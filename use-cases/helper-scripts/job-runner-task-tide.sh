#!/bin/bash

. ~/start.sh


# Stagger batch
ms=$(((1000 + RANDOM % 4001) / 1000));
sleep $ms

if [ ! -z "$SLURM_ARRAY_TASK_ID" ]
then
    JOB_ID=$SLURM_ARRAY_TASK_ID

else 
    JOB_ID="${SLURM_JOB_ID:-local}"
fi

JOB_NAME="${SLURM_JOB_NAME:-tasktide_job}"
LOG_FILE="$JOBDIR/$JOB_NAME/$JOB_ID.log"

START_TIME="$(date '+%Y-%m-%d %H:%M:%S')"
START_EPOCH=$(date +%s)
CMD=(tasktide engine "$@")

mkdir -p $TMPDIR/tasktide/$SLURM_JOB_ID && \
    cd $TMPDIR/tasktide/$SLURM_JOB_ID

mkdir -p $JOBDIR/$JOB_NAME
rm -f $LOG_FILE && touch $LOG_FILE


# Configur task logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [job:$JOB_ID] $*" &>> $LOG_FILE
}


# Slurm job meta data
echo -e "\\n\\n" &>> $LOG_FILE
log "========================================"
log "TaskTide SLURM job starting"
log "Job ID      : $JOB_ID"
log "Job Name    : $JOB_NAME"
log "Nodes       : $NODE_LIST"
log "Start time  : $START_TIME"
log "Workdir     : $WORKDIR"
log "Args passed : $*"
log "========================================"
echo -e "\\n\\n" &>> $LOG_FILE


# TaskTide metadata
log "========================================"
log "Resolved command:"
log "  ${CMD[*]}"


# Run tasktide
log "Launching tasktide:"

set -ex
tasktide \
    engine "$@" &>> $LOG_FILE

EXIT_CODE=${PIPESTATUS[0]}
END_EPOCH=$(date +%s)
DURATION=$((END_EPOCH - START_EPOCH))


echo -e "\\n\\n\\n\\n" &>> $LOG_FILE
log "Tasktide finished, cleaning up working directory"
log "Exit code : $EXIT_CODE"
log "Duration  : ${DURATION}s"
log "End time  : $(date '+%Y-%m-%d %H:%M:%S')"


# Clean up
cd .. && \
    rm -fr $SLURM_JOB_ID
log "Cleaned up workdir"
log "========================================"
echo -e "\\n\\n" &>> $LOG_FILE