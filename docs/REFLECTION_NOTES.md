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

**Verification:** Dependabot opened four update PRs after the Docker<br/>
work reached `master`. CI checks ran on those PRs.

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
tests or security scanning. The Docker runtime smoke test passed in<br/>
GitHub Actions; negative cases are checked by a separate workflow.

#### Entry 009 - Negative Docker Runtime Tests

**Date:** 18 November 2026

The positive smoke test checks a correctly configured container.<br/>
I added three negative cases to confirm that the script also reports<br/>
expected failures instead of returning success for every input.

| Scenario                   | Actual exit code | Result        |
|----------------------------|-----------------:|---------------|
| Incorrect UID              |                1 | ![PASS][pass] |
| Invalid container port     |                1 | ![PASS][pass] |
| Missing API endpoint (404) |               22 | ![PASS][pass] |

The tests compare exit codes and error text. All three passed locally<br/>
and in a manual GitHub Actions run. I kept them outside the regular<br/>
CI workflow because they check the test mechanism, not each new build.

#### Entry 010 - Dependabot and Trivy Security Gate

**Date:** 18 November 2026

Once the Docker changes were merged, Dependabot opened four update<br/>
PRs. This confirmed that the dependency update configuration worked.<br/>
The PRs were automatically tested by Java CI and Docker CI.

PR #6 proposed changing the Java runtime image from version 21 to 24.<br/>
The Java checks and Docker runtime smoke test passed. Trivy then found<br/>
16 HIGH vulnerabilities in the Ubuntu 24.04 image and exited with<br/>
code 1. The Docker check failed, although the PR remained open.

| PR #6 check                 | Result        |
|-----------------------------|---------------|
| Java CI                     | ![PASS][pass] |
| Docker build and smoke test | ![PASS][pass] |
| Trivy: 16 HIGH, 0 CRITICAL  | Failed check  |

The result changed how I view dependency upgrades: a newer base image<br/>
is not automatically a safer one. Testing and scanning need to happen<br/>
before a dependency update is accepted. I kept the project on Java 21<br/>
and did not merge the suggested major-version update.

The scan failed the PR check, but failed checks alone do not guarantee<br/>
that a merge is blocked. A branch protection rule or ruleset would be<br/>
needed to enforce that restriction.

**Evidence:** See the Dependabot PR list, PR #6 checks, Trivy log,<br/>
and manual negative-test run linked from the README.

#### Entry 011 - Task Manager Frontend and Playwright E2E

**Date:** 18 November 2026

**Objective:** Add a usable browser interface to the existing REST API<br/>
and test real user actions end to end.

**Implementation:**

- Built a responsive HTML, CSS, and JavaScript interface in Spring<br/>
  Boot's `static` resources directory.
- Added task creation, listing, completion toggling, deletion, refresh,<br/>
  status counters, and error messages.
- Used the existing `/api/tasks` endpoints with `fetch`, avoiding a<br/>
  second frontend service and unnecessary CORS configuration.
- Created four Chromium Playwright tests for loading, adding, updating,<br/>
  and deleting tasks.
- Added `package.json`, a lockfile, and the Playwright configuration.
- Added a separate GitHub Actions workflow for E2E testing.

**Problems encountered and responses:**

The initial `npm init -y` and `npm install` failed because the existing<br/>
`package.json` was empty, not valid JSON. I replaced the empty file<br/>
with a minimal valid package definition and then installed Playwright.<br/>
The dependency lockfile allows CI to use `npm ci` rather than resolving<br/>
a new dependency tree on every run.

The first Spring Boot startup failed because port 8080 was already in<br/>
use. I ran the application on port 8081 instead and used that port in<br/>
Playwright configuration and the proposed CI job. This avoids stopping<br/>
an unrelated local service.

**Verification (local, 18 November 2026):**

| Check                       | Result        |
|-----------------------------|---------------|
| Frontend page loads         | ![PASS][pass] |
| Create task in Chromium     | ![PASS][pass] |
| Change task completion      | ![PASS][pass] |
| Delete task in Chromium     | ![PASS][pass] |
| JavaScript syntax checks    | ![PASS][pass] |
| Playwright test discovery   | ![PASS][pass] |
| `actionlint` workflow check | ![PASS][pass] |

All four Playwright tests passed locally in 8.4 seconds. The workflow<br/>
passed `actionlint`, and eight implementation files were staged with<br/>
no errors from `git diff --cached --check`.

**Reflection:** A working API and passing Java tests did not show<br/>
whether a user could create or update tasks in a real browser. The<br/>
Playwright tests cover these actions and check the resulting API state.<br/>
Keeping the frontend small makes it easier to focus on the CI/CD<br/>
assignment instead of frontend framework setup. The separate browser<br/>
workflow also makes E2E failures easier to identify independently of<br/>
Java tests and Docker security results.

**Limitations and next verification:** The four E2E tests cover basic<br/>
CRUD flows, not every validation error, accessibility concern, or<br/>
concurrent update. The new workflow has not run on GitHub Actions yet.<br/>
Only local E2E results are recorded as PASS. After a feature-branch<br/>
push, the GitHub run and its uploaded artifacts must be reviewed before<br/>
calling CI verification complete.

#### Entry 012 - Playwright CI Race Condition

**Date:** 18 November 2026

**Objective:** Investigate a Playwright test that passed locally
but failed in GitHub Actions.

**Problem:**

The first GitHub Actions E2E run passed three tests and failed one.
The completion test expected `completed: true`, but the backend
returned `completed: false`.

**Analysis:**

The frontend sends an asynchronous PATCH request when the user
checks a task. The original test checked the checkbox and then
immediately requested the task state through the API.

Checking the checkbox did not guarantee that the PATCH request
had completed. This created a likely race condition.

**Solution:**

I changed the Playwright test to wait for the matching HTTP PATCH
response using `page.waitForResponse()`.

The test checks HTTP 200 before requesting the stored task state.

**Verification:**

| Test                       | Result        |
|----------------------------|---------------|
| Initial GitHub Actions run | FAIL: 3/4     |
| Repeated completion test   | PASS: 10/10   |
| Full local E2E suite       | PASS: 4/4     |
| GitHub Actions after fix   | PASS: 4/4 E2E |

**Reflection:**

A test that passes locally can still fail in CI due to differences
in request timing. The original test verified the browser checkbox
but did not synchronise with the backend operation.

Waiting for the actual HTTP response is more reliable than adding
a fixed delay. This was a test synchronisation problem based on
the observed behavior, and the GitHub Actions rerun passed.

**Evidence:**

- `evidence/playwright-ci-race-failure_1.png`
- `evidence/playwright-ci-race-failure_2.png`
- `evidence/playwright-race-fix-repeat.png`
- `evidence/playwright-ci-success.png`

#### Entry 013 - Release Scripts and Security Checks

**Date:** 19 November 2026

**Objective:** Make the release pipeline easier to understand and test.

I first put the release commands directly into the GitHub Actions YAML.
It worked as a starting point, but the file became long and difficult
for me to check. I decided to keep the workflow for job order and
permissions, and move the longer Bash commands into `scripts/release/`.

I kept two jobs. Verify runs the application tests, Docker checks and
Trivy scan. Publish runs only if Verify succeeds. It uses the same
Docker image rather than building another one.

During the review, I found a few things to fix: the Docker image name
was repeated, the downloaded image needed more checks, and a repeated
release could try to reuse an existing tag. I updated the scripts to
check the image ID and labels, look for existing releases and tags, and
check the master commit again before publishing.

**How I used ChatGPT:**

I planned the pipeline structure and set the requirements for testing,
security and release behavior. I used ChatGPT to help write the Bash
and PowerShell code and to review possible errors. I did not simply use
the first version it produced. Some scripts failed during local checks,
including a Windows-to-Bash path problem. I tested the changes, reported
the failures and had the scripts corrected.

**Verification:**

- `actionlint` completed without errors.
- The release scripts passed Bash syntax checks.
- Offline tests passed for tags, master SHA, existing releases and
  image tags, archive checksums and Docker image metadata.

The offline tests use mock commands, so at this stage they did not prove
that publishing worked on GitHub. I planned a separate tagged release
for end-to-end verification.

**What I learned:**

ChatGPT helped me write the code faster, but it also made mistakes.
I needed to decide what the scripts should do and check the results.
Keeping the scripts separate made those checks easier. A release could
still partly succeed if the image is pushed but GitHub Release creation
fails, so that case needs care during the first real release.

#### Entry 014 - Automated Release Script Tests

**Date:** 19 November 2026

**Objective:** Run release-script checks automatically in GitHub Actions
before attempting the first tagged release.

I added a dedicated `release-tests.yml` workflow to execute Bash syntax
checks and the existing offline test suite on an Ubuntu runner. The
tests use mock GitHub and Docker commands; they verify both accepted
inputs and expected failures without pushing an image or creating a
release.

The first local run failed because some Bash scripts had Windows CRLF
line endings. I converted the release scripts to LF and added a
`.gitattributes` rule to keep that format. The scripts remained Bash;
only their line endings changed.

**Verification:**

- All 12 release Bash scripts passed syntax checks locally.
- Offline positive and negative release checks passed locally.
- `actionlint` reported no errors for `release-tests.yml`.
- **Release Script Validation** passed in GitHub Actions on Ubuntu.
- A separate Docker Security run failed during Maven dependency
  resolution, but passed when rerun. Its original cause was not proven.

**Evidence:** `evidence/release-script-tests-github-actions-pass.png`

**Reflection:** A local PASS did not independently demonstrate that
the checks worked in CI. The GitHub Actions run gives reproducible
evidence tied to a commit. Negative cases confirm that unsafe release
inputs are rejected. These tests did not verify GHCR publishing on their own.</br>
I checked that separately with a tagged release.

#### Entry 015 - First GHCR Release and Security Fix

**Date:** 19 November 2026

**Objective:** Publish the first tested version of the Task Manager
through GitHub Actions.

I created tag `v0.1.0` on `master` and started the release workflow.
The Verify job built the application and ran its checks, but Trivy found
one HIGH vulnerability in the Pebble binary included in the Java 21
base image. The job failed, so the Publish job did not release the image.

I looked at the scan result instead of bypassing it. I changed the
extract and runtime images to `eclipse-temurin:21-jre-noble` while keeping
Java 21. The base image did not contain Pebble, and the new complete
application image passed the local Trivy scan with 0 HIGH and 0 CRITICAL
findings.

Running the Docker smoke test locally was less straightforward. Git Bash
first failed on Windows CRLF line endings, so I added a Git rule to keep
the Docker Bash scripts in LF format. Running the test inside a helper
container then verified the non-root user and security settings, but its
HTTP health check timed out. The application itself started in the logs.
I used the GitHub Actions Docker Security run on Ubuntu for the final
smoke-test verification rather than claiming that local test passed.

The PR #12 checks passed. After the merge, a separate Docker build on
`master` failed to resolve a Maven parent POM. It passed when rerun.
I could not prove why that download failed, so I kept the issue separate
from the Trivy vulnerability.

**First successful release:** I tagged the merged commit `8a5f21a` as
`v0.1.1`. The Release and GHCR workflow completed successfully. GitHub
Container Registry now holds the public versioned image and GitHub
Releases records its commit and image digest.

**Evidence:**

- `evidence/ghcr-release-v0.1.1-actions.png`
- `evidence/ghcr-release-v0.1.1-package.png`
- `evidence/ghcr-release-v0.1.1-details.png`

**Reflection:** This was a major milestone because the pipeline did more
than pass tests: it produced a versioned image that can be deployed.
The failed `v0.1.0` attempt was also useful. It showed that the security
gate really stops a release when a HIGH vulnerability is found. I kept
that failed run as evidence and used a new tag for the corrected release,
rather than moving the old one. The next step is to deploy the published
image to Kubernetes and test its health and rollback.

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
