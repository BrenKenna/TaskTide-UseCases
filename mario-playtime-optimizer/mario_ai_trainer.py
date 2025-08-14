"""
Super Mario Bros PPO Trainer & Player
Generated with assistance from ChatGPT

This script allows you to train or play Super Mario Bros using the PPO algorithm 
from Stable-Baselines3 with preprocessing wrappers including grayscale conversion, 
frame skipping, and frame stacking.

Features:
- Training & playback modes
- Optional video recording
- Customizable world and level
"""

import sys
import argparse
import os
import logging
import cv2
import gym
import numpy as np
import gym_super_mario_bros
from gym_super_mario_bros.actions import SIMPLE_MOVEMENT
from nes_py.wrappers import JoypadSpace
from stable_baselines3 import PPO
from stable_baselines3.common.vec_env import DummyVecEnv, VecFrameStack, VecVideoRecorder

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler("training.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class StreamToLogger:
    """
    Redirects writes to a logger instance.
    """
    def __init__(self, logger, level):
        self.logger = logger
        self.level = level
        self.buffer = ''

    def write(self, message):
        message = message.strip()
        if message:
            self.logger.log(self.level, message)

    def flush(self):
        pass  # This method is required for compatibility


class SkipFrame(gym.Wrapper):
    """
    Wrapper that repeats the same action for a fixed number of frames.
    """
    def __init__(self, env, skip):
        super().__init__(env)
        self._skip = skip

    def step(self, action):
        total_reward = 0.0
        done = False
        for _ in range(self._skip):
            obs, reward, done, info = self.env.step(action)
            total_reward += reward
            if done:
                break
        return obs, total_reward, done, info


class GrayScaleObservation(gym.ObservationWrapper):
    """
    Converts observations to grayscale and resizes them to 84x84.
    """
    def __init__(self, env):
        super().__init__(env)
        self.observation_space = gym.spaces.Box(
            low=0, high=255, shape=(84, 84, 1), dtype=np.uint8
        )

    def observation(self, obs):
        obs = cv2.cvtColor(obs, cv2.COLOR_RGB2GRAY)
        obs = cv2.resize(obs, (84, 84), interpolation=cv2.INTER_AREA)
        return obs[:, :, None]


def create_env(world: int, level: int):
    """
    Creates a processed gym environment for a specific Mario world and level.
    """
    env_id = f"SuperMarioBros-{world}-{level}-v0"
    logger.info(f"Creating environment: {env_id}")
    env = gym_super_mario_bros.make(env_id)
    env = JoypadSpace(env, SIMPLE_MOVEMENT)
    env = SkipFrame(env, skip=4)
    env = GrayScaleObservation(env)
    env = DummyVecEnv([lambda: env])
    env = VecFrameStack(env, n_stack=4)
    return env


def train(world: int, level: int, timesteps: int):
    """
    Trains a PPO agent on the specified world and level.
    """
    logger.info(f"Starting training on World {world} Level {level} for {timesteps} timesteps.")
    env = create_env(world, level)
    model = PPO("CnnPolicy", env, verbose=1)
    model.learn(total_timesteps=timesteps)
    model_path = f"mario_{world}_{level}_ppo"
    model.save(model_path)
    logger.info(f"Training complete. Model saved to {model_path}.zip")


def play(world: int, level: int, model_path: str, record_video: bool = False, stop_after_level: int = 1, max_retries: int = 10):
    """
    Loads a trained model and plays the game, optionally recording video.
    Retries until level is completed or retry limit is reached.
    """
    if not os.path.exists(model_path + ".zip"):
        raise FileNotFoundError(f"Trained model not found at: {model_path}.zip")

    logger.info(f"Loading model from {model_path}.zip")
    model = PPO.load(model_path)

    video_writer = None
    retry_count = 0
    steps_total = 0

    while retry_count < max_retries:
        env = create_env(world, level)
        obs = env.reset()
        done = False
        steps = 0

        if record_video and video_writer is None:
            os.makedirs("videos", exist_ok=True)
            video_path = f"videos/{os.path.basename(model_path)}.mp4"
            frame = env.render(mode="rgb_array")
            height, width, _ = frame.shape
            video_writer = cv2.VideoWriter(
                video_path, cv2.VideoWriter_fourcc(*"mp4v"), 30, (width, height)
            )
            logger.info("Video recording enabled.")

        while not done:
            action, _ = model.predict(obs)
            obs, _, done, info = env.step(action)
            frame = env.render(mode="rgb_array")

            if record_video and video_writer:
                video_writer.write(cv2.cvtColor(frame, cv2.COLOR_RGB2BGR))

            steps += 1
            steps_total += 1

            if info[0].get("flag_get"):
                logger.info(f"Level {level} completed in {steps} steps.")
                if record_video and video_writer:
                    video_writer.release()
                    logger.info(f"Video saved to ./videos/{os.path.basename(model_path)}.mp4")
                return

        logger.info(f"Mario died on attempt {retry_count + 1} after {steps} steps.")
        retry_count += 1

    logger.warning(f"Max retries ({max_retries}) reached. Level {level} not completed.")
    if record_video and video_writer:
        video_writer.release()
        logger.info(f"Partial video saved to ./videos/{os.path.basename(model_path)}.mp4")



def main():
    parser = argparse.ArgumentParser(description="Train or play Super Mario Bros using PPO.")
    parser.add_argument("--mode", choices=["train", "play"], required=True, help="train or play")
    parser.add_argument("--world", type=int, default=1, help="World number (1-8)")
    parser.add_argument("--level", type=int, default=1, help="Level number (1-4)")
    parser.add_argument("--timesteps", type=int, default=1_000_000, help="Training timesteps")
    parser.add_argument("--video", action="store_true", help="Record video (only in play mode)")
    parser.add_argument("--model-path", type=str, help="Path to trained model (only for play mode)")
    parser.add_argument("--stop-after-level", type=int, default=1, help="Level to stop after playing")
    parser.add_argument("--max-retries", type=int, default=10, help="Max number of retries (lives) before stopping")

    args = parser.parse_args()

    if args.mode == "train":
        train(args.world, args.level, args.timesteps)
    elif args.mode == "play":
        if not args.model_path:
            raise ValueError("--model-path is required in play mode.")
        play(args.world, args.level, args.model_path, record_video=args.video, stop_after_level=args.stop_after_level, max_retries=args.max_retries)


 # Redirect stdout and stderr to logger
if __name__ == "__main__":
    sys.stdout = StreamToLogger(logger, logging.INFO)
    sys.stderr = StreamToLogger(logger, logging.ERROR)
    main()