### DevSecOps CI/CD Pipeline for a Spring Boot Task Manager

**Atlantic Technological University (ATU)**

**Program:** Postgraduate Diploma in Computing in DevOps<br/>
**Module:** DevOps Software Engineering<br/>
**Lecturer:** Maria Griffin<br/>
**Student:** Maksym Voronianskyi<br/>
**Student Number:** L00213593<br/>
**Academic Year:** 2026/2027

**Technologies:** Java 21, Spring Boot, Maven, GitHub Actions, SonarQube, Trivy,<br/>
Docker, Kubernetes, Terraform, Playwright, Prometheus, Grafana, Slack

---

### Overview

This project develops an automated DevSecOps CI/CD pipeline for a small Spring<br/>
Boot Task Manager web application.

The application is intentionally limited in scope so that the project can focus on<br/>
reproducible builds, automated testing, secure software delivery, container<br/>
orchestration, monitoring, and recovery procedures.

**Assignment:** Task 3 - DevOps in Action: Creating a mini-pipeline (60%).<br/>
**Related assignment:** Task 4 - DevOps in Action: Reflection (10%).

#### Project Status

**Current phase:** Project setup and architecture design. The pipeline, tests,<br/>
deployment, and monitoring are planned and have not yet been validated. Results<br/>
will be added after execution.

#### Technologies

| Area                         | Selected Technologies                 |
|------------------------------|---------------------------------------|
| Application                  | Java 21, Spring Boot, Maven           |
| Frontend                     | HTML, CSS, JavaScript                 |
| Unit and integration testing | JUnit, Mockito, Spring Boot Test      |
| Frontend and E2E testing     | Playwright                            |
| Test coverage                | JaCoCo                                |
| CI/CD                        | GitHub Actions                        |
| Code quality                 | SonarQube                             |
| Security scanning            | Trivy, secret scanning                |
| Containerisation             | Docker                                |
| Orchestration                | Kubernetes                            |
| Infrastructure as Code       | Terraform                             |
| Observability                | Prometheus, Grafana, application logs |
| Notifications                | Slack                                 |

#### Application Scope

The Task Manager application will provide a small REST API and web interface for<br/>
managing tasks.

- Create a task.
- List existing tasks.
- Update task status.
- Delete a task.

#### Pipeline Architecture

The planned CI/CD process separates Pull Request validation from trusted<br/>
deployment operations.

1. Create a feature branch and open a GitHub Pull Request.
2. Run automated build, unit tests, integration tests, and frontend tests.
3. Apply code quality and security checks before merging.
4. Build and scan a multi-stage Docker image.
5. Publish the verified image with an immutable identifier.
6. Deploy to a local Kubernetes environment through a controlled workflow.
7. Verify application health, observe metrics, and test rollback procedures.
8. Capture logs, alerts, pipeline results, and evidence for the assignment.

#### Git Workflow

- `master` is the integration branch.
- Feature branches isolate implementation changes.
- Pull Requests document changes, tests, and review outcomes.
- Release tags will identify validated application versions.

#### Testing Strategy

| Test Level     | Purpose                                      | Status  |
|----------------|----------------------------------------------|---------|
| Unit           | Validate isolated application logic          | Planned |
| Integration    | Validate application components together     | Planned |
| API            | Validate REST endpoint behaviour             | Planned |
| Frontend / E2E | Validate browser-based user workflows        | Planned |
| Security       | Detect vulnerable dependencies and images    | Planned |
| Deployment     | Validate rollout, health checks and rollback | Planned |

Test results, GitHub Actions run links, and screenshots will be documented in the<br/>
relevant README sections and stored under `evidence/`.

#### Security and Supply Chain Controls

The planned controls include:

- Read-only default permissions for GitHub Actions jobs.
- Separation of untrusted Pull Request checks from deployment credentials.
- Static analysis and vulnerability scanning with enforced quality gates.
- Minimal Docker runtime privileges and multi-stage builds.
- Software Bill of Materials (SBOM) generation.
- Immutable container image digests and provenance where supported.
- Protected deployment configuration and restricted secret access.

Verified controls, test evidence, and remaining limitations will be added to this<br/>
section after implementation.

#### Containerisation and Deployment

The application will use Docker for packaging and local Kubernetes for<br/>
orchestration. Infrastructure and deployment configurations will be kept in<br/>
version control to support reproducibility.

Deployment validation will include readiness and liveness checks, smoke tests, and<br/>
a documented rollback experiment.

#### Monitoring and Logging

The observability stack is planned to include:

- Spring Boot Actuator and Micrometer metrics.
- Prometheus metrics collection.
- Grafana dashboards for application health.
- Structured application logs.
- Alerting and Slack notifications.

#### Assignment Requirements and Evidence

| Assessment Criterion               | Marks | Evidence Location                 |
|------------------------------------|------:|-----------------------------------|
| Source Code Management             |    10 | Git history and Pull Requests     |
| Automated Builds and Testing       |    20 | CI results and test reports       |
| Static Analysis and Security       |    15 | Quality and vulnerability reports |
| Containerisation and Orchestration |    20 | Docker and Kubernetes evidence    |
| Deployment                         |    20 | CD runs and deployment checks     |
| Monitoring and Logging             |    15 | Dashboards, alerts, and logs      |

Evidence links and verified outcomes will be added as the project progresses. No<br/>
test or deployment result is claimed before successful validation.

#### Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Reflection Notes](docs/REFLECTION_NOTES.md)

Pipeline test results, security evidence, and deployment outcomes will be<br/>
documented in this README and linked to files in `evidence/`.

#### References

Official technical and academic sources will be added when the related<br/>
implementation decisions and controls are documented and validated.

#### Development Status and Limitations

This README describes the agreed project architecture at the initial setup stage.<br/>
Planned features are not presented as completed work. Verified commands,<br/>
screenshots, test results, and implementation limitations will be incorporated<br/>
throughout development.
