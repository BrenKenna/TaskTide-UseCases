from setuptools import setup

setup(
    name="mario-agent",
    version="1.0.0",
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