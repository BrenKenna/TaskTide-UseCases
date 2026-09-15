<p align="center">
  <img src="/assets/logo1.jpg" alt="TaskTide Logo" width="250"/>
</p>

# TaskTide Use Cases

TaskTide is a workflow orchestration engine for [data application deployments](https://tasktide.org). Specifically for workflows where there are a collection of variables inputs that each step in a workflow.

Each use case maintains their own code repository separately, and just simply registers a pointer to that here and an additional README.md if they so choose. This setup allows TaskTide userbase to feel more like a community, and so issues, discussions about data applications are all welcomed and encourage here. We just ask our community members to stylize their repository similar to the core TaskTide use cases, where their application abides by common practice (PyPI, R-metaverse, JuliaHub, Conda etc).

We also encourage our members to configure container images of their data application (apptainer/docker) for simple installs and reproducibility.

<br>

<p align="center">
  <img src="/assets/tasktide-non-tech-arch.png" alt="TaskTide Architecture" width="650"/>
</p>

<br>

---

## Core Use Cases

### 1). Julia Function Runner

A containerized environment for executing Julia functions.

>    [`FunctionRunner/ ➞`](./FunctionRunner/)


### 2). Image Analysis

An image-analysis use case demonstrating the TaskTide execution model.

>    **[ImageAnalysis/ ➞](./ImageAnalysis/)**


### 3). Mario AI Agent

An AI agent capable of interacting with the Mario environment.

>    **[Mario-AI-Agent/ ➞](./Mario-AI-Agent/)**


### 4). Bioinformatic Workflow

A collection of shell scripts for exome/genome sequence alignment and downstream processing.

>    **[Workflows/ ➞](./Bioinformatic-Workflows/)**

<br>

---

## Use Case Structure

A valid use case follows this basic structure:

```text
MyUseCase/
├── README.md
├── Dockerfile
├── test.sh
└── ...
```