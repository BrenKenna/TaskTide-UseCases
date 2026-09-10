# TaskTide Deployment Use Case: Mario AI Agent

This repository contains the standalone deployment package for the **Mario AI Agent**, a reinforcement learning application designed to operate as an external task workload managed by the TaskTide workflow orchestration engine.

The agent demonstrates TaskTide’s ability to coordinate, introspect, and manage the lifecycle of containerized and arbitrary Python execution environments at runtime.

---

## 🏗️ Architecture Integration
This application executes a Reinforcement Learning agent playing Super Mario Bros inside an isolated container environment. **TaskTide** registers this container as a stateful task execution block, enabling real-time process monitoring, metrics tracking, and resource lifecycle controls without relying on heavy cloud daemons.

* **Core System:** Built on top of the [TaskTide Core Orchestration Engine](https://tasktide.org).
* **Documentation:** Detailed specifications are available in the [TaskTide Use Cases Documentation](https://docs.tasktide.org/).

---

## 🚀 Installation & Prerequisites

### Option A: Local Python Environment
Ensure you have Python 3.10+ installed.

1. Install system-level dependencies required for OpenAI Gym/Gymnasium environments:
   ```bash
   # Ubuntu/Debian
   sudo apt-get update && sudo apt-get install -y swig python3-dev
   ```
2. Install the package locally:
   ```bash
   pip install .
   ```

### Option B: Docker Containerization
A pre-built image is available on DockerHub. You can pull or build it directly:
```bash
# Pull from DockerHub
docker pull bkenna/mario-agent:latest

# Or build from the local Dockerfile
docker build -t bkenna/mario-agent -f mario-agent.Dockerfile .
```

---

## 💻 Running the Program

### Standard Local Execution
Run the Mario AI training execution pipeline directly through python:
```bash
python mario-agent \
    --mode train \
    --world 1 \
    --level 1 \
    --timesteps 6000
```

### Execution via TaskTide Orchestration
To invoke this workflow via the TaskTide CLI layer as an isolated task. Example requires the [TaskTide-REST API](https://docs.tasktide.org/tasktide/tasktide/#e-web-api).

Register ***Mario Bros AI Agent*** workflow with a ***TrainMarioBros*** step to train an agent on a given level, and a ***PlayMarioBros*** step to enact that model in production.
```bash
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
```


```bash
# Enqueue workload: swap out hostname for Tasktide-REST API
stepName="TrainMarioBros"
for world in {1..4}; do
    for level in {1..8}; do
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
```

Launches the TaskTide-Engine in Workflow-Service mode targeting tasks from previously created steps. The execution environment for these tasks is provided by an apptainer image of the [Mario AI Agent](https://hub.docker.com/repository/docker/bkenna/mario-agent/general). Results from these tasks will be written within that apptainer which passes through the hosting container onto provided host directory.

```bash
docker container run --rm \
  --cap-add SYS_ADMIN \
  --security-opt no-new-privileges:true \
  --device /dev/fuse \
  -v ./microprofile-config.properties:/opt/tasktide/config/META-INF/microprofile-config.properties:ro \
  -v ../sif/mario-agent.sif:/opt/mario-agent/mario-agent.sif:ro \
  -v ./mario-data/:/data/mario:rw \
  -v ./tasktide_data:/opt/tasktide/tasktide-process-executor-streams:rw \
  bkenna/tasktide:apptainer \
    engine \
        --repository-type "nosql" \
        --target "WORKITEM" \
        --step-name "TrainMarioBros,PlayMarioBros" \
        --execution-policy "service" \
        --worker-pool-size "2" \
        --worker-window-size "4" \
        --item-task-threads "2" \
        --result-set-size "2" \
        --acquisition-mode "SCANNER" \
        --strategy-type "ROUND_ROBIN" \

```

---

## 🔗 Resources
* **TaskTide Ecosystem:** [Official Website](https://tasktide.org)
* **Source Code:** [TaskTide Repository](https://github.tasktide.org)
* **Production Build References:** [DockerHub](https://hub.docker.com/repository/docker/bkenna/mario-agent/general)
