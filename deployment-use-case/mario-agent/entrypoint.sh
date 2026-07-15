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
          MODEL_PATH="$2"
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
    taskLabel="PlayMario_Bros-${WORLD}_Level-$LEVEL"
    taskScript="apptainer docker://bkenna/mario-agent play --video --model-path $WRK/mario_$WORLD_$LEVEL_ppo.zip"

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
    WRK="/data/mario/world-$WORLD/level-$LEVEL"
    mkdir -p $WRK && cd $WRK

    # Play agent using the trained model
    mario-agent --mode play \
        --model-path "mario_$WORLD_$LEVEL_ppo" \       
        --video

else
    echo "Usage:"
    echo "  mario-agent train --world 1 --level 1 --timesteps 6000"
    echo "  mario-agent play --model-path mario_1_1_ppo"

fi