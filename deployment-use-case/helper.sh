#!/bin/bash


##################################################
##################################################
## 
## 1). Test Application in Container
## 
##################################################
##################################################

# Start container
docker run -it --rm `
    -v "C:\Users\Bren\Documents\GitHub\TaskTide\tasktide\use-cases\deployment-use-case:/app" `
    -w /app `
    python:3.10 bash


# Prequistes
apt update -y && apt upgrade -y

apt install -y \
    python3-dev build-essential \
    libgl1 libegl1 libgles2 \
    libglu1-mesa mesa-utils libgl1-mesa-dri ffmpeg

pip install "setuptools<65" "wheel<0.38"
pip install --upgrade pip==23.3.2


# Install agent dependancies
pip install -e .


# Train app
mario-agent \
    --mode train \
    --world 1 \
    --level 1 \
    --timesteps 6000

'''

root@9d4ccd887222:/app# mario-agent \
    --mode train \
    --world 1 \
    --level 1 \
    --timesteps 6000
2026-06-26 12:07:12,554 [INFO] Starting training on World 1 Level 1 for 6000 timesteps.
2026-06-26 12:07:12,555 [INFO] Creating environment: SuperMarioBros-1-1-v0
Using cpu device
Wrapping the env in a VecTransposeImage.
-----------------------------
| time/              |      |
|    fps             | 87   |
|    iterations      | 1    |
|    time_elapsed    | 23   |
|    total_timesteps | 2048 |
-----------------------------
----------------------------------------
| time/                   |            |
|    fps                  | 68         |
|    iterations           | 2          |
|    time_elapsed         | 59         |
|    total_timesteps      | 4096       |
| train/                  |            |
|    approx_kl            | 0.02251003 |
|    clip_fraction        | 0.329      |
|    clip_range           | 0.2        |
|    entropy_loss         | -1.92      |
|    explained_variance   | 0.000336   |
|    learning_rate        | 0.0003     |
|    loss                 | 127        |
|    n_updates            | 10         |
|    policy_gradient_loss | 0.0139     |
|    value_loss           | 545        |
----------------------------------------
-----------------------------------------
| time/                   |             |
|    fps                  | 64          |
|    iterations           | 3           |
|    time_elapsed         | 95          |
|    total_timesteps      | 6144        |
| train/                  |             |
|    approx_kl            | 0.019705089 |
|    clip_fraction        | 0.307       |
|    clip_range           | 0.2         |
|    entropy_loss         | -1.88       |
|    explained_variance   | 0.627       |
|    learning_rate        | 0.0003      |
|    loss                 | 235         |
|    n_updates            | 20          |
|    policy_gradient_loss | 0.0132      |
|    value_loss           | 595         |
-----------------------------------------
2026-06-26 12:09:07,300 [INFO] Training complete. Model saved to mario_1_1_ppo.zip

root@9d4ccd887222:/app#

'''

##################################################
##################################################
## 
## 2). Verify Containerized Application
## 
##################################################
##################################################


# Build container
docker build -t mario-agent -f mario-agent.Dockerfile .


# Run container
docker run -it --rm mario-agent train --world 1 --level 1 --timesteps 6000

'''

2026-06-26 13:14:05,191 [INFO] Starting training on World 1 Level 1 for 6000 timesteps.
2026-06-26 13:14:05,192 [INFO] Creating environment: SuperMarioBros-1-1-v0
Using cpu device
Wrapping the env in a VecTransposeImage.
-----------------------------
| time/              |      |
|    fps             | 72   |
|    iterations      | 1    |
|    time_elapsed    | 28   |
|    total_timesteps | 2048 |
-----------------------------
----------------------------------------
| time/                   |            |
|    fps                  | 58         |
|    iterations           | 2          |
|    time_elapsed         | 70         |
|    total_timesteps      | 4096       |
| train/                  |            |
|    approx_kl            | 0.01891379 |
|    clip_fraction        | 0.314      |
|    clip_range           | 0.2        |
|    entropy_loss         | -1.92      |
|    explained_variance   | 0.000154   |
|    learning_rate        | 0.0003     |
|    loss                 | 301        |
|    n_updates            | 10         |
|    policy_gradient_loss | 0.0106     |
|    value_loss           | 953        |
----------------------------------------
-----------------------------------------
| time/                   |             |
|    fps                  | 54          |
|    iterations           | 3           |
|    time_elapsed         | 111         |
|    total_timesteps      | 6144        |
| train/                  |             |
|    approx_kl            | 0.034630843 |
|    clip_fraction        | 0.386       |
|    clip_range           | 0.2         |
|    entropy_loss         | -1.86       |
|    explained_variance   | 0.498       |
|    learning_rate        | 0.0003      |
|    loss                 | 823         |
|    n_updates            | 20          |
|    policy_gradient_loss | 0.0122      |
|    value_loss           | 1.95e+03    |
-----------------------------------------
2026-06-26 13:16:17,984 [INFO] Training complete. Model saved to mario_1_1_ppo.zip

'''



##################################################
##################################################
## 
## 3). Verify Containerized Application
## 
##################################################
##################################################


# 
docker compose --file tasktide-deployment.yml up -d



# Check running apptainer directly: fakeroot does not work
stepName="BusyBoxMessage"
for i in {1..3}
do
    taskLabel="BusyBoxMessage-$i"
    taskScript="apptainer run docker://busybox echo \"Hello from BusyBox-$i\""
    curl -s \
            -H "Content-Type: application/json" \
            -X POST http://localhost/services/workitem/create \
            -d "$(jq -n \
                --arg name "$taskLabel" \
                --arg script "$taskScript" \
                --arg step "$stepName" \
                '{
                    "Task Name": $name,
                    "Task Script": $script,
                    "Step Name": $step
                }')" \
        | jq '.Id'
done


curl http://localhost/services/workitem/get?id=WorkItem-29b2c40b-196f-42f3-a100-bb9a5484a765

''' ---> Running without "privileged: true" causes apptainer to fail with 255 and no visible error message.

{
  "DoneDate": 1783951467114,
  "Id": "WorkItem-0a4e50c2-1082-471d-8537-183c7a8aa978",
  "ItemName": "BusyBoxMessage-2",
  "ItemState": "DONE",
  "ItemType": "SINGLE",
  "Job Environment Id": "JobEnvironment-ffe75a89-952d-4f89-8416-649e402ca709",
  "LockDate": 1783951462733,
  "LockId": "MTc4Mzk1MTQ2MjczMTlkODQ3YzE4LWVjZTUtNDE1Ny05YzIwLWQ5MmU0ODg3OGEzNQ==",
  "StepId": "Step-6247e9fa-df6d-4d7a-adab-74e1bf442d43",
  "StepName": "BusyBoxMessage",
  "TaskCount": 1,
  "TaskDone": 1,
  "Workload": {
    "TaskMap": {
      "BusyBoxMessage-2": {
        "Job Environment Id": "JobEnvironment-ffe75a89-952d-4f89-8416-649e402ca709",
        "Task": "apptainer run docker://busybox echo \"Hello from BusyBox-2\"",
        "Task Log": {
          "CPU Duration": 0,
          "End Time": 1783951467114,
          "Exit Code": 0,
          "Process Id": 121,
          "Process Log": {
            "Stderr": [
              "Hello from BusyBox-2"
            ],
            "Stdout": [
              "Hello from BusyBox-2"
            ],
            "id": "ProcessLog-7e4d701a-5152-4fa4-ab58-177120757193"
          },
          "Start Time": 1783951463903,
          "Thread Name": "pool-3-thread-1",
          "id": "TaskLogging-2a70f824-cb75-4617-93b2-f00435ce4ee2"
        },
        "Task Name": "BusyBoxMessage-2",
        "Task State": "COMPLETE",
        "Work Item Id": "WorkItem-0a4e50c2-1082-471d-8537-183c7a8aa978",
        "annotations": {
          "Annotation Id": "CustomAnnotation-9173e915-efab-4882-9ea7-fd50c72e8be5",
          "Annotation Map": {}
        },
        "id": "ItemTask-2416d2d3-550a-455f-be28-e39d2d1b25e9"
      }
    },
    "WorkloadType": "SINGLE",
    "earliestDone": 1783951467114,
    "id": "Workload-d38dd0c3-4f20-4c0a-a7c7-fac7690766c1",
    "latestDone": 1783951467114,
    "workloadSize": 1
  },
  "annotations": {
    "Annotation Id": "CustomAnnotation-0f99a16c-7b9d-41c3-a569-753460dcc00b",
    "Annotation Map": {}
  },
  "collection": "BusyBoxMessage",
  "workloadSize": 1
}


{
  "DoneDate": 0,
  "Id": "WorkItem-351d3b6c-ab83-473f-a21a-32a318ec4ff1",
  "ItemName": "BusyBoxMessage-3",
  "ItemState": "ERROR",
  "ItemType": "SINGLE",
  "Job Environment Id": "JobEnvironment-ffe75a89-952d-4f89-8416-649e402ca709",
  "LockDate": 1783951957305,
  "LockId": "MTc4Mzk1MTk1NzMwNTZjYTY4NjdiLWNmNmYtNDhiMS1iODhkLWRlNjc0NjI3NWFhMQ==",
  "StepId": "Step-6247e9fa-df6d-4d7a-adab-74e1bf442d43",
  "StepName": "BusyBoxMessage",
  "TaskCount": 1,
  "TaskDone": 0,
  "Workload": {
    "TaskMap": {
      "BusyBoxMessage-3": {
        "Job Environment Id": "JobEnvironment-ffe75a89-952d-4f89-8416-649e402ca709",
        "Task": "apptainer run docker://busybox echo \"Hello from BusyBox-3\"",
        "Task Log": {
          "CPU Duration": 0,
          "End Time": 1783951961422,
          "Exit Code": 255,
          "Process Id": 220,
          "Process Log": {
            "Stderr": [],
            "Stdout": [],
            "id": "ProcessLog-b3414548-f77b-41e3-8f04-6670a9511734"
          },
          "Start Time": 1783951960518,
          "Thread Name": "pool-3-thread-2",
          "id": "TaskLogging-e58d570e-c5be-40be-88ff-999869c5b8a1"
        },
        "Task Name": "BusyBoxMessage-3",
        "Task State": "ERROR",
        "Work Item Id": "WorkItem-351d3b6c-ab83-473f-a21a-32a318ec4ff1",
        "annotations": {
          "Annotation Id": "CustomAnnotation-275ed2b4-4274-4bea-863e-ac847faea54e",
          "Annotation Map": {}
        },
        "id": "ItemTask-e89b8348-7cc7-4f8a-8cc9-cbadbf346d9a"
      }
    },
    "WorkloadType": "SINGLE",
    "earliestDone": -1,
    "id": "Workload-6a3099bd-d628-473d-b7fd-824a812059e1",
    "latestDone": 0,
    "workloadSize": 1
  },
  "annotations": {
    "Annotation Id": "CustomAnnotation-eca18777-bf56-4eeb-b6f5-8dfe616db1de",
    "Annotation Map": {}
  },
  "collection": "BusyBoxMessage",
  "workloadSize": 1
}

'''


# Enqueue workload
stepName="TrainMarioBros"
for world in {1..2}; do
    for level in {1..2}; do
        containerCMD="apptainer run --bind /data/mario:/data --env PYTHONPATH=/opt/mario-agent:\$PYTHONPATH /opt/mario-agent/mario-agent.sif"
        taskScript="$containerCMD train --world $world --level $level --timesteps 6000"
        taskLabel="Mario-World${world}-Level${level}"
        curl -s \
            -H "Content-Type: application/json" \
            -X POST http://localhost/services/workitem/create \
            -d "$(jq -n \
                --arg name "$taskLabel" \
                --arg script "$taskScript" \
                --arg step "$stepName" \
                '{
                    "Task Name": $name,
                    "Task Script": $script,
                    "Step Name": $step
                }')" \
        | jq '.Id'
    done
done



'''

"WorkItem-ab68adac-8b7d-46a3-a128-3b7e10e2b3bd"
"WorkItem-3f97acb3-f809-4d1e-bc18-a92456d9a6b7"
"WorkItem-c3f14f5e-5493-4cb1-97e6-73b400f62b1d"
"WorkItem-a4b804fe-621d-4022-bc16-fc2f5e1e15ff"

'''



# 
docker container logs tasktide-service-mario_trainer-1


'''

2026-07-08 14:31:53 INFO  [ pool-3-thread-1 -> org.tasktide.engine.executor.ItemTaskExecutor.executeTask ]: Executing task on thread 'pool-3-thread-1':
'apptainer run docker://bkenna/mario-agent train --world 1 --level 2 --timesteps 6000'
2026-07-08 14:31:53 INFO  [ pool-3-thread-1 -> org.tasktide.engine.observer.ObserverChain.onTaskProcessing ]: Evaluating Observer 'ItemTaskTimeKeeper' for task 'ItemTask-b1648c6e-6bcf-456f-90ea-8ff36c48307c' with onTaskProcessing result 'true'
2026-07-08 14:31:53 INFO  [ pool-3-thread-1 -> org.tasktide.engine.observer.ObserverChain.onTaskProcessing ]: Evaluating Observer 'ItemTaskStateObserver' for task 'ItemTask-b1648c6e-6bcf-456f-90ea-8ff36c48307c' with onTaskProcessing result 'true'
2026-07-08 14:31:53 DEBUG [ pool-3-thread-1 -> org.tasktide.engine.executor.ProcessExecutor.execute ]: Beginning execution of task:     apptainer run docker://bkenna/mario-agent train --world 1 --level 2 --timesteps 6000
2026-07-08 14:31:59 INFO  [ main -> org.tasktide.engine.worker.TaskTideEngineWorker.processSampling ]: Starting engine 'Worker-1'
2026-07-08 14:31:59 INFO  [ main -> org.tasktide.engine.worker.TaskTideEngineWorker.processSampling ]: Engine 'Worker-1' started, caching for reference
2026-07-08 14:31:59 INFO  [ pool-2-thread-2 -> org.tasktide.engine.worker.TaskTideEngineWorker.sampleAndTraverse ]: Configuring WorkItem-Traverser for processing
2026-07-08 14:31:59 INFO  [ pool-2-thread-2 -> org.tasktide.engine.worker.TaskTideEngineWorker.sampleAndTraverse ]: Fetching workload
2026-07-08 14:31:59 INFO  [ pool-2-thread-2 -> org.tasktide.engine.worker.TaskTideEngineWorker.sampleWorkload ]: Processing retrieved workload of size '0'
2026-07-08 14:32:09 INFO  [ main -> org.tasktide.engine.worker.TaskTideEngineWorker.processSampling ]: Waiting on '2' to process window sizes of '4'
2026-07-08 14:32:09 INFO  [ main -> org.tasktide.engine.worker.TaskTideEngineWorker.processSampling ]: Waiting on task: 'Task-0'



INFO:    Converting OCI blobs to SIF format
INFO:    Starting build...
INFO:    Fetching OCI image...


'''