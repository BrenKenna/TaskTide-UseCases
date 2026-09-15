# Contributing to TaskTide Use Cases

Thank you for contributing to the TaskTide use-case collection.

This repository collects examples of TaskTide being used in the wild to provide a collaborative space to share, build, and evaluate real-world use cases with each other.

For TaskTide itself, see [tasktide.org](https://tasktide.org/) and [github.tasktide.org](https://github.tasktide.org/)

---

## 1). Contribution process

Contributions are made through a GitHub Pull Request - [see the following template](.github/pull_request_template.md)

The expected process is:

```text
Create use case
      ↓
Open Pull Request
      ↓
Step 0 — Validate
      ↓
Step 1 — Build container
      ↓
Step 2 — Run test.sh
      ↓
Review
      ↓
Merge
      ↓
Register as a TaskTide use case
```

The automated checks provide the common evaluation interface. The implementation of the use case remains the contributor's responsibility.

---

## 2). Use case repository structure

Each use case should have its own directory.

At minimum:

```text
MyUseCase/
├── README.md
├── Dockerfile
└── test.sh
```

You are free to add any additional files or directories required by the use case.

For example:

```text
MyUseCase/
├── README.md
├── Dockerfile
├── test.sh
├── src/
├── scripts/
├── config/
└── ...
```

### 3). Use case repository documentation

The README should explain what the use case demonstrates.

Where relevant, include:

- What the use case does
- How TaskTide is being used
- How to run or understand the example
- Required dependencies
- Required configuration
- External services
- Any limitations or unusual behaviour

The README is primarily for people.


### 4). Packaging use cases

For simplifying reproducibility we highly recommend that projects containerize their use case software. The Dockerfile defines the environment used to build and run the use case.

The evaluation workflow builds the image from the use-case directory.

Conceptually:

```bash
docker build -t my-use-case ./MyUseCase
```

The container should include everything required to execute the use case and its test.

### test.sh

`test.sh` is the common evaluation interface.

It must:

- Be named exactly `test.sh`
- Be beside the Dockerfile
- Contain `set -ex`
- Exit with `0` when the use case succeeds
- Exit non-zero when the use case fails

For example:

```bash
#!/bin/bash
set -ex

./run.sh
./verify.sh
```

There is deliberately no required testing framework.

After `set -ex`, the contents of `test.sh` are up to you.

---

## 5). Automated Evaluation

The GitHub Actions workflow evaluates a submitted use case in three stages.

### Step 0 — Validate

The selected use-case directory is checked for the required structure.

At minimum, the following must be present:

```text
README.md
Dockerfile
test.sh
```

The validation also checks the required `test.sh` contract.

A submission should not proceed to the build stage if the basic structure is invalid.

### Step 1 — Build

The Dockerfile is used to build the use-case image.

Conceptually:

```bash
docker build -t <image> <use-case-directory>
```

### Step 2 — Test

The resulting image is run and `test.sh` is executed.

The test must exit with status `0`.

A non-zero exit status causes the evaluation to fail.

---

## 6). Supporting services

Use cases requiring additional services/containers should have their deployment documented

Examples include:

- Databases
- Message queues
- Other application containers
- External services
- Supporting infrastructure

If the shared evaluation workflow needs to provide additional infrastructure, explain the requirement in the Pull Request rather than assuming it is available.

---

## 7). Test locally

Before opening a Pull Request, test the use case locally where possible.

For example:

```bash
docker build -t my-use-case ./MyUseCase
```

Then:

```bash
docker run --rm my-use-case ./test.sh
```

If supporting services are required, reproduce those locally as well.

A passing local test does not replace the GitHub Actions evaluation, but it makes failures easier to diagnose.

---

## 8). Opening a pull request

When submitting a new use case, the Pull Request should explain:

- What the use case demonstrates
- How TaskTide is being used
- How the use case is evaluated
- Any additional services or dependencies
- Anything unusual that reviewers should know

Keep unrelated changes out of the Pull Request where possible.

A typical new contribution should primarily add a new directory:

```text
+ MyUseCase/
```

---

## 9). Review and registration

Passing automated evaluation does not automatically mean that a use case will be accepted.

The Pull Request is still subject to review.

Once accepted and merged, the use case becomes part of the collection and can be registered as a TaskTide use-case datapoint.

The registration exists to make the collection discoverable to the wider TaskTide ecosystem. Contributors should not need to maintain a separate external registration process.

---

## 10). Existing use cases

The repository contains reference use cases which demonstrate the expected structure and evaluation model.

See:

- [`FunctionRunner/`](./FunctionRunner/)
- [`ImageAnalysis/`](./ImageAnalysis/)
- [`Mario-AI-Agent/`](./Mario-AI-Agent/)
- [`BioinformaticWorkflows/`](./Bioinformatic-Workflows/)

These are examples, not strict implementation templates.

---

## 11). Use case lifecycle

Use cases have a simple lifecycle.

### i). Core

Core use cases are maintained as reference examples and are exempt from the normal community archival process.

### ii). Community

Community use cases are contributed examples which are part of the active collection.

### iii). Archived

A community use case that has been inactive for more than one year may be moved to the archive.

Archiving is not a judgement on the quality of the use case.

Archived use cases remain available as part of the historical community collection, but are no longer actively assessed.

An archived use case can be brought back into the active collection through a Pull Request.

---

## 12). Changing the shared infrastructure

Contributors should normally be able to add a use case without changing the shared GitHub Actions infrastructure.

If your use case requires a change to the evaluation workflow or supporting scripts, explain why in the Pull Request.

Changes to shared infrastructure should generally solve a problem that is useful beyond a single use case.

---

## 13). In scope entriess

This repository is for things that demonstrate **TaskTide being used**.

Good contributions include:

- New applications
- New workloads
- New integrations
- New environments
- Experiments
- Demonstrations
- Research examples
- Real-world usage

The implementation can be simple or complex.

The important thing is that it provides a useful example of TaskTide in use.

---

## 14). Out of scope

This repository is not the place for core TaskTide development.

For example, changes to:

- The TaskTide platform
- Core TaskTide functionality
- TaskTide APIs
- Core TaskTide documentation
- Platform-wide features

should be made through the appropriate TaskTide project resources.

A useful distinction is:

> **This repository shows what can be done with TaskTide.**

> **The main TaskTide project builds TaskTide itself.**
