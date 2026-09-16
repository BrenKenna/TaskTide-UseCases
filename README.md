<p align="center">
  <img src="/repo-assets/logo1.jpg" alt="TaskTide Logo" width="225"/>
</p>

# TaskTide Use Cases

TaskTide is a workflow orchestration engine for [data application deployments](https://tasktide.org). Specifically for workflows where there are a large  collection of variables inputs for each step in a workflow.

Each use case maintains their own code repository separately, and just simply registers a pointer to that here and an additional README.md descriptor with code highlights of how TaskTide was used to orchestrate deployment.

The setup is intentional to try and allow TaskTide userbase to feel more like a community. So issues, discussions about data applications are all welcomed and encourage here.

We just ask our community members to stylize their repository similar to the core TaskTide use cases, and their application abides by common practice (PyPI, R-metaverse, JuliaHub, Conda etc).

We also encourage our members to configure container images of their data application (apptainer/docker) for simple installs and reproducibility.

<br>

<p align="center">
  <img src="/repo-assets/tasktide-non-tech-arch.png" alt="TaskTide non-technical architecture"/>
</p>

<br>

---

## Core Use Cases

### 1). Julia Function Runner

A containerized environment for executing Julia functions.

 > **[FunctionRunner/ ➞](./FunctionRunner/)**

<br>

### 2). Image Analysis

An image-analysis use case demonstrating the TaskTide execution model.

 > **[ImageAnalysis/ ➞](./ImageAnalysis/)**

<br>

### 3). Mario AI Agent

An AI agent capable of interacting with the Mario environment.

 > **[Mario-AI-Agent/ ➞](./Mario-AI-Agent/)**

<br>

### 4). Bioinformatic Workflow

A collection of shell scripts for exome/genome sequence alignment and downstream processing.

 > **[Workflows/ ➞](./BioinformaticWorkflows/)**

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
