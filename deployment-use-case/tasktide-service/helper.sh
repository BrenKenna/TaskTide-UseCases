#!/bin/bash



##################################################
##################################################
## 
## 1). Test Application in Container
## 
##################################################
##################################################



# Start container
docker container run -it --rm `
    -v "C:\Users\Bren\Documents\GitHub\TaskTide\tasktide\use-cases\deployment-use-case\tasktide-service:/docker-build:ro" `
    -v "C:\Users\Bren\Documents\GitHub\TaskTide\tasktide\tasktide\build\distributions\tasktide-0.9.5.zip:/tasktide.zip:ro" `
    -w /app `
    eclipse-temurin:17-jre bash


# Prequistes
apt update -y && apt upgrade -y
apt-get install -y --no-install-recommends unzip
rm -rf /var/lib/apt/lists/*


# Provision user
groupadd --system tasktide
useradd --system --create-home --home-dir /home/tasktide --gid tasktide tasktide


# Unpack app
unzip /tasktide.zip -d /opt/
mv /opt/tasktide-0.9.5 /opt/tasktide

chmod +x /opt/tasktide/bin/tasktide
chown -R tasktide:tasktide /opt/tasktide


# Test
/opt/tasktide/bin/tasktide --help

'''
  _____         _      _____ _     _      
 |_   _|_ _ ___| | __ |_   _(_) __| | ___ 
   | |/ _` / __| |/ /   | | | |/ _` |/ _ \
   | | (_| \__ \   <    | | | | (_| |  __/
   |_|\__,_|___/_|\_\   |_| |_|\__,_|\___|

TaskTide-v0.9.0
_________________________________________________

'''


##################################################
##################################################
## 
## 2). Verify Containerized Application
## 
##################################################
##################################################


# Build container
docker build -t tasktide -f tasktide.Dockerfile .


# Test
docker container run `
    tasktide --help

'''

  _____         _      _____ _     _      
 |_   _|_ _ ___| | __ |_   _(_) __| | ___ 
   | |/ _` / __| |/ /   | | | |/ _` |/ _ \
   | | (_| \__ \   <    | | | | (_| |  __/
   |_|\__,_|___/_|\_\   |_| |_|\__,_|\___|

TaskTide-v0.9.0
_________________________________________________

2026-06-27 17:21:32 WARN  [ main -> org.tasktide.tasktide.TaskTide.main ]: Help flag detected

'''
