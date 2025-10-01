#!/bin/bash

# Load needed variables
. ~/start.sh

# Parse & validate inputs
SM=$1
bam=$2
base=$(basename $bam)
if [ -z $SM ] || [ -z $bam ] 
then
    echo "Error, both sample identifier and bam/cram file must be provided"
    exit 1

elif [ ! -f $bam ]
then
    echo "Error, bam file not found for '$SM'\\nSupplied arg '$bam'"
    exit 1
fi

# Setup working directory
wrk=$TMPDIR/$SLURM_JOB_ID/$SM-DedupBqsr
mkdir -p $wrk
cd $wrk


#########################################
#########################################
## 
## 1). Dedup
## 
#########################################
#########################################


# Convert to BAM
time samtools view -h -@ 8 -T $b38_REF $bam -b > $SM.bam
samtools index -@ 8 $SM.bam

# Mark duplicate reads
echo -e "\\n\\nMarking Duplicate Reads\\n"
time java -Djava.io.tmpdir=$wrk -jar $GATK \
    MarkDuplicates \
    I=$SM.bam AS=true O=$SM.dedup.bam \
    METRICS_FILE=$SM.dedupMetrics.txt QUIET=true \
    COMPRESSION_LEVEL=0 2>> $BAM/$SM/$SM-Dedup.log

# Sort dedup BAM
samtools sort -@ 8 -o $BAM/$SM/$SM.dedup-sorted.bam $SM.dedup.bam
samtools index -@ 8 $BAM/$SM/$SM.dedup-sorted.bam

# Clean up temp BAMs
if [ -f $BAM/$SM/$SM.dedup-sorted.bam.bai ]
then
    echo "Deduplication successful, clearing temp & original files"
    rm -f $SM.bam* $SM.dedup.bam* $bam*
    mv $SM.dedupMetrics.txt $BAM/$SM/

else
    echo "Error: Deduplication failed. Check logs"
    cd ..
    rm -fr $SM-DedupBqsr
    exit 1
fi


#########################################
#########################################
## 
## 3). BQSR
## 
#########################################
#########################################


# Calculate recalibration table
echo -e "\\n\\nCalculating recalibration model\\n"
BQSR_Loci=$(echo -L chr{1..22} | sed 's/ / -L /g' | sed 's/-L -L/-L/g')
time java -Djava.io.tmpdir=$wrk -jar $GATK \
    BaseRecalibrator -R $b38_REF \
    -I $BAM/$SM/$SM.dedup-sorted.bam -o $BAM/$SM/$SM.recal \
    $BQSR_Loci \
    -knownSites $dbSNP \
    -knownSites $MILLS \
    -knownSites $KnownIndels 2>> $BAM/$SM/$SM.bqsr.log


# Apply recalibration model
echo -e "\\n\\nApplying recalibration model\\n"
time java -Djava.io.tmpdir=$wrk -jar $GATK \
    ApplyBQSR \
    -I $BAM/$SM/$SM.dedup-sorted.bam -R $b38_REF \
    --bqsr-recal-file $BAM/$SM/$SM.recal \
    -O $BAM/$SM/$SM.bqsr.bam \
    --global-qscore-prior -1.0 \
    --preserve-qscores-less-than 6 \
    --static-quantized-quals 10 \
    --static-quantized-quals 20 \
    --static-quantized-quals 30 2>> $BAM/$SM/$SM.bqsr.log

if [ -f $BAM/$SM/$SM.bqsr.bam ]
then
    echo "BQSR Applied"
    rm -f $BAM/$SM/$SM.dedup-sorted.bam* $BAM/$SM/$SM.recal

else
    echo "Error: BQSR processing failed, check logs."
    exit 1
fi


# Sort and compress directly to CRAM
echo -e "\\n\\nSorting & compressing to CRAM\\n"
time samtools sort -@ 8 -T $wrk -O CRAM -o $BAM/$SM/$SM.final-gatk.cram $BAM/$SM/$SM.bqsr.bam -T $b38_REF
samtools index -@ 8 $BAM/$SM/$SM.final-gatk.cram

# Final cleanup
if [ -f $BAM/$SM/$SM.final-gatk.cram.crai ]
then
    echo "Processing complete, cleaning temp directory"
    cd ..
    rm -fr $SM-DedupBqsr
    rm -f $BAM/$SM/$SM.bqsr.bam*

    # Generate MD5 checksum and flagstats
    echo -e "Generating MD5 sum and alignment summary metrics"
    md5sum $BAM/$SM/$SM.final-gatk.cram* > $BAM/$SM/$SM.final-gatk.cram.md5sum
    samtools flagstat -@ 2 $BAM/$SM/$SM.final-gatk.cram > $BAM/$SM/$SM-flagstats.txt

else
    echo "Error: CRAM processing failed, check logs."
    exit 1
fi