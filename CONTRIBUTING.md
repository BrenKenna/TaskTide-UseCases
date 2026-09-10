# Contributing to TaskTide Use Cases

Thank you for contributing to the TaskTide use-case collection.

This repository is not the core TaskTide project. It is a collection of examples, experiments, integrations, and real-world applications demonstrating how TaskTide can be used.

The goal is simple:

> **Show TaskTide being used in the wild.**

The TaskTide project itself lives at [tasktide.org](https://tasktide.org/). This repository provides a common way to package and evaluate examples of TaskTide being used across different applications, environments, and workloads.

---

## What Counts as a Use Case?

A use case can be almost anything that demonstrates TaskTide solving a real problem.

For example:

- A scientific workload
- A data-processing pipeline
- An AI or machine-learning workflow
- An HPC workload
- A distributed application
- An integration with another system
- A workflow using external services
- An experiment exploring a particular TaskTide capability
- A small example demonstrating a specific feature
- A larger application composed of multiple tasks

The implementation language, framework, dependencies, and internal structure are up to you.

The only requirement is that the use case can be packaged and evaluated through the standard interface described below.

---

## The Use Case Contract

Each use case lives in its own directory.

At minimum, it must contain:

```text
MyUseCase/
├── README.md
├── Dockerfile
└── test.sh
```