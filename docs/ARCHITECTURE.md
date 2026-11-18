### CI/CD Pipeline Architecture

**Atlantic Technological University (ATU)**

**Programme:** Postgraduate Diploma in Computing in DevOps<br/>
**Module:** DevOps Software Engineering<br/>
**Lecturer:** Maria Griffin<br/>
**Student:** Maksym Voronianskyi<br/>
**Student Number:** L00213593<br/>
**Academic Year:** 2026/2027

**Technologies:** Java 21, Spring Boot, Spring Data JPA, H2, Maven,<br/>
JUnit, Mockito, JaCoCo, HTML, CSS, JavaScript, Playwright, GitHub<br/>
Actions, SonarQube, Trivy, Dependabot, Docker, Docker Compose, GHCR,<br/>
Kubernetes, Kustomize, Terraform, Actuator, Micrometer, Prometheus,<br/>
Grafana, Slack, SBOM, Software Provenance, Image Signing, Semantic<br/>
Versioning

---

## Overview

The DevSecOps architecture supports automated verification and<br/>
controlled delivery of a small Java Spring Boot Task Manager<br/>
application. The main focus is reproducibility, security,<br/>
deployment, reliability, and observability.

## Application Architecture

| Component | Technology                 | Responsibility               |
|-----------|----------------------------|------------------------------|
| Backend   | Java 21, Spring Boot       | REST API and business logic  |
| Data      | Spring Data JPA, H2        | Persistence                  |
| Frontend  | HTML, CSS, JavaScript      | Browser-based task interface |
| Build     | Maven                      | Dependency management        |
| Testing   | JUnit, Mockito, Playwright | Automated verification       |

### Implemented Backend

The backend uses Spring MVC controllers, service components, Spring<br/>
Data JPA repositories, and H2. Bean Validation checks requests;<br/>
centralised exception handling returns HTTP 400/404 where<br/>
applicable.

Four service unit tests, four MVC API integration tests, and one<br/>
context load test passed on Java 21 and Spring Boot 4.1.2. The<br/>
browser-based frontend is not yet implemented.

## Code Coverage and Quality Gates

JaCoCo 0.8.16 generates reports during Maven verification. The build<br/>
enforces a minimum of 80% instruction coverage.

| Validation                   | Result        |
|------------------------------|---------------|
| Nine automated tests         | ![PASS][pass] |
| JaCoCo coverage: 88%         | ![PASS][pass] |
| Minimum coverage gate: 80%   | ![PASS][pass] |
| SonarQube Quality Gate       | ![PASS][pass] |
| Reliability A, 0 open issues | ![PASS][pass] |

SonarQube analysis confirmed 90.2% coverage and 0.0% code<br/>
duplication.

## CI Architecture

Pull Request validation and release/deployment operations run in<br/>
separate trust contexts.

```text
                     GitHub Pull Request
                              |
                              v
                        CI Validation
                              |
              +---------------+---------------+
              |               |               |
              v               v               v
         Java Tests      Code Quality     Docker Tests
              |               |               |
              +---------------+---------------+
                              |
                              v
                       Security Gates
                         /        \
                      PASS        FAIL
                       |            |
                       v            v
                  Merge eligible   Block
```

### Implemented Workflows

- Java CI builds, tests, and enforces the JaCoCo threshold.
- Docker CI builds the image and executes Trivy vulnerability
  scanning.
- A local Docker runtime smoke test verifies effective security
  settings.
- The Docker workflow includes a call to the reusable smoke-test
  script.
- Workflow permissions are limited to `contents: read`.
- GitHub Actions dependencies use full commit SHA references.
- CI concurrency cancels superseded branch runs.

The new Docker smoke-test step is not yet verified on a GitHub<br/>
runner.

## Docker Build Architecture

The Dockerfile uses three stages:

1. **Build:** Maven compiles and verifies the Java application.
2. **Extract:** Spring Boot extracts the layered executable JAR.
3. **Runtime:** The JRE executes the application as a non-root user.

Layered packaging helps reuse cached dependencies when application<br/>
code changes without modifying the dependency set.

### Docker Runtime Security Contract

| Requirement                    | Docker implementation                |
|--------------------------------|--------------------------------------|
| Non-root process               | `USER 10001:10001`                   |
| Immutable root filesystem      | `--read-only`                        |
| Minimal Linux capabilities     | `--cap-drop ALL`                     |
| No privilege escalation        | `--security-opt no-new-privileges`   |
| Restricted writable storage    | `/app/tmp` tmpfs                     |
| Local testing network exposure | `127.0.0.1` with a dynamic host port |

The `/app/tmp` tmpfs uses `rw,nosuid,noexec` plus explicit UID/GID.<br/>
The configuration is applied when the container starts, not solely<br/>
by building the Docker image.

### Runtime Verification

The CI workflow executes `scripts/docker/smoke-test.sh` after the<br/>
Docker build and before Trivy scanning. GitHub Actions orchestrates<br/>
the step; the Bash script implements the checks.

The script:

1. Verifies the non-root user configured in the built image.
2. Runs the image with read-only filesystem and restricted privileges.
3. Uses `docker inspect` to check effective runtime configuration.
4. Discovers the dynamically assigned localhost host port.
5. Polls `/actuator/health` until Spring Boot reports `UP`.
6. Checks the response to `GET /api/tasks`.
7. Removes the container and prints logs if validation fails.

Runtime values such as image name, UID/GID, timeout, and endpoint<br/>
paths are configurable through environment variables.

| Local verification (18 November 2026) | Result        |
|---------------------------------------|---------------|
| Bash syntax                           | ![PASS][pass] |
| Docker image build                    | ![PASS][pass] |
| Image user                            | ![PASS][pass] |
| Runtime security restrictions         | ![PASS][pass] |
| Dynamic localhost port                | ![PASS][pass] |
| Spring Boot health endpoint           | ![PASS][pass] |
| REST API smoke response               | ![PASS][pass] |

**Verification:** Local PASS. GitHub Actions smoke-test run pending.

## Release and Supply Chain Architecture

### Versioning and Release Artifacts

| Element            | Configuration                             |
|--------------------|-------------------------------------------|
| Commit convention  | Conventional Commits                      |
| Version scheme     | Semantic Versioning (`MAJOR.MINOR.PATCH`) |
| Version identifier | Git tag (`vX.Y.Z`)                        |
| Release record     | GitHub Release associated with the tag    |
| Image registry     | GitHub Container Registry (GHCR)          |
| Image identity     | Immutable registry digest (`sha256:...`)  |
| Security evidence  | Trivy report, SBOM, provenance, signature |

### Release Flow

```text
Conventional Commits
         |
         v
CI: Tests + Coverage + SonarQube + Docker + Trivy
         |
         v
Approved merge to default branch
         |
         v
Version selection (Semantic Versioning)
         |
         v
Git tag vX.Y.Z
         |
         v
GitHub Release
         |
         v
Build and publish image to GHCR
         |
         +--> Vulnerability scan
         +--> Generate SBOM
         +--> Generate provenance
         +--> Sign and verify artifact
         |
         v
Record immutable image digest
         |
         v
Deploy verified image by digest
```

### Artifact Promotion

The deployment references the verified GHCR image digest, rather<br/>
than rebuilding the application or relying on a mutable image tag.

## Kubernetes Deployment Architecture

### Workload and Runtime Security

| Component                   | Kubernetes configuration                  |
|-----------------------------|-------------------------------------------|
| Application                 | Deployment                                |
| Internal access             | Service                                   |
| Non-root process            | `runAsNonRoot`, `runAsUser`, `runAsGroup` |
| Read-only root              | `readOnlyRootFilesystem: true`            |
| Capabilities                | `drop: [ALL]`                             |
| Privilege escalation        | `allowPrivilegeEscalation: false`         |
| System-call filtering       | `seccompProfile: RuntimeDefault`          |
| Writable temporary files    | `emptyDir` mounted at `/app/tmp`          |
| Health checks               | Startup, readiness, liveness probes       |
| Environment overlays        | Kustomize                                 |
| Infrastructure provisioning | Terraform                                 |

### Deployment Flow

```text
Verified GHCR image digest
            |
            v
Kustomize environment configuration
            |
            v
Kubernetes Deployment
            |
            +--> Startup probe
            +--> Readiness probe
            +--> Liveness probe
            |
            v
Rollout verification
            |
            +--> PASS: deployment complete
            |
            +--> FAIL: rollback
```

### CI/CD Trust Boundaries

| Pipeline stage      | Access                               |
|---------------------|--------------------------------------|
| Pull Request CI     | Read-only repository access          |
| Release workflow    | Tag and release creation permissions |
| Image publication   | GHCR package write permissions       |
| Deployment workflow | Environment-scoped credentials       |

Deployment workflows are serialised per target environment.

## Security Architecture

- Minimum GitHub Actions permissions and full SHA-pinned
  dependencies.
- Dependabot configuration for GitHub Actions, Maven, and Docker.
- SonarQube static quality analysis and Trivy vulnerability scanning.
- Hardened Docker runtime with reduced process and filesystem
  privileges.
- Restricted secrets and separate trust boundaries for deployment.
- Immutable release artifacts and eventual provenance validation.

## Observability

| Component            | Responsibility                         |
|----------------------|----------------------------------------|
| Spring Boot Actuator | Health and application metrics         |
| Micrometer           | Application instrumentation            |
| Prometheus           | Metrics collection                     |
| Grafana              | Operational dashboards                 |
| Application logging  | Structured diagnostic information      |
| Slack                | Pipeline and operational notifications |

## Verification Strategy

Evidence should include both positive and negative outcomes:

- Successful and failed automated tests.
- Coverage thresholds and code quality gate enforcement.
- Vulnerability findings and blocked releases.
- Container build and hardened runtime validation.
- Kubernetes rollout, health checks, and rollback.
- Metrics, dashboard screenshots, and alert notifications.
- Tagged release and immutable artifact traceability.

[pass]: https://img.shields.io/badge/PASS-2ea44f?style=flat-square
