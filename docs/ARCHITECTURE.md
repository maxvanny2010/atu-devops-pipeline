# CI/CD Pipeline Architecture

## Overview

This project implements an automated DevSecOps delivery pipeline for a<br/>
Java Spring Boot Task Manager application.

The application is intentionally small. The primary engineering focus<br/>
is automated testing, security, release management, deployment,<br/>
reliability, monitoring and reproducibility.

## Application Architecture

| Component | Technology                 | Responsibility                      |
|-----------|----------------------------|-------------------------------------|
| Backend   | Java 21, Spring Boot       | REST API and business logic         |
| Frontend  | HTML, CSS, JavaScript      | Task management interface           |
| Database  | H2                         | Application persistence             |
| Build     | Maven                      | Dependency management and packaging |
| Testing   | JUnit, Mockito, Playwright | Automated verification              |

## CI Architecture

The CI pipeline validates changes before merging into `master`.

```text
                      GitHub Pull Request
                               |
                               v
                         CI Pipeline
                               |
            +------------------+------------------+
            |                  |                  |
            v                  v                  v
       Unit Tests       Integration Tests      E2E Tests
            |                  |                  |
            +------------------+------------------+
                               |
                               v
                      Code and Security
                               |
                               v
                         Quality Gate
                          /       \
                       PASS       FAIL
                        |           |
                        v           v
                  Merge to master  Block
```

The diagram shows logical checks, not final GitHub Actions job dependencies.<br/>
Independent checks run in parallel where practical.

CI concurrency cancels superseded runs for the same branch.<br/>
Pipeline permissions follow the principle of least privilege.

## Release and Supply Chain

After successful validation of trusted code:

1. Determine the application version using Conventional Commits.
2. Create a versioned GitHub Release and Git tag.
3. Build and scan the Docker image.
4. Generate a Software Bill of Materials (SBOM).
5. Generate build provenance where supported.
6. Publish the image to GitHub Container Registry (GHCR).
7. Identify the release artifact using an immutable image digest.

The same validated image digest is promoted between environments.

## Deployment Architecture

- Kubernetes provides application orchestration.
- Terraform supports reproducible infrastructure provisioning where useful.
- Kubernetes manifests and Kustomize define application configuration.
- GitHub Actions orchestrates trusted deployment workflows.
- Readiness, liveness and startup probes validate application health.
- Smoke tests verify application behavior after deployment.
- Rollback procedures support recovery from failed releases.

Deployments to the same environment are serialized.<br/>
A dedicated deployment runner is separated from untrusted PR jobs.

## Security Architecture

- Restricted GitHub Actions permissions.
- No deployment credentials in untrusted pull request jobs.
- Protected branches and deployment environments where supported.
- SonarQube quality analysis and Trivy security scanning.
- Secret scanning and dependency integrity checks.
- Multi-stage Docker build with non-root runtime.
- Immutable image references and restricted secret access.

## Observability

| Component            | Responsibility                          |
|----------------------|-----------------------------------------|
| Spring Boot Actuator | Application health and metrics          |
| Micrometer           | Application metric instrumentation      |
| Prometheus           | Metrics collection and alert evaluation |
| Grafana              | Dashboards and visualisation            |
| Application logging  | Structured diagnostic events            |
| Slack                | Pipeline and operational notifications  |

## Verification Strategy

The implementation will include positive and negative tests.

Evidence will cover:

- Successful and failed automated tests.
- Quality gate enforcement and security scan results.
- Container build and image verification.
- Kubernetes rollout, application health and rollback.
- Monitoring dashboards and alert notifications.
- Versioned release creation and artifact traceability.

All implementation claims must be supported by actual verification.

## Architecture Status

Design documented. Implementation and validation are pending.
