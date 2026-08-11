#!/bin/bash

# Parse arguments
export PYTHONPATH=/opt/mario-agent:$PYTHONPATH

set -ex
MODE=$1
shift

case "$MODE" in
  train)
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --world)
          WORLD="$2"
          shift 2
          ;;
        --level)
          LEVEL="$2"
          shift 2
          ;;
        --timesteps)
          TIMESTEPS="$2"
          shift 2
          ;;
        *)
          echo "Unknown arg: $1"
          exit 1
          ;;
      esac
    done
    ;;
  play)
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --model-path)
          MODEL_PATH=$( echo $2 | sed 's/.zip//g' )
          shift 2
          ;;
        --video)
          VIDEO="--video"
          shift 1
          ;;
        --max-retries)
          MAX_RETRIES=${2:-5}
          shift 2
          ;;
        --stop-after)
          STOP_AFTER=${2:-5}
          shift 2
          ;;
        *)
          echo "Unknown arg: $1"
          exit 1
          ;;
      esac
    done
    ;;
esac


# Determine how to run agent
if [ "$MODE" == "train" ]
then

    # Setup working directory
    WRK="/data/mario/world-$WORLD/level-$LEVEL"
    mkdir -p $WRK && cd $WRK

    # Train agent
    mario-agent \
        --mode train \
        --world $WORLD \
        --level $LEVEL \
        --timesteps $TIMESTEPS

    # Enqueue play task
    stepName="PlayMarioBros"
    taskLabel="PlayMarioBros-World-${WORLD}_Level-${LEVEL}"
    containerCMD="apptainer run --bind /data/mario:/data --env PYTHONPATH=/opt/mario-agent:\$PYTHONPATH /opt/mario-agent/mario-agent.sif"
    task="play --video --model-path $WRK/mario_${WORLD}_${LEVEL}_ppo --max-retries 10 --stop-after 5"
    taskScript="$containerCMD $task"

    curl -v -H "Content-Type: application/json" \
       -X POST http://tasktide_app/services/workitem/create \
        -d "$(jq -n \
            --arg name "$taskLabel" \
            --arg task "$taskScript" \
            --arg step "$stepName" \
              '{
                "Task Name": $name,
                "Task Script": $task,
                "Step Name": $step
              }')"


# Otherwise play 
elif [ "$MODE" == "play" ]
then

    # Setup working directory
    WORLD=$(basename $MODEL_PATH | cut -d '_' -f 2)
    LEVEL=$(basename $MODEL_PATH | cut -d '_' -f 3)
    WRK="/data/mario/videos/world-${WORLD}/level-${LEVEL}"
    mkdir -p $WRK && cd $WRK

    # Play agent using the trained model
    mario-agent \
      --mode play \
      --model-path "$MODEL_PATH" \
      --video \
      --max-retries $MAX_RETRIES \
      --stop-after-level $STOP_AFTER

else
    echo "Usage:"
    echo "  mario-agent train --world 1 --level 1 --timesteps 6000"
    echo "  mario-agent play --model-path mario_1_1_ppo"
fi