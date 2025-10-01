#!/bin/bash

# Load needed variables
. ~/start.sh

# Parse & validate inputs
SM=$1
bam=$2
base=$(basename $bam)
if [ -z "$SM" ] || [ -z "$bam" ]
then
    echo "Error, both sample identifier and bam/cram file must be provided"
    exit 1
fi

# Setup working directory
wrk=$TMPDIR/$SLURM_JOB_ID/$SM-Alignment
mkdir -p $wrk
cd $wrk

# Fetch sample
wget $bam
wget $bam.bai


# Shuffle and write to fastq for realignment
echo -e "\\n\\nPerforming FASTQ extraction\\n"
time samtools bamshuf -@ 8 --reference $b37_REF \
    --output-fmt BAM -uOn 128 $base $SM.tmp | \
    samtools bam2fq -@ 8 -t -s /dev/null \
        -1 $SM.R1.fq.gz -2 $SM.R2.fq.gz - 
> /dev/null
rm -f $base*


# Align to b38
echo -e "\\n\\nPerforming alignment to build 38\\n"
mkdir -p $BAM/$SM
time \
    $BWA_DIR/bwa mem -K 100000000 -t 8 -Y $b38_REF -R "@RG\tID:$SM\tLB:$SM\tSM:$SM\tPL:ILLUMINA" $SM.R1.fq.gz $SM.R2.fq.gz 2>> $BAM/$SM/$SM-Alignment.log \
    | samblaster -a --addMateTags \
    | samtools view -h --threads 8 -CS > $SM.aln.cram
rm -f $SM.R1.fq.gz $SM.R2.fq.gz


# Sort and index
echo -e "\\n\\nSorting aligned cram\\n"
time samtools sort -@ 8 -T $wrk -o $BAM/$SM/$SM.sorted.cram $SM.aln.cram
samtools index -@ 8 $BAM/$SM/$SM.sorted.cram
rm -f $SM.aln.cram


# Clean up
cd ..
rm -fr $SM-Alignment
echo -e "\\nProcessing completed"