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
      --name "tasktide_webapi" -p "80:80" `
      tasktide web-api --host "tasktide_webapi" --port 80 --base-path "/tasktide"


'''

  _____         _      _____ _     _      
 |_   _|_ _ ___| | __ |_   _(_) __| | ___ 
   | |/ _` / __| |/ /   | | | |/ _` |/ _ \
   | | (_| \__ \   <    | | | | (_| |  __/
   |_|\__,_|___/_|\_\   |_| |_|\__,_|\___|

TaskTide-v0.9.0
_________________________________________________


2026-06-27 20:39:26 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Constructing client: 'WebAPI'
2026-06-27 20:39:26 INFO  [ main -> org.tasktide.tasktide.client.TaskTideWebApiClient.configureClient ]: Fetching configurations for TaskTide-WebApi
2026-06-27 20:39:26 INFO  [ main -> org.tasktide.tasktide.client.TaskTideWebApiClient.configureClient ]: Proceeding with TaskTide-WebApi configurations:

Host = 'tasktide_webapi'
Port = '80'
Base Path = '/tasktide'
2026-06-27 20:39:26 INFO  [ main -> org.tasktide.tasktide.client.TaskTideWebApiClient.configureClient ]: TaskTide-WebApi configured
2026-06-27 20:39:26 INFO  [ main -> org.tasktide.tasktide.client.TaskTideWebApiClient.performClientTask ]: Starting TaskTide-WebApi
SLF4J(W): No SLF4J providers were found.
SLF4J(W): Defaulting to no-operation (NOP) logger implementation
SLF4J(W): See https://www.slf4j.org/codes.html#noProviders for further details.
2026-06-27 20:39:26 INFO  [ main -> org.tasktide.api.TaskTideWebApi.addSecureConnector ]: No PEM file provided, skipping SSL config
2026-06-27 20:39:26 INFO  [ main -> org.tasktide.api.TaskTideWebApi.startWebServer ]: SSL not configured
Jun 27, 2026 8:39:26 PM org.glassfish.jersey.internal.Errors logErrors
WARNING: The following warnings have been detected: WARNING: A HTTP GET method, public jakarta.ws.rs.core.Response org.tasktide.api.resources.manager.rest.ManagerResource.exportTasks(org.tasktide.core.manager.command.commands.ExportCommand,jakarta.ws.rs.core.HttpHeaders,jakarta.ws.rs.core.UriInfo,jakarta.ws.rs.core.SecurityContext), should not consume any entity.

2026-06-27 20:39:26 INFO  [ main -> org.tasktide.tasktide.client.TaskTideWebApiClient.performClientTask ]: Server listening on 'tasktide_webapi:80//tasktide' spinup state is 'STARTED'
2026-06-27 20:39:53 INFO  [ qtp886292426-74 -> org.tasktide.api.resources.services.rest.StepRestResource.<init> ]: Step resource created
2026-06-27 20:39:53 INFO  [ qtp886292426-74 -> org.tasktide.api.auth.AuthenicationFilter.filter ]: Processing incoming request
2026-06-27 20:39:53 WARN  [ qtp886292426-74 -> org.tasktide.api.auth.AuthenicationFilter.filter ]: Unable to detect authentication scheme, defaulting to none
2026-06-27 20:39:53 INFO  [ qtp886292426-74 -> org.tasktide.api.auth.AuthenicationFilter.filter ]: Bypassing authentication
2026-06-27 20:39:53 INFO  [ qtp886292426-74 -> org.tasktide.api.resources.services.rest.StepRestResource.readStep ]: Get Step request recieved from 'null', Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36':
'

'''


##################################################
##################################################
## 
## 3). Deploy Service
## 
##################################################
##################################################


# Run service
docker compose --file tasktide-deployment.yml up -d

'''

[+] up 9/9
 ✔ Network tasktide-service_tasktide_web        Created                                                                                                                                                0.2s
 ✔ Network tasktide-service_nginx_alb           Created                                                                                                                                                0.1s
 ✔ Network tasktide-service_dbNet               Created                                                                                                                                                0.1s
 ✔ Container couchdb                            Created                                                                                                                                                0.2s
 ✔ Container tasktide-service-initCouchDB-1     Created                                                                                                                                                0.2s
 ✔ Container tasktide-service-tasktide_webapi-3 Created                                                                                                                                                0.2s
 ✔ Container tasktide-service-tasktide_webapi-1 Created                                                                                                                                                0.2s
 ✔ Container tasktide-service-tasktide_webapi-2 Created                                                                                                                                                0.2s
 ✔ Container tasktide_app                       Created                                                                                                                                                0.2s


'''


# Register a task
curl -v -H "Content-Type: application/json" \
  -X POST http://localhost/services/workitem/create \
  -d '{
    "Task Name": "Seq10",
    "Task Script": "seq 10",
    "Step Name": "SeqTasks"
  }' \
| jq


'''

{
  "DoneDate": 0,
  "Id": "WorkItem-17ff1e88-54d7-47d7-a8a3-e4ede814b84e",
  "ItemName": "Seq10",
  "ItemState": "TODO",
  "ItemType": "SINGLE",
  "Job Environment Id": "",
  "LockDate": 0,
  "StepId": "Step-03083c32-2ed1-4a6e-89d5-4ab311ca3db5",
  "StepName": "SeqTasks",
  "TaskCount": 1,
  "TaskDone": 0,
  "Workload": {
    "TaskMap": {
      "Seq10": {
        "Job Environment Id": "",
        "Task": "seq 10",
        "Task Log": {
          "CPU Duration": 0,
          "End Time": 0,
          "Exit Code": -1,
          "Process Id": 0,
          "Process Log": {
            "Stderr": [
              ""
            ],
            "Stdout": [
              ""
            ],
            "id": "ProcessLog-100e2acb-648a-4b11-a7c6-daced555b49b"
          },
          "Start Time": 0,
          "Thread Name": "NA",
          "id": "TaskLog-063378de-81bd-46a2-aa06-bdaf6cc4d11e"
        },
        "Task Name": "Seq10",
        "Task State": "PENDING",
        "Work Item Id": "WorkItem-17ff1e88-54d7-47d7-a8a3-e4ede814b84e",
        "annotations": {
          "Annotation Id": "CustomAnnotation-25fb5b42-845f-496b-b968-93f364fe5466",
          "Annotation Map": {}
        },
        "id": "ItemTask-726fccf4-0844-4a2e-a0f1-8f6f9b83746a"
      }
    },
    "WorkloadType": "SINGLE",
    "earliestDone": -1,
    "id": "Workload-ac16eb70-23b3-4d23-8253-2e693780acec",
    "latestDone": 0,
    "workloadSize": 1
  },
  "annotations": {
    "Annotation Id": "CustomAnnotation-039dd1d7-4dc2-4fc9-82e1-ce1dd5b6144c",
    "Annotation Map": {}
  },
  "collection": "SeqTasks",
  "workloadSize": 1
}

'''



# Clear services, and re-deploy
docker compose --file tasktide-deployment.yml down --remove-orphans
docker compose --file tasktide-deployment.yml up -d

curl -v \
  -H "Content-Type: application/json" \
  -X GET 'http://localhost/services/workitem/get?id=WorkItem-17ff1e88-54d7-47d7-a8a3-e4ede814b84e' \
| jq

'''

{
  "DoneDate": 0,
  "Id": "WorkItem-17ff1e88-54d7-47d7-a8a3-e4ede814b84e",
  "ItemName": "Seq10",
  "ItemState": "TODO",
  "ItemType": "SINGLE",
  "Job Environment Id": "",
  "LockDate": 0,
  "StepId": "Step-03083c32-2ed1-4a6e-89d5-4ab311ca3db5",
  "StepName": "SeqTasks",
  "TaskCount": 1,
  "TaskDone": 0,
  "Workload": {
    "TaskMap": {
      "Seq10": {
        "Job Environment Id": "",
        "Task": "seq 10",
        "Task Log": {
          "CPU Duration": 0,
          "End Time": 0,
          "Exit Code": -1,
          "Process Id": 0,
          "Process Log": {
            "Stderr": [
              ""
            ],
            "Stdout": [
              ""
            ],
            "id": "ProcessLog-100e2acb-648a-4b11-a7c6-daced555b49b"
          },
          "Start Time": 0,
          "Thread Name": "NA",
          "id": "TaskLog-063378de-81bd-46a2-aa06-bdaf6cc4d11e"
        },
        "Task Name": "Seq10",
        "Task State": "PENDING",
        "Work Item Id": "WorkItem-17ff1e88-54d7-47d7-a8a3-e4ede814b84e",
        "annotations": {
          "Annotation Id": "CustomAnnotation-25fb5b42-845f-496b-b968-93f364fe5466",
          "Annotation Map": {}
        },
        "id": "ItemTask-726fccf4-0844-4a2e-a0f1-8f6f9b83746a"
      }
    },
    "WorkloadType": "SINGLE",
    "earliestDone": -1,
    "id": "Workload-ac16eb70-23b3-4d23-8253-2e693780acec",
    "latestDone": 0,
    "workloadSize": 1
  },
  "annotations": {
    "Annotation Id": "CustomAnnotation-039dd1d7-4dc2-4fc9-82e1-ce1dd5b6144c",
    "Annotation Map": {}
  },
  "collection": "SeqTasks",
  "workloadSize": 1
}

'''



##################################################################################
##################################################################################
##
## 4). Use Case Deployment Scenarios
##
## - TaskTide ships as an inheritable base image
## - TaskTide ships separate image with apptainer to fetch & run app/DAL images
##
##################################################################################
##################################################################################


##############################################
##############################################
## 
## a). Run Application within Apptainer
## 
##############################################
##############################################


# Install apptainer 
docker run -it --privileged --rm eclipse-temurin:17-jre bash


```{bash}

# Install apptainer
apt update -y && apt upgrade -y
apt-get install -y apptainer


# Check with java image
root@480e82f83b9d:/# apptainer run docker://eclipse-temurin:17-jre bash

'''
INFO:    Converting OCI blobs to SIF format
INFO:    Starting build...
INFO:    Fetching OCI image...
39.6MiB / 39.6MiB [ ] 100 % 2.3 MiB/s 0s
45.4MiB / 45.4MiB [ ] 100 % 2.3 MiB/s 0s
19.2MiB / 19.2MiB [ ] 100 % 2.3 MiB/s 0s
INFO:    Extracting OCI image...
INFO:    Inserting Apptainer configuration...
INFO:    Creating SIF file...

Apptainer> java --version
openjdk 17.0.19 2026-04-21
OpenJDK Runtime Environment Temurin-17.0.19+10 (build 17.0.19+10)
OpenJDK 64-Bit Server VM Temurin-17.0.19+10 (build 17.0.19+10, mixed mode, sharing)
Apptainer> ^C
Apptainer> 
exit
'''


# Check with mario image
apptainer run docker://bkenna/mario-agent \
    --mode train \
    --world 1 \
    --level 1 \
    --timesteps 6000

'''
INFO:    Converting OCI blobs to SIF format
INFO:    Starting build...
INFO:    Fetching OCI image...
1.2MiB / 1.2MiB     [ ] 100 % 5.3 MiB/s 0s
13.2MiB / 13.2MiB   [ ] 100 % 5.3 MiB/s 0s
28.4MiB / 28.4MiB   [ ] 100 % 5.3 MiB/s 0s
13.3MiB / 13.3MiB   [ ] 100 % 5.3 MiB/s 0s
365.9MiB / 365.9MiB [ ] 100 % 5.3 MiB/s 0s
7.0MiB / 7.0MiB     [ ] 100 % 5.3 MiB/s 0s
13.3MiB / 13.3MiB   [ ]   100 % 5.3 MiB/s 0s
5.4GiB / 5.4GiB     [ ] 100 % 5.3 MiB/s 0s
INFO:    Extracting OCI image...
INFO:    Inserting Apptainer configuration...
INFO:    Creating SIF file...
[  ]

INFO:    squashfuse not found, will not be able to mount SIF or other squashfs files
INFO:    fuse2fs not found, will not be able to mount EXT3 filesystems
INFO:    gocryptfs not found, will not be able to use gocryptfs
INFO:    Converting SIF file to temporary sandbox...
FATAL:   while extracting /root/.apptainer/cache/oci-tmp/bdce71a04d3bd65e38b3a5d23907b6917829831f7b119a45b310f3e47751660c: root filesystem extraction failed: extract command failed: INFO   : A system administrator may need to enable user namespaces, install
INFO   :   apptainer-suid, or compile with ./mconfig --with-suid
ERROR  : Failed to create user namespace: not allowed to create user namespace

'''

```


# Install apptainer 
docker container run --rm -it --privileged tasktide bash

```{bash}

# Post above installation: Run apptainer in wwritable directory
mkdir -p /tmp/mario && cd /tmp/mario
apptainer run docker://bkenna/mario-agent \
    train \
    --world 1 \
    --level 1 \
    --timesteps 6000


''' ---> Results are visible, volume mount only necessary on hosting docker container

INFO:    Using cached SIF image
/bin/bash: warning: setlocale: LC_ALL: cannot change locale (en_US.UTF-8): No such file or directory
2026-07-01 11:42:20,330 [INFO] Starting training on World 1 Level 1 for 6000 timesteps.
2026-07-01 11:42:20,330 [INFO] Creating environment: SuperMarioBros-1-1-v0
Using cpu device
Wrapping the env in a VecTransposeImage.

-----------------------------
| time/              |      |
|    fps             | 102  |
|    iterations      | 1    |
|    time_elapsed    | 19   |
|    total_timesteps | 2048 |
-----------------------------

-----------------------------------------
| time/                   |             |
|    fps                  | 73          |
|    iterations           | 2           |
|    time_elapsed         | 55          |
|    total_timesteps      | 4096        |
| train/                  |             |
|    approx_kl            | 0.033107623 |
|    clip_fraction        | 0.317       |
|    clip_range           | 0.2         |
|    entropy_loss         | -1.92       |
|    explained_variance   | 0.000667    |
|    learning_rate        | 0.0003      |
|    loss                 | 532         |
|    n_updates            | 10          |
|    policy_gradient_loss | 0.0151      |
|    value_loss           | 1.54e+03    |
-----------------------------------------

----------------------------------------
| time/                   |            |
|    fps                  | 65         |
|    iterations           | 3          |
|    time_elapsed         | 93         |
|    total_timesteps      | 6144       |
| train/                  |            |
|    approx_kl            | 0.07366551 |
|    clip_fraction        | 0.387      |
|    clip_range           | 0.2        |
|    entropy_loss         | -1.85      |
|    explained_variance   | 0.593      |
|    learning_rate        | 0.0003     |
|    loss                 | 458        |
|    n_updates            | 20         |
|    policy_gradient_loss | 0.0395     |
|    value_loss           | 874        |
----------------------------------------
2026-07-01 11:44:13,837 [INFO] Training complete. Model saved to mario_1_1_ppo.zip

mario_1_1_ppo.zip  training.log

'''
```

# Package to docker hub
docker build -t tasktide:apptainer -f tasktide.Dockerfile .
docker tag tasktide:apptainer bkenna/tasktide:apptainer
docker push bkenna/tasktide:apptainer



# Package to docker hub
docker build -t mario-agent -f mario-agent.Dockerfile .
docker tag mario-agent:latest bkenna/mario-agent:latest
docker push bkenna/mario-agent:latest



##############################################
##############################################
## 
## b). Deploy TaskTide & Enqueue Workload
## 
##############################################
##############################################


# 
docker compose --file tasktide-deployment.yml up -d

'''
[+] up 8/8
 ✔ Network tasktide-service_dbNet               Created                                                                                                                                                0.1s
 ✔ Network tasktide-service_tasktide_web        Created                                                                                                                                                0.0s
 ✔ Container couchdb                            Created                                                                                                                                                0.1s
 ✔ Container tasktide-service-initCouchDB-1     Created                                                                                                                                                0.1s
 ✔ Container tasktide-service-tasktide_webapi-3 Created                                                                                                                                                0.1s
 ✔ Container tasktide-service-tasktide_webapi-1 Created                                                                                                                                                0.1s
 ✔ Container tasktide-service-tasktide_webapi-2 Created                                                                                                                                                0.1s
 ✔ Container tasktide_app                       Created                                                                                                                                                0.1s

'''


# Enqueue workload
for world in {1..3}
do
  for level in in {1..3}
  do
      taskScript="apptainer run docker://bkenna/mario-agent train --world $world --level $level --timesteps 6000"
      taskLabel="Mario-World${world}-Level${level}"
      curl -H "Content-Type: application/json" \
        -X POST http://localhost/services/workitem/create \
        -d '{
          "Task Name": '"$taskLabel"',
          "Task Script": '"$taskScript"',
          "Step Name": "Mario-Training"
        }' \
      | jq ".Id"
  done
done



# Run engine
$replicas=1
for ( $iter = 0; $iter -lt $replicas; $iter++ ) {
  docker rm -f tasktide_engine-$iter
  docker container run -d `
    --name tasktide_engine-$iter `
    --network tasktide-service_tasktide_web `
    --network tasktide-service_dbNet `
    -v "./microprofile-config.properties:/opt/tasktide/config/META-INF/microprofile-config.properties" `
    -v "./tasktide_data/:/home/tasktide/data/" `
    tasktide:latest `
      engine --step-name "SeqTasks" --worker-pool-size "2" --item-task-threads "2" --worker-window-size "2" --stream-directory "/home/tasktide/data"
}




##################################################################################
##################################################################################
## 
## Troubleshooting Notes
## 
##################################################################################
##################################################################################


# Build container
docker build -t mario-agent -f mario-agent.Dockerfile .
docker tag mario-agent:latest bkenna/mario-agent:latest
docker push bkenna/mario-agent:latest 


# Build with apptainer
docker build -t tasktide:latest -f tasktide.Dockerfile .
docker tag tasktide:latest bkenna/tasktide:latest
docker push bkenna/tasktide:latest



# Build with apptainer
docker build -t tasktide:apptainer -f tasktide.Dockerfile .
docker tag tasktide:apptainer bkenna/tasktide:apptainer
docker push bkenna/tasktide:apptainer



# Engine overwritting with 
$iter="1"
docker rm -f tasktide_engine-$iter

docker container run --rm `
  --name tasktide_engine-$iter `
  --network tasktide-service_tasktide_web `
  --network tasktide-service_dbNet `
  -v "./microprofile-config.properties:/opt/tasktide/config/META-INF/microprofile-config.properties" `
  tasktide:latest engine --step-name "Mario-Training" --worker-pool-size "2" --item-task-threads "2" --worker-window-size "2"


# Clear with logs
docker compose --file tasktide-deployment.yml down --remove-orphans

docker compose --file tasktide-deployment.yml up -d



# Register a task
curl -v -H "Content-Type: application/json" \
  -X POST http://localhost/services/workitem/create \
  -d '{
    "Task Name": "10GB File Generation",
    "Task Script": "openssl rand 10G",
    "Step Name": "FileGeneration"
  }' \
| jq



# WorkItem-58576d3c-5efb-4f7e-965e-3d933b46e475, ItemTask-223d1591-284b-41b0-a32d-aa7f145e4efc
docker container run --rm `
  --network tasktide-service_tasktide_web `
  --network tasktide-service_dbNet `
  -v "./microprofile-config.properties:/opt/tasktide/config/META-INF/microprofile-config.properties" `
  -v "./tasktide_data/:/home/tasktide/" `
  tasktide:latest engine --step-name "FileGeneration" --worker-pool-size "2" --item-task-threads "2" --worker-window-size "2" --stream-directory "/home/tasktide/"

''' --> Mild time overhead for large log files, but no issue redirecting and logging

2026-07-01 15:01:21 INFO  [ main -> org.tasktide.engine.worker.TaskTideEngineWorker.processSampling ]: Waiting on task: 'Task-0'
2026-07-01 15:03:43 DEBUG [ pool-3-thread-1 -> org.tasktide.engine.executor.ProcessExecutor.execute ]: Execution complete for task:     openssl rand 10G
2026-07-01 15:03:43 DEBUG [ pool-3-thread-1 -> org.tasktide.engine.executor.ProcessExecutor.execute ]: Building ProcessLog for task:    openssl rand 10G
2026-07-01 15:10:24 DEBUG [ pool-3-thread-1 -> org.tasktide.engine.executor.ProcessExecutor.execute ]: Displaying TaskLogging:
{
    "CPU Duration": 0,
    "End Time": 1782918624405,
    "Exit Code": 0,
    "Process Id": 108,
    "Process Log": {
        "Stderr": [
            "Std/Stderr logs saved to:\t'/home/tasktide/tasktide-process-executor-streams/ProcessExecutor-8ddd91ab-fe24-4dbb-ac71-7c4a57f3c87d/logs.zip'"
        ],
        "Stdout": [
            "Std/Stderr logs saved to:\t'/home/tasktide/tasktide-process-executor-streams/ProcessExecutor-8ddd91ab-fe24-4dbb-ac71-7c4a57f3c87d/logs.zip'"
        ],
        "id": "ProcessLog-794d9e9b-ef75-4351-a3cb-002706136263"
    },
    "Start Time": 1782918073556,
    "Thread Name": "pool-3-thread-1",
    "id": "TaskLogging-e549d6fa-9cd7-4ebc-aff0-690555217b77"
}
'''