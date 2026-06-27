# Use Java17 base image installing required software
FROM eclipse-temurin:17-jre


# Configure container
RUN groupadd --system tasktide && \
    useradd --system --create-home --home-dir /home/tasktide --gid tasktide tasktide && \
    apt-get update && \
    apt-get install -y --no-install-recommends unzip && \
    rm -rf /var/lib/apt/lists/*


# Unpack task into working directory
COPY tasktide.zip /tmp/tasktide.zip
RUN unzip /tmp/tasktide.zip -d /opt &&
    mv /opt/tasktide-0.9.5 /opt/tasktide && \
    chmod +x /opt/tasktide/bin/tasktide && \
    chown -R tasktide:tasktide /opt/tasktide


# Mark config folder as volume for swapping configs
VOLUME [ "/opt/tasktide/config" ]


# Switch to non root user to run task tide
USER tasktide
WORKDIR /home/tasktide
ENTRYPOINT [ "/opt/tasktide/bin/tasktide" ]