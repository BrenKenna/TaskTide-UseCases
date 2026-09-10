from setuptools import setup, find_packages
import os

this_directory = os.path.abspath(os.path.dirname(__file__))
with open(os.path.join(this_directory, "README.md"), encoding="utf-8") as f:
    long_description = f.read()

setup(
    name="mario-agent",
    version="1.0.1",
    packages=find_packages(),

    description="Pygym agent for Mario Bros",
    long_description=long_description,
    long_description_content_type="text/markdown",

    project_urls={
        "Homepage": "https://github.com/BrenKenna/Mario-AI-Agent",
        "TaskTide Core": "https://tasktide.org"
    },

    py_modules=["mario-ai-agent"],
    install_requires=[
        "gym==0.21.0",
        "stable-baselines3==1.6.2",
        "gym-super-mario-bros==7.4.0",
        "nes-py==8.2.1",
        "pyglet==1.5.21",
        "opencv-python",
        "numpy<1.24",
    ],
    entry_points={
        "console_scripts": [
            "mario-agent=mario_ai_agent:main"
        ]
    }
)