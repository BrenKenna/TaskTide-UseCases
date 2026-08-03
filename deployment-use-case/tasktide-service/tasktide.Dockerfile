# Use Java17 base image installing required software
FROM eclipse-temurin:17-jre


# Configure container
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        unzip \
        jq \
        curl \
        fuse \
        squashfuse \
        apptainer && \
    mkdir -p /home/tasktide/.apptainer && \
    rm -rf /var/lib/apt/lists/*


# Unpack task into working directory
COPY tasktide.zip /tmp/tasktide.zip
RUN unzip /tmp/tasktide.zip -d /opt && \
    mv /opt/tasktide-0.9.5 /opt/tasktide && \
    chmod +x /opt/tasktide/bin/tasktide


# Mark config folder as volume for swapping configs
VOLUME [ "/opt/tasktide/config" ]


# Configure non-root user
RUN groupadd --system tasktide && \
    useradd --system --create-home --home-dir /home/tasktide --gid tasktide tasktide && \
    chown -R tasktide:tasktide /home/tasktide && \
    chown -R tasktide:tasktide /opt/tasktide


# Switch to non root user to run task tide
USER tasktide
WORKDIR /home/tasktide
ENTRYPOINT [ "/opt/tasktide/bin/tasktide" ]