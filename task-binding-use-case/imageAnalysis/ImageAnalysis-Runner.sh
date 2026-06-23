#!/bin/bash

# Load environment
. ~/start.sh


# Handle job id
if [ ! -z "$SLURM_ARRAY_TASK_ID" ]
then
    JOB_ID=${SLURM_JOB_ID}_${SLURM_ARRAY_TASK_ID}

else 
    JOB_ID="${SLURM_JOB_ID:-local}"
fi


# Configure log directory
echo -e "Configuring image analysis for directory:\\t$JOB_ID"
mkdir -p $DATA_DIR/logs/ImageAnalysis/
set -e 
exec > >(tee -a $DATA_DIR/logs/ImageAnalysis/$JOB_ID-ImageAnalysis.log) 2>&1


# Configure working directory
set -x
wrk=$TMPDIR/ImageAnalysis/$JOB_ID
mkdir -p $wrk
cd $wrk


# Run image analysis
echo -e "Configuring image analysis for:\\t$JOB_ID"
spark-submit \
    --master local[*] \
    ~/software/bin/image-generator.R \
        "$@"


# Cleanup
echo -e "Cleaning up image analysis:\\t$JOB_ID"
cd ../
rm -fr $label
echo -e "Image analysis complete for job:\\t$JOB_ID"