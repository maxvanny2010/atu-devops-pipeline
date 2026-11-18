### Development and Reflection Notes

**Atlantic Technological University (ATU)**

**Programme:** Postgraduate Diploma in Computing in DevOps<br/>
**Module:** DevOps Software Engineering<br/>
**Lecturer:** Maria Griffin<br/>
**Student:** Maksym Voronianskyi<br/>
**Student Number:** L00213593<br/>
**Academic Year:** 2026/2027

**Technologies:** Java 21, Spring Boot, Maven, JUnit, Mockito,<br/>
JaCoCo, Git, GitHub Actions, SonarQube, Trivy, Dependabot, Docker,<br/>
Docker Compose, HTML, CSS, JavaScript, Playwright, GHCR, Kubernetes,<br/>
Kustomize, Terraform, Actuator, Micrometer, Prometheus, Grafana,<br/>
Slack, SBOM, Software Provenance, Image Signing, Semantic Versioning

---

### Purpose

This document records technical decisions, engineering trade-offs,<br/>
implementation outcomes, and verifiable evidence from development of<br/>
the CI/CD pipeline. It provides source material for Task 4:<br/>
Reflective Analysis. Only observed results are represented as<br/>
completed work.

### 1. Initial Architecture Decisions

**Date:** 16 November 2026

#### Project Scope

A small Spring Boot Task Manager is used so that the central<br/>
engineering focus remains automated delivery, security, reliability,<br/>
and observability.

#### CI/CD Platform

GitHub Actions was selected for CI/CD automation. Jenkins was<br/>
considered as an alternative, but GitHub Actions integrates directly<br/>
with the repository without maintaining a dedicated Jenkins server.

#### Testing Strategy

The testing approach combines JUnit, Mockito, Spring Boot<br/>
integration tests, Playwright browser tests, and JaCoCo coverage<br/>
enforcement.

#### Security Strategy

SonarQube and Trivy provide code quality and vulnerability scanning.<br/>
Further controls address workflow permissions, container privileges,<br/>
secrets, dependency maintenance, and software supply chain<br/>
integrity.

#### Deployment Strategy

Docker provides reproducible packaging; Kubernetes provides<br/>
orchestration. Terraform may be used where infrastructure<br/>
provisioning adds clear value.

#### Monitoring Strategy

Spring Boot Actuator, Micrometer, Prometheus, and Grafana form the<br/>
observability design. Slack provides operational notifications.

#### Release Strategy

Conventional Commits and Semantic Versioning support release<br/>
traceability. Versioned artifacts will be linked to immutable<br/>
container digests.

### 2. Implementation Journal

#### Entry 001 - Repository Initialisation

**Date:** 16 November 2026

**Objective:** Establish the Git repository and project structure.

**Completed:**

- Created the local repository and published the initial GitHub
  project.
- Established `master` and feature branch workflow.
- Consolidated initial setup into one commit.
- Established README and ignore rules.

**Decision:**

Keep the primary technical documentation in README and Architecture.<br/>
Maintain separate Reflection Notes to support Task 4.

**Outcome:** Repository structure established for incremental<br/>
development.

#### Entry 002 - Task Manager REST API

**Date:** 17 November 2026

**Implemented:** Spring Boot 4.1.2 CRUD API, H2, validation, and<br/>
HTTP 400/404.

**Engineering work:**

- Corrected the Spring Initializr parent version to `4.1.2`.
- Used an alternative local Maven repository to avoid a cache lock.
- Corrected JSON escaping in API integration tests.
- Updated H2, json-smart, and ASM based on resolved dependency
  versions.

| Verification              | Result        |
|---------------------------|---------------|
| Maven build               | ![PASS][pass] |
| Nine automated tests      | ![PASS][pass] |
| Zero test failures/errors | ![PASS][pass] |

#### Entry 003 - JaCoCo Code Coverage

**Date:** 17 November 2026

JaCoCo 0.8.16 was integrated into Maven verification. Nine automated<br/>
tests passed with 88% instruction coverage. The 80% Quality Gate<br/>
passed.

| Verification     | Result        |
|------------------|---------------|
| Nine tests       | ![PASS][pass] |
| Coverage: 88%    | ![PASS][pass] |
| Minimum 80% gate | ![PASS][pass] |

#### Entry 004 - GitHub Actions CI

**Date:** 17 November 2026

Created the Java 21 Maven CI workflow with automated testing,<br/>
coverage, and test report artifact uploads. Feature-branch triggers<br/>
were configured.

| Verification                     | Result        |
|----------------------------------|---------------|
| Local actionlint                 | ![PASS][pass] |
| GitHub Actions run `44083764858` | ![PASS][pass] |
| Test report artifacts            | ![PASS][pass] |

#### Entry 005 - SonarQube Static Analysis

**Date:** 17 November 2026

**Objective:** Evaluate code quality using SonarQube Community<br/>
Build.

**Implementation and findings:**

- Analysed the Maven project using JaCoCo XML coverage data.
- Obtained 90.2% coverage and 0.0% duplicated code.
- Identified Reliability rule `java:S9427` in an integration test.
- Replaced Java `assert` with JUnit `assertNotNull()`.
- Repeated Maven verification and SonarQube analysis.

**Reflection:** A passing test suite does not eliminate all code<br/>
quality issues. Static analysis detected an assertion that might be<br/>
disabled in normal JVM execution without `-ea`.

| Verification                 | Result        |
|------------------------------|---------------|
| Maven tests and JaCoCo gate  | ![PASS][pass] |
| SonarQube Quality Gate       | ![PASS][pass] |
| Reliability A, 0 open issues | ![PASS][pass] |

Before-and-after screenshots are retained under `evidence/`.

#### Entry 006 - Docker Containerisation and Trivy Security

**Date:** 17 November 2026

**Objective:** Package the application in a secure Docker image and<br/>
introduce automated image vulnerability scanning.

**Implementation:**

- Built a three-stage Dockerfile using Java 21.
- Executed Maven tests and the coverage gate in the build stage.
- Extracted the Spring Boot layered JAR for efficient caching.
- Configured non-root application execution and a read-only rootfs.
- Removed Linux capabilities and restricted privilege escalation.
- Added a separate Docker build and Trivy GitHub Actions workflow.

**Engineering decisions:**

A writable `tmpfs` at `/app/tmp` allows application temporary files<br/>
while keeping the root filesystem read-only. Explicit UID/GID mount<br/>
options ensure the non-root application process can use this<br/>
directory.

The extracted Spring Boot application uses the correct layered JAR<br/>
entrypoint. Trivy scan execution was configured with an adequate<br/>
timeout.

**Reflection:** Building an image does not prove that it starts<br/>
correctly. Runtime checks are required to validate actual<br/>
permissions and application availability under the selected security<br/>
restrictions.

| Verification                     | Result        |
|----------------------------------|---------------|
| Three-stage Docker image build   | ![PASS][pass] |
| Application health and REST API  | ![PASS][pass] |
| Runtime security configuration   | ![PASS][pass] |
| Trivy 0.76.2 security gate       | ![PASS][pass] |
| GitHub Actions run `44162103286` | ![PASS][pass] |

The cited GitHub Actions run covered image build and Trivy scanning.

#### Entry 007 - CI Hardening and Dependency Management

**Date:** 18 November 2026

**Objective:** Improve CI security, dependency maintenance, and<br/>
efficiency.

**Implementation:**

- Added concurrency control to the Docker security workflow.
- Preserved concurrency protection in the Java CI workflow.
- Pinned GitHub Actions to full commit SHA references.
- Kept minimum workflow permissions (`contents: read`).
- Configured Dependabot for Maven, Docker, and GitHub Actions.

**Engineering rationale:**

SHA pinning prevents a movable tag from silently selecting different<br/>
Action code. Dependabot can propose controlled upgrades as<br/>
reviewable Pull Requests, retaining reproducibility without freezing<br/>
dependencies.

CI runs can cancel superseded work. Deployment runs require a<br/>
different policy to avoid interrupting active releases.

**Industry context:**

GitHub Engineering describes operational Dependabot usage. Reddit<br/>
Engineering has documented prior Dependabot use and its later<br/>
migration to Renovate to support different dependency management<br/>
requirements. Neither replaces testing and review of proposed<br/>
updates.

**References:**

- [GitHub Engineering: Dependabot][github-dependabot]
- [Reddit Engineering: Dependency management][reddit-dependencies]

**Trade-off:** Pinned components require maintenance. Automated<br/>
updates still require review and a passing CI pipeline before<br/>
merging.

**Verification status:** Configuration is present on the feature<br/>
branch. Dependabot update PR creation has not yet been verified.

#### Entry 008 - Automated Docker Runtime Smoke Tests

**Date:** 18 November 2026

**Objective:** Verify that the built image runs the Spring Boot<br/>
application under the configured Docker runtime security<br/>
restrictions.

**Implementation:**

- Added reusable `scripts/docker/smoke-test.sh`.
- Integrated the script into the Docker security workflow.
- Kept runtime checks separate from CI orchestration.
- Selected a dynamically allocated localhost host port.
- Verified the image's non-root application user.
- Inspected read-only rootfs, capability removal, and privilege
  controls.
- Checked `tmpfs` options, Spring Boot health, and the REST API.
- Added container cleanup and failure diagnostic logging.

**Engineering rationale:**

A Docker build and vulnerability scan do not establish that the<br/>
application can actually run with hardened runtime settings. The<br/>
smoke test verifies these constraints and application availability<br/>
before the security scan.

A separate Bash script is reusable locally and in GitHub Actions.<br/>
Dynamic host port discovery avoids conflicts with existing services.<br/>
The security contract also defines requirements for future<br/>
Kubernetes deployment.

| Local verification (18 November 2026) | Result        |
|---------------------------------------|---------------|
| Bash syntax                           | ![PASS][pass] |
| Docker image build                    | ![PASS][pass] |
| Non-root image user                   | ![PASS][pass] |
| Runtime security restrictions         | ![PASS][pass] |
| Dynamic host port discovery           | ![PASS][pass] |
| Spring Boot health endpoint           | ![PASS][pass] |
| REST API smoke response               | ![PASS][pass] |

**Limitations:** HTTP smoke checks do not replace full integration<br/>
tests or security testing. The new smoke-test step has not yet<br/>
passed on a GitHub Actions runner. Negative security tests remain a<br/>
separate task.

### 3. Future Journal Entries

Each subsequent phase will record its objective, implementation,<br/>
engineering decisions, observed results, evidence, and limitations.

Do not record planned activities as completed work.

### 4. Task 4 Preparation

The reflective report will evaluate tool selection, architecture,<br/>
engineering trade-offs, the effects of automation, testing and<br/>
security, and the benefits and limits of collaboration and<br/>
reproducible delivery.

The report will compare alternatives and justify future improvements<br/>
using evidence from validated project work.

[pass]: https://img.shields.io/badge/PASS-2ea44f?style=flat-square

[github-dependabot]: https://github.blog/engineering/platform-security/

[reddit-dependencies]: https://www.reddit.com/r/RedditEng/
