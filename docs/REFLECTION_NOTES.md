## Development and Reflection Notes

### Purpose

This document records technical decisions, implementation challenges,<br/>
alternative approaches, validation outcomes and lessons learned during<br/>
the development of the CI/CD pipeline.

The notes provide source material for Task 4: Reflective Analysis.<br/>
Only observed results are presented as completed work.

### 1. Initial Architecture Decisions

**Date:** 16 November 2026

#### Project Scope

The project uses a small Java Spring Boot Task Manager application.<br/>
The application is intentionally simple so the main focus remains on<br/>
automated delivery, security, reliability and observability.

#### CI/CD Platform

GitHub Actions was selected for CI/CD automation.<br/>
Jenkins was considered as an alternative. GitHub Actions provides native<br/>
repository integration without maintaining a dedicated Jenkins server.

#### Testing Strategy

The planned test strategy includes:

- JUnit and Mockito for unit testing.
- Spring Boot integration and API testing.
- Playwright for browser-based frontend testing.
- JaCoCo for code coverage and quality enforcement.

#### Security Strategy

SonarQube and Trivy were selected for code quality and vulnerability<br/>
scanning. Other planned controls address secrets, workflow permissions,<br/>
container security and software supply chain integrity.

#### Deployment Strategy

Docker and Kubernetes were selected for containerization and orchestration.<br/>
Terraform will be considered where it adds a clear technical benefit<br/>
to reproducible infrastructure provisioning.

#### Monitoring Strategy

Prometheus and Grafana were selected for application metrics and dashboards.<br/>
Slack is planned for pipeline feedback and operational notifications.

#### Release Strategy

Conventional Commits and Semantic Versioning were selected.<br/>
Automated release management is planned after the core CI pipeline works.

### 2. Implementation Journal

#### Entry 001 - Repository Initialisation

**Date:** 16 November 2026<br/>
**Objective:** Establish the Git repository and project structure.

**Completed:**

- Created the local Git repository.
- Created the `master` and `feature/project-setup` branches.
- Created the public GitHub repository.
- Published both branches.
- Created the initial commit `bd67797`.
- Established the initial README and Git ignore rules.

**Challenge:**

The original project structure contained more documentation files than<br/>
necessary for the assignment.

**Decision:**

Consolidate technical documentation into README and ARCHITECTURE.<br/>
Maintain separate Reflection Notes for Task 4.

**Outcome:**

The Git repository and initial project structure were established.<br/>
The CI pipeline and application have not yet been implemented.

### 3. Future Journal Entries

For each development phase, record:

- Objective and context.
- Design decisions and alternatives.
- Actual implementation and problems encountered.
- Fixes, validation results and evidence links.
- Remaining limitations and lessons learned.

Do not record planned activities as completed.

### 4. Task 4 Preparation

The final report will critically evaluate tool selection, architecture,<br/>
implementation challenges, the benefits and drawbacks of CI/CD, and the<br/>
application of collaboration, automation, measurement and sharing.

It will also compare alternative approaches and justify improvements<br/>
using actual evidence from the completed project.
