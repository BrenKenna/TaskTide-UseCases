# Python 3.10 base image
FROM python:3.10-slim


# System deps
RUN apt-get update && apt-get install -y \
    libgl1 libegl1 libgles2 \
    libglu1-mesa mesa-utils libgl1-mesa-dri \
    ffmpeg \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*


# Set working directory inside user home
WORKDIR /opt/mario-agent
COPY . .

RUN pip install --no-cache-dir \
    "setuptools<65" "wheel<0.38" \
    && pip install --no-cache-dir --upgrade pip==23.3.2

RUN pip install -e .


# Non-previleged container
RUN useradd -m -s /bin/bash mario-agent
RUN chown -R mario-agent:mario-agent /opt/mario-agent \
    && chmod +x /opt/mario-agent/entrypoint.sh
USER mario-agent


# Default working dir
WORKDIR /home/mario-agent/
ENTRYPOINT ["/opt/mario-agent/entrypoint.sh"]