# Register a TaskTide Use Case

Thank you for contributing a TaskTide use case.

Please complete the sections below so reviewers can understand, validate, and register the use case.

## 1). Use Case

**Name:**

<!-- Name of the use-case directory, e.g. MyUseCase -->

**Short description:**

<!-- What does this use case demonstrate? -->

**Category:**

<!-- e.g. application, workload, integration, environment, experiment, research, real-world usage -->

---

## 2). What does this demonstrate?

<!--
Briefly describe:
- What the use case does
- What problem or workflow it represents
- How TaskTide is being used
-->

---

## 3). Implementation

**Use-case directory:**

```text
<!-- e.g. MyUseCase/ -->
```

**TaskTide components/features used:**

<!-- List the relevant TaskTide functionality used by this example. -->

---

## 4). Evaluation

**How is the use case tested?**

<!--
Explain briefly what test.sh does and what constitutes success.
-->

**Local test completed?**

* [ ] `docker build` succeeds
* [ ] `test.sh` passes locally
* [ ] Supporting services have been tested locally, if required

---

## 4). Dependencies

**Does this use case require additional services or infrastructure?**

* [ ] No
* [ ] Yes — described below

<!--
If yes, describe databases, message queues, external services,
additional containers, credentials/configuration, etc.
-->

---

## 5). Configuration

<!--
List any environment variables, secrets, configuration files,
API keys, credentials, or other setup required.

Do not include actual secrets in this Pull Request.
-->

---

## 6). Review Notes

<!--
Anything reviewers should know?

Examples:
- Unusual implementation details
- Known limitations
- Expected test duration
- External dependencies
- Reasons for a particular design
-->

---

## 7). Checklist

* [ ] The use case has its own directory.
* [ ] `README.md` is present.
* [ ] `Dockerfile` is present.
* [ ] `test.sh` is present beside the `Dockerfile`.
* [ ] `test.sh` contains `set -ex`.
* [ ] `test.sh` exits `0` on success and non-zero on failure.
* [ ] The Docker image builds successfully.
* [ ] The use case has been tested locally where possible.
* [ ] Required dependencies and supporting services are documented.
* [ ] No secrets or credentials have been committed.
* [ ] This Pull Request contains only changes relevant to this use case.

---

## 8). Registration

By submitting this Pull Request, I understand that, if accepted and merged, this use case will become part of the TaskTide use-case collection and may be registered as a TaskTide use-case datapoint.
