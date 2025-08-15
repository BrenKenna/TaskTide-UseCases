#!/bin/bash
# Wrapper for SLURM job array tasks

LOG_DIR="/scratch/$USER/tasks"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$SLURM_ARRAY_TASK_ID.log"

{
    echo "===== TASK $SLURM_ARRAY_TASK_ID START ====="
    
    # Print environment
    echo "===== Displaying Environment ====="
    printenv
    
    # CPU info
    echo "===== CPU Info ====="
    lscpu | grep -E 'Architecture|Socket|Core|Thread|CPU\(s\)'
    
    # RAM info
    echo "===== RAM Info ====="
    free -h | awk '/^Mem:/ {print "Total RAM:", $2, "Used:", $3, "Free:", $4}'
    
    echo "===== TASK $SLURM_ARRAY_TASK_ID END ====="
} &> "$LOG_FILE"