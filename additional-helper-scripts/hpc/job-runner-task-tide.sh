#!/bin/bash


# Load and setup working directory for TaskTide
. ~/start.sh

JOB_ID="${SLURM_JOB_ID:-local}"
JOB_NAME="${SLURM_JOB_NAME:-tasktide_job}"
NODE_LIST="${SLURM_NODELIST:-unknown}"
START_TIME="$(date '+%Y-%m-%d %H:%M:%S')"
START_EPOCH=$(date +%s)

CMD=(tasktide engine "$@")

mkdir -p $TMPDIR/tasktide/$SLURM_JOB_ID && \
    cd $TMPDIR/tasktide/$SLURM_JOB_ID


# Configur task logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [job:$JOB_ID] $*"
}


# Slurm job meta data
echo -e "\\n\\n"
log "========================================"
log "TaskTide SLURM job starting"
log "Job ID      : $JOB_ID"
log "Job Name    : $JOB_NAME"
log "Nodes       : $NODE_LIST"
log "Start time  : $START_TIME"
log "Workdir     : $WORKDIR"
log "Args passed : $*"
log "========================================"
echo -e "\\n\\n"

# TaskTide metadata
log "========================================"
log "Resolved command:"
log "  ${CMD[*]}"

# Run tasktide
log "Launching tasktide:"
set -ex
tasktide \
    engine "$@"

EXIT_CODE=${PIPESTATUS[0]}
END_EPOCH=$(date +%s)
DURATION=$((END_EPOCH - START_EPOCH))

echo -e "\\n\\n\\n\\n"
log "Tasktide finished, cleaning up working directory"
log "Exit code : $EXIT_CODE"
log "Duration  : ${DURATION}s"
log "End time  : $(date '+%Y-%m-%d %H:%M:%S')"

# Clean up
cd .. && rm -fr $SLURM_JOB_ID
log "Cleaned up workdir"
log "========================================"
echo -e "\\n\\n"