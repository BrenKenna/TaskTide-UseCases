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


# Check applying model
export PYTHONPATH="/opt/mario-agent":$PYTHONPATH
PPO="/data/mario/mario/world-2/level-1/mario_2_1_ppo"

mkdir -p /data/mario/videos && cd /data/mario/videos

mario-agent --mode play --model-path "$PPO" --video





##################################################
##################################################
## 
## 3). Verify Containerized Application
## 
##################################################
##################################################


# Deploy
docker compose --file tasktide-deployment.yml up -d


'''
[+] up 12/12
 ✔ Network tasktide-service_dbNet               Created                                                                                            0.1s
 ✔ Network tasktide-service_tasktide_web        Created                                                                                            0.0s
 ✔ Network tasktide-service_nginx_alb           Created                                                                                            0.0s
 ✔ Container couchdb                            Created                                                                                            0.1s
 ✔ Container tasktide-service-initCouchDB-1     Created                                                                                            0.1s
 ✔ Container tasktide-service-tasktide_webapi-3 Created                                                                                            0.1s
 ✔ Container tasktide-service-tasktide_webapi-1 Created                                                                                            0.1s
 ✔ Container tasktide-service-tasktide_webapi-2 Created                                                                                            0.1s
 ✔ Container tasktide_app                       Created                                                                                            0.2s
 ✔ Container tasktide-service-mario_ai_agent-1   Created                                                                                            0.2s
 ✔ Container tasktide-service-mario_ai_agent-2   Created                                                                                            0.2s
 ✔ Container tasktide-service-mario_ai_agent-3   Created                                                                                            0.2s

'''


# Register workflow
tasktide \
    manager \
        --repository-type "nosql" \
        --nosql-database-type "document" \
        --method "Add" \
        --step-name "TrainMarioBros" \
        --workflow-name "Mario Bros AI Agent" \
        --target "STEP"


tasktide \
    manager \
        --repository-type "nosql" \
        --nosql-database-type "document" \
        --method "Add" \
        --step-name "PlayMarioBros" \
        --workflow-name "Mario Bros AI Agent" \
        --target "STEP"



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

"WorkItem-58b1ead7-357e-4ea6-8854-9a1f6336efff"
"WorkItem-28ddb681-a854-41db-a014-b67ad7fd78be"
"WorkItem-291b8258-f561-4db7-ba93-d9b150dfa563"
"WorkItem-01767c72-58e0-409a-9d97-c014839b98fe"

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