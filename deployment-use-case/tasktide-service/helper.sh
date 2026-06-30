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