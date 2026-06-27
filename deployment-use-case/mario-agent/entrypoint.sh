#!/bin/bash

set -e

CMD=${1:-help}
shift || true

case "$CMD" in
  train)
    mario-agent --mode train "$@"
    ;;
  play)
    mario-agent --mode play "$@"
    ;;
  help|*)
    echo "Usage:"
    echo "  mario-agent train --world 1 --level 1 --timesteps 6000"
    echo "  mario-agent play --model-path mario_1_1_ppo"
    ;;
esac