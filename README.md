# TaskTide Use Cases

A collection of containerized AI and software use cases designed to be **built, executed, and evaluated consistently through GitHub Actions**.

## What is TaskTide?

TaskTide provides a common structure for packaging practical use cases into reproducible containers.

Each use case defines:

1. **A container environment** — described by its `Dockerfile`.
2. **An executable use case** — whatever application, agent, model, or workflow the contributor provides.
3. **A test** — defined by `test.sh`, which verifies that the use case works as expected.

The goal is simple:

> **Make different use cases easy to contribute, build, run, and evaluate using the same interface.**

---

## Use Cases

### Julia Function Runner

A containerized environment for executing Julia functions.

[`FunctionRunner/`](./FunctionRunner/)

### Image Analysis

An image-analysis use case demonstrating the TaskTide execution model.

[`ImageAnalysis/`](./ImageAnalysis/)

### Mario AI Agent

An AI agent capable of interacting with the Mario environment.

[`Mario-AI-Agent/`](./Mario-AI-Agent/)

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