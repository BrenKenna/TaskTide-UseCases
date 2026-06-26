#!/bin/bash


##################################################
##################################################
## 
## 1). Verify Containerized Application
## 
##################################################
##################################################

# Start container
docker run -it --rm `
    -v "C:\Users\Bren\Documents\GitHub\TaskTide\tasktide\use-cases\deployment-use-case:/app" `
    -w /app `
    python:3.10 bash


# Prequistes
apt update -y && apt upgrade -y

apt install -y \
    python3-dev build-essential \
    libgl1 libegl1 libgles2 \
    libglu1-mesa mesa-utils libgl1-mesa-dri ffmpeg

pip install "setuptools<65" "wheel<0.38"
pip install --upgrade pip==23.3.2


# Install agent dependancies
pip install -e .


# Train app
mario-agent \
    --mode train \
    --world 1 \
    --level 1 \
    --timesteps 6000

'''

root@9d4ccd887222:/app# mario-agent \
    --mode train \
    --world 1 \
    --level 1 \
    --timesteps 6000
2026-06-26 12:07:12,554 [INFO] Starting training on World 1 Level 1 for 6000 timesteps.
2026-06-26 12:07:12,555 [INFO] Creating environment: SuperMarioBros-1-1-v0
Using cpu device
Wrapping the env in a VecTransposeImage.
-----------------------------
| time/              |      |
|    fps             | 87   |
|    iterations      | 1    |
|    time_elapsed    | 23   |
|    total_timesteps | 2048 |
-----------------------------
----------------------------------------
| time/                   |            |
|    fps                  | 68         |
|    iterations           | 2          |
|    time_elapsed         | 59         |
|    total_timesteps      | 4096       |
| train/                  |            |
|    approx_kl            | 0.02251003 |
|    clip_fraction        | 0.329      |
|    clip_range           | 0.2        |
|    entropy_loss         | -1.92      |
|    explained_variance   | 0.000336   |
|    learning_rate        | 0.0003     |
|    loss                 | 127        |
|    n_updates            | 10         |
|    policy_gradient_loss | 0.0139     |
|    value_loss           | 545        |
----------------------------------------
-----------------------------------------
| time/                   |             |
|    fps                  | 64          |
|    iterations           | 3           |
|    time_elapsed         | 95          |
|    total_timesteps      | 6144        |
| train/                  |             |
|    approx_kl            | 0.019705089 |
|    clip_fraction        | 0.307       |
|    clip_range           | 0.2         |
|    entropy_loss         | -1.88       |
|    explained_variance   | 0.627       |
|    learning_rate        | 0.0003      |
|    loss                 | 235         |
|    n_updates            | 20          |
|    policy_gradient_loss | 0.0132      |
|    value_loss           | 595         |
-----------------------------------------
2026-06-26 12:09:07,300 [INFO] Training complete. Model saved to mario_1_1_ppo.zip

root@9d4ccd887222:/app#

'''

##################################################
##################################################
## 
## 1). Verify Containerized Application
## 
##################################################
##################################################


# Build container
docker build -t mario-agent -f mario-agent.Dockerfile .


# Run container
docker run -it --rm mario-agent train --world 1 --level 1 --timesteps 6000

'''

2026-06-26 13:14:05,191 [INFO] Starting training on World 1 Level 1 for 6000 timesteps.
2026-06-26 13:14:05,192 [INFO] Creating environment: SuperMarioBros-1-1-v0
Using cpu device
Wrapping the env in a VecTransposeImage.
-----------------------------
| time/              |      |
|    fps             | 72   |
|    iterations      | 1    |
|    time_elapsed    | 28   |
|    total_timesteps | 2048 |
-----------------------------
----------------------------------------
| time/                   |            |
|    fps                  | 58         |
|    iterations           | 2          |
|    time_elapsed         | 70         |
|    total_timesteps      | 4096       |
| train/                  |            |
|    approx_kl            | 0.01891379 |
|    clip_fraction        | 0.314      |
|    clip_range           | 0.2        |
|    entropy_loss         | -1.92      |
|    explained_variance   | 0.000154   |
|    learning_rate        | 0.0003     |
|    loss                 | 301        |
|    n_updates            | 10         |
|    policy_gradient_loss | 0.0106     |
|    value_loss           | 953        |
----------------------------------------
-----------------------------------------
| time/                   |             |
|    fps                  | 54          |
|    iterations           | 3           |
|    time_elapsed         | 111         |
|    total_timesteps      | 6144        |
| train/                  |             |
|    approx_kl            | 0.034630843 |
|    clip_fraction        | 0.386       |
|    clip_range           | 0.2         |
|    entropy_loss         | -1.86       |
|    explained_variance   | 0.498       |
|    learning_rate        | 0.0003      |
|    loss                 | 823         |
|    n_updates            | 20          |
|    policy_gradient_loss | 0.0122      |
|    value_loss           | 1.95e+03    |
-----------------------------------------
2026-06-26 13:16:17,984 [INFO] Training complete. Model saved to mario_1_1_ppo.zip

'''