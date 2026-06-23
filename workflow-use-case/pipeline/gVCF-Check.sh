#!/bin/bash

# Load needed variables
. ~/start.sh


# Parse & validate inputs
inp=$1
acc=$(basename $inp | cut -d \. -f 1)
base=$(basename $inp)
if [ -z $inp ]  
then
    echo "Error, both sample identifier and gvcf file must be provided"
    exit 1
elif [ ! -f $inp ]
then
    echo "Error, gvcf file not found for '$acc'\\nSupplied arg '$gvcf'"
    exit 1
fi


# Sanity check gVCF
iid=$(zcat $inp | head -n 10000 | grep "#CHROM" | cut -f 10)
size=$(du -sh $inp | awk '{print $1}')
length=$(zcat $inp | wc -l)
width=$(zcat $inp | grep -v "\#" | awk '{print NF}' | sort | uniq -c | awk '{print $2}' | sed 's/\n/,/g')
NVar=$(zgrep -c "MQ" $inp )


# Summarise variants
GQ20=$(zgrep "MQ" $inp | cut -f 10 | cut -d \: -f 4 | sort -n | awk '$1 > 20 {print}' | wc -l)
GQ60=$(zgrep "MQ" $inp | cut -f 10 | cut -d \: -f 4 | sort -n | awk '$1 > 60 {print}' | wc -l)
GQ90=$(zgrep "MQ" $inp | cut -f 10 | cut -d \: -f 4 | sort -n | awk '$1 > 90 {print}' | wc -l)
variantSummary=$GQ20,$GQ60,$GQ90


# Create table
echo -e "IID\\tAccession\\tgVCF\\tDisk_Usage\\tWidth\\tLength\\tN_Variants\\tN_dbSNP_Calls\\tGenome_GQ_Summary(GT_20,GT_60,GT_90)\\tVariant_GQ_Summary(GT_20,GT_60,GT_90)" > ${base}_checks.tsv
echo -e "$iid\\t$acc\\t$base\\t$size\\t$width\\t$length\\t$NVar\\t$variantSummary" >> ${base}_checks.tsv