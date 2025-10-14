#!/bin/bash


if [[ "$1" == "gpu" ]]
then
    echo "Starting interactive GPU session..."
    srun --job-name="Interactive-GPU-Shell" \
        --partition=gpu \
        --gres=gpu:1 \
        --nodes=1 \
        --ntasks=1 \
        --job-name="GPU-Job" \
        --cpus-per-task=4 \
        --time=08:00:00 \
        --pty bash
else
    echo "Starting interactive CPU session..."
    srun --job-name="Interactive-Shell" \
        -t 08:00:00 \
        -n 1 \
        -c 8 \
        --pty bash
fi