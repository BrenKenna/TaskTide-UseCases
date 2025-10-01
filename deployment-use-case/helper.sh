#!/bin/bash

# Prequistes
apt-get install -y \ 
    ffmpeg libglu1-mesa libgl1-mesa-glx \
    libgl1-mesa-dri libegl1-mesa libgles2-mesa


# Train app
python3 mario_ai_trainger.py --mode train --world 1 --level 1 --timesteps 6000


# Play given level
export PYGLET_HEADLESS=1
python3 mario_ai_trainer.py --mode play --model-path mario_1_1_ppo --video --stop-after-level 2