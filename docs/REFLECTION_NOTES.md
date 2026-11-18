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
- Created and published the initial Git branches and GitHub repository.
- Consolidated setup changes into one initial commit on `master`.
- Established the initial README and Git ignore rules.

**Challenge:**

The original project structure contained more documentation files than<br/>
necessary for the assignment.

**Decision:**

Consolidate technical documentation into README and ARCHITECTURE.<br/>
Maintain separate Reflection Notes for Task 4.

**Outcome:**

The Git repository and initial project structure were established.<br/>
Application implementation and CI automation were deferred to later work.

#### Entry 002 - Task Manager REST API

**Date:** 17 November 2026<br/>
**Implemented:** Spring Boot 4.1.2 CRUD API, H2, validation and HTTP 400/404.

**Challenges and fixes:**

- Corrected the Spring Initializr parent version from `4.1.2.RELEASE` to `4.1.2`.
- Avoided a Windows Maven cache lock by using a separate local repository.
- Fixed invalid JSON string escaping in API integration tests.
- Updated H2, json-smart and ASM after inspecting resolved dependency versions.

**Verified:** Local Maven build succeeded; 9 tests passed, 0 failures or errors.<br/>
**Not yet implemented:** JaCoCo, CI workflows, deployment and monitoring.

#### Entry 003 - JaCoCo Code Coverage

**Date:** 17 November 2026

JaCoCo 0.8.16 was integrated into Maven verification.<br/>
All 9 tests passed with 88% instruction coverage.<br/>
The 80% Quality Gate passed successfully.

#### Entry 004 - GitHub Actions CI

**Date:** 17 November 2026

Created a GitHub Actions workflow using Java 21 and Maven verification.<br/>
Local actionlint validation passed. Feature-branch push triggers were added.<br/>
GitHub Actions run `44083764858` succeeded, including the build, tests,<br/>
coverage gate and uploaded test and JaCoCo report artifacts.

#### Entry 005 - SonarQube Static Analysis

**Date:** 17 November 2026

**Objective:** Evaluate Java code quality using SonarQube Community Build.

**Validation and findings:**

- Started a local SonarQube Community Build server using Docker.
- Analyzed the Maven project with its JaCoCo XML coverage report.
- Initial Quality Gate passed; coverage was 90.2% with 0.0% duplications.
- SonarQube reported one high-impact Reliability issue (rule `java:S9427`).
- The issue concerned a Java `assert` in `TaskApiIntegrationTest.java`.
- Replaced `assert location != null;` with JUnit `assertNotNull(location);`.

**Reflection:**

The existing assertion provided a practical validation of static analysis.<br/>
Unlike JUnit assertions, Java `assert` may be disabled without JVM `-ea`.<br/>
The finding demonstrated that passing tests and a passing Quality Gate do<br/>
not necessarily mean that all code quality issues have been addressed.

**Retest outcome:**

Maven verification passed with all 9 tests and the JaCoCo 80% gate.<br/>
The repeat SonarQube analysis passed its Quality Gate with 90.2% coverage,<br/>
0.0% duplications, Reliability A and 0 open issues.<br/>
Before-and-after screenshots were retained in `evidence/`.<br/>
SonarQube Community Build has limited security analysis capabilities.

#### Entry 006 - Docker Containerisation and Trivy Security

**Date:** 17 November 2026

**Objective:** Package and validate the Spring Boot application in a
secure Docker container and introduce automated image security scanning.

**Implementation:**

- Implemented a three-stage Dockerfile using Java 21.
- Used Maven to build, test and verify the application.
- Extracted Spring Boot Layered JAR components for Docker layer caching.
- Configured a non-root runtime user and read-only filesystem.
- Removed Linux capabilities and disabled privilege escalation.
- Added a separate GitHub Actions Docker build and Trivy scanning workflow.

**Challenges and resolutions:**

- Tomcat initially failed because the `tmpfs` directory was not writable
  by the non-root user. Explicit UID/GID options resolved the issue.
- The initial layered application entrypoint could not load `JarLauncher`.
  Using the extracted `application.jar` resolved the startup problem.
- Trivy initially exceeded its scan timeout. Increasing the timeout to
  20 minutes allowed the image scan to complete.

**Verified results:**

- Three-stage Docker build succeeded.
- Application health returned `UP`.
- REST API responded successfully.
- Runtime security configuration was verified.
- Trivy 0.76.2 detected 0 HIGH/CRITICAL vulnerabilities.
- The local Trivy Security Gate passed.

**Reflection:**

A successful Docker build does not guarantee that a container can start.<br/>
Runtime validation revealed permission and startup issues that automated
build checks alone could not detect. Layered packaging also demonstrated
the benefits of separating application code from dependencies.

**Additional verification:** GitHub Actions Docker build and Trivy scan run 44162103286 passed.


#### Entry 007 - CI Hardening and Dependency Management

**Date:** 18 November 2026

**Objective:** Improve CI pipeline security, dependency maintenance and
execution efficiency without introducing unnecessary administrative privileges.

**Implementation:**

- Added concurrency control to the Docker security workflow.
- Preserved existing concurrency control in the Java CI workflow.
- Pinned GitHub Actions to full commit SHA references.
- Preserved minimal workflow permissions (`contents: read`).
- Configured Dependabot for GitHub Actions, Maven and Docker dependencies.

**Engineering decisions:**

Full commit SHA pinning prevents an existing workflow reference from
silently resolving to a different Action implementation when a tag moves.

Dependabot provides a controlled update mechanism through pull requests,
allowing pinned dependencies to be updated without abandoning reproducibility.

Concurrency cancellation was enabled only for CI workflows. Future deployment
workflows will use a separate concurrency policy to avoid interrupting active
deployments.

**Industry context and design rationale:**

Dependabot was introduced after implementing Docker and Trivy to address
the ongoing maintenance of vulnerable or outdated dependencies.

GitHub Engineering documents operational use of Dependabot.
Reddit Engineering has discussed previous Dependabot adoption and
its subsequent migration to Renovate for more advanced requirements.

This supports the decision to automate dependency update proposals
while keeping testing, review and release approval separate.

References:
- https://github.blog/engineering/platform-security/how-we-use-dependabot-to-secure-github/
- https://www.reddit.com/r/RedditEng/comments/1s1q879/dependency_hell_aka_how_i_learned_to_stop/
**Trade-offs:**

Pinned dependencies require ongoing maintenance. Automated dependency update
pull requests reduce manual work but do not replace review or testing.

**Pending verification:**

- Validate the configuration through GitHub.
- Verify Dependabot update pull request creation when updates become available.
- Implement Docker runtime smoke tests.
- Implement negative security tests.
- Add artifact digest and provenance controls.

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
