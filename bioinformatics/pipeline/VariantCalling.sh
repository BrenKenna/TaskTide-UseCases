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

wrk=$TMPDIR/$SLURM_JOB_ID/$SM-Alignment
mkdir -p $wrk

# Run haplotype caller
echo -e "\\nPerforming WXS Calling\\n"
mkdir -p $GVCF/$SM/
samtools view -h -b $bam > $wrk/$SM.bam
samtools index $wrk/$SM.bam

time java -Djava.io.tmpdir=$wrk -jar $GATK \
    HaplotypeCaller \
    --native-pair-hmm-threads 2 \
    -R $b38_REF --dbsnp $dbSNP \
    -ERC GVCF -L $TGT \
    -I $wrk/$SM.bam \
    -O $GVCF/$SM/$SM.g.vcf.gz &>> $GVCF/$SM/$SM.vcf.log

cd $GVCF/$SM/
md5sum $SM.g.vcf.gz* > $SM.md5sum


# Check results
bash $SOFT/bin/alignment-scripts/gVCF-Checks.sh $SM.g.vcf.gz