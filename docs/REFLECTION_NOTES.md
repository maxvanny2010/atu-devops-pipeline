### Development and Reflection Notes

**Atlantic Technological University (ATU)**

**Programme:** Postgraduate Diploma in Computing in DevOps **Module:** DevOps<br/>
Software Engineering **Lecturer:** Maria Griffin **Student:** Maksym<br/>
Voronianskyi **Student Number:** L00213593 **Academic Year:** 2026/2027

**Technologies:** Java 21, Spring Boot, Maven, JUnit, Mockito, JaCoCo, Git,<br/>
GitHub Actions, SonarQube, Trivy, Dependabot, Docker, Docker Compose, HTML,<br/>
CSS, JavaScript, Playwright, GHCR, Kubernetes, Kustomize, Terraform, Actuator,<br/>
Micrometer, Prometheus, Grafana, Slack, SBOM, Software Provenance, Image<br/>
Signing, Semantic Versioning

---

### Purpose

This document records technical decisions, engineering trade-offs,<br/>
implementation outcomes, and verifiable evidence from development of the CI/CD<br/>
pipeline. It provides source material for Task 4: Reflective Analysis. Only<br/>
observed results are represented as completed work.

### 1. Initial Architecture Decisions

**Date:** 16 November 2026

#### Project Scope

A small Spring Boot Task Manager is used so that the central engineering focus<br/>
remains automated delivery, security, reliability, and observability.

#### CI/CD Platform

GitHub Actions was selected for CI/CD automation. Jenkins was considered as an<br/>
alternative, but GitHub Actions integrates directly with the repository without<br/>
maintaining a dedicated Jenkins server.

#### Testing Strategy

The testing approach combines JUnit, Mockito, Spring Boot integration tests,<br/>
Playwright browser tests, and JaCoCo coverage enforcement.

#### Security Strategy

SonarQube and Trivy provide code quality and vulnerability scanning. Further<br/>
controls address workflow permissions, container privileges, secrets,<br/>
dependency maintenance, and software supply chain integrity.

#### Deployment Strategy

Docker provides reproducible packaging; Kubernetes provides orchestration.<br/>
Terraform may be used where infrastructure provisioning adds clear value.

#### Monitoring Strategy

Spring Boot Actuator, Micrometer, Prometheus, and Grafana form the<br/>
observability design. Slack provides operational notifications.

#### Release Strategy

Conventional Commits and Semantic Versioning support release traceability.<br/>
Versioned artifacts will be linked to immutable container digests.

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

Keep the primary technical documentation in README and Architecture. Maintain<br/>
separate Reflection Notes to support Task 4.

**Outcome:** Repository structure established for incremental development.

#### Entry 002 - Task Manager REST API

**Date:** 17 November 2026

**Implemented:** Spring Boot 4.1.2 CRUD API, H2, validation, and HTTP 400/404.

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

JaCoCo 0.8.16 was integrated into Maven verification. Nine automated tests<br/>
passed with 88% instruction coverage. The 80% Quality Gate passed.

| Verification     | Result        |
|------------------|---------------|
| Nine tests       | ![PASS][pass] |
| Coverage: 88%    | ![PASS][pass] |
| Minimum 80% gate | ![PASS][pass] |

#### Entry 004 - GitHub Actions CI

**Date:** 17 November 2026

Created the Java 21 Maven CI workflow with automated testing, coverage, and<br/>
test report artifact uploads. Feature-branch triggers were configured.

| Verification                     | Result        |
|----------------------------------|---------------|
| Local actionlint                 | ![PASS][pass] |
| GitHub Actions run `44083764858` | ![PASS][pass] |
| Test report artifacts            | ![PASS][pass] |

#### Entry 005 - SonarQube Static Analysis

**Date:** 17 November 2026

**Objective:** Evaluate code quality using SonarQube Community Build.

**Implementation and findings:**

- Analysed the Maven project using JaCoCo XML coverage data.
- Obtained 90.2% coverage and 0.0% duplicated code.
- Identified Reliability rule `java:S9427` in an integration test.
- Replaced Java `assert` with JUnit `assertNotNull()`.
- Repeated Maven verification and SonarQube analysis.

**Reflection:** A passing test suite does not eliminate all code quality<br/>
issues. Static analysis detected an assertion that might be disabled in normal<br/>
JVM execution without `-ea`.

| Verification                 | Result        |
|------------------------------|---------------|
| Maven tests and JaCoCo gate  | ![PASS][pass] |
| SonarQube Quality Gate       | ![PASS][pass] |
| Reliability A, 0 open issues | ![PASS][pass] |

Before-and-after screenshots are retained under `evidence/`.

#### Entry 006 - Docker Containerisation and Trivy Security

**Date:** 17 November 2026

**Objective:** Package the application in a secure Docker image and introduce<br/>
automated image vulnerability scanning.

**Implementation:**

- Built a three-stage Dockerfile using Java 21.
- Executed Maven tests and the coverage gate in the build stage.
- Extracted the Spring Boot layered JAR for efficient caching.
- Configured non-root application execution and a read-only rootfs.
- Removed Linux capabilities and restricted privilege escalation.
- Added a separate Docker build and Trivy GitHub Actions workflow.

**Engineering decisions:**

A writable `tmpfs` at `/app/tmp` allows application temporary files while<br/>
keeping the root filesystem read-only. Explicit UID/GID mount options ensure<br/>
the non-root application process can use this directory.

The extracted Spring Boot application uses the correct layered JAR entrypoint.<br/>
Trivy scan execution was configured with an adequate timeout.

**Reflection:** Building an image does not prove that it starts correctly.<br/>
Runtime checks are required to validate actual permissions and application<br/>
availability under the selected security restrictions.

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

**Objective:** Improve CI security, dependency maintenance, and efficiency.

**Implementation:**

- Added concurrency control to the Docker security workflow.
- Preserved concurrency protection in the Java CI workflow.
- Pinned GitHub Actions to full commit SHA references.
- Kept minimum workflow permissions (`contents: read`).
- Configured Dependabot for Maven, Docker, and GitHub Actions.

**Engineering rationale:**

SHA pinning prevents a movable tag from silently selecting different Action<br/>
code. Dependabot can propose controlled upgrades as reviewable Pull Requests,<br/>
retaining reproducibility without freezing dependencies.

CI runs can cancel superseded work. Deployment runs require a different policy<br/>
to avoid interrupting active releases.

**Industry context:**

GitHub Engineering describes operational Dependabot usage. Reddit Engineering<br/>
has documented prior Dependabot use and its later migration to Renovate to<br/>
support different dependency management requirements. Neither replaces testing<br/>
and review of proposed updates.

**References:**

- [GitHub Engineering: Dependabot][github-dependabot]
- [Reddit Engineering: Dependency management][reddit-dependencies]

**Trade-off:** Pinned components require maintenance. Automated updates still<br/>
require review and a passing CI pipeline before merging.

**Verification:** Dependabot opened four update PRs after the Docker work<br/>
reached `master`. CI checks ran on those PRs.

#### Entry 008 - Automated Docker Runtime Smoke Tests

**Date:** 18 November 2026

**Objective:** Verify that the built image runs the Spring Boot application<br/>
under the configured Docker runtime security restrictions.

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

A Docker build and vulnerability scan do not establish that the application can<br/>
actually run with hardened runtime settings. The smoke test verifies these<br/>
constraints and application availability before the security scan.

A separate Bash script is reusable locally and in GitHub Actions. Dynamic host<br/>
port discovery avoids conflicts with existing services. The security contract<br/>
also defines requirements for future Kubernetes deployment.

| Local verification (18 November 2026) | Result        |
|---------------------------------------|---------------|
| Bash syntax                           | ![PASS][pass] |
| Docker image build                    | ![PASS][pass] |
| Non-root image user                   | ![PASS][pass] |
| Runtime security restrictions         | ![PASS][pass] |
| Dynamic host port discovery           | ![PASS][pass] |
| Spring Boot health endpoint           | ![PASS][pass] |
| REST API smoke response               | ![PASS][pass] |

**Limitations:** HTTP smoke checks do not replace full integration tests or<br/>
security scanning. The Docker runtime smoke test passed in GitHub Actions;<br/>
negative cases are checked by a separate workflow.

#### Entry 009 - Negative Docker Runtime Tests

**Date:** 18 November 2026

The positive smoke test checks a correctly configured container. I added three<br/>
negative cases to confirm that the script also reports expected failures<br/>
instead of returning success for every input.

| Scenario                   | Actual exit code | Result        |
|----------------------------|-----------------:|---------------|
| Incorrect UID              |                1 | ![PASS][pass] |
| Invalid container port     |                1 | ![PASS][pass] |
| Missing API endpoint (404) |               22 | ![PASS][pass] |

The tests compare exit codes and error text. All three passed locally and in a<br/>
manual GitHub Actions run. I kept them outside the regular CI workflow because<br/>
they check the test mechanism, not each new build.

#### Entry 010 - Dependabot and Trivy Security Gate

**Date:** 18 November 2026

Once the Docker changes were merged, Dependabot opened four update PRs. This<br/>
confirmed that the dependency update configuration worked. The PRs were<br/>
automatically tested by Java CI and Docker CI.

PR #6 proposed changing the Java runtime image from version 21 to 24. The Java<br/>
checks and Docker runtime smoke test passed. Trivy then found 16 HIGH<br/>
vulnerabilities in the Ubuntu 24.04 image and exited with code 1. The Docker<br/>
check failed, although the PR remained open.

| PR #6 check                 | Result        |
|-----------------------------|---------------|
| Java CI                     | ![PASS][pass] |
| Docker build and smoke test | ![PASS][pass] |
| Trivy: 16 HIGH, 0 CRITICAL  | Failed check  |

The result changed how I view dependency upgrades: a newer base image is not<br/>
automatically a safer one. Testing and scanning need to happen before a<br/>
dependency update is accepted. I kept the project on Java 21 and did not merge<br/>
the suggested major-version update.

The scan failed the PR check, but failed checks alone do not guarantee that a<br/>
merge is blocked. A branch protection rule or ruleset would be needed to<br/>
enforce that restriction.

**Evidence:** See the Dependabot PR list, PR #6 checks, Trivy log, and manual<br/>
negative-test run linked from the README.

#### Entry 011 - Task Manager Frontend and Playwright E2E

**Date:** 18 November 2026

**Objective:** Add a usable browser interface to the existing REST API and test<br/>
real user actions end to end.

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
`package.json` was empty, not valid JSON. I replaced the empty file with a<br/>
minimal valid package definition and then installed Playwright. The dependency<br/>
lockfile allows CI to use `npm ci` rather than resolving a new dependency tree<br/>
on every run.

The first Spring Boot startup failed because port 8080 was already in use. I<br/>
ran the application on port 8081 instead and used that port in Playwright<br/>
configuration and the proposed CI job. This avoids stopping an unrelated local<br/>
service.

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

All four Playwright tests passed locally in 8.4 seconds. The workflow passed<br/>
`actionlint`, and eight implementation files were staged with no errors from<br/>
`git diff --cached --check`.

**Reflection:** A working API and passing Java tests did not show whether a<br/>
user could create or update tasks in a real browser. The Playwright tests cover<br/>
these actions and check the resulting API state. Keeping the frontend small<br/>
makes it easier to focus on the CI/CD assignment instead of frontend framework<br/>
setup. The separate browser workflow also makes E2E failures easier to identify<br/>
independently of Java tests and Docker security results.

**Limitations and next verification:** The four E2E tests cover basic CRUD<br/>
flows, not every validation error, accessibility concern, or concurrent update.<br/>
The new workflow has not run on GitHub Actions yet. Only local E2E results are<br/>
recorded as PASS. After a feature-branch push, the GitHub run and its uploaded<br/>
artifacts must be reviewed before calling CI verification complete.

#### Entry 012 - Playwright CI Race Condition

**Date:** 18 November 2026

**Objective:** Investigate a Playwright test that passed locally but failed in<br/>
GitHub Actions.

**Problem:**

The first GitHub Actions E2E run passed three tests and failed one. The<br/>
completion test expected `completed: true`, but the backend returned<br/>
`completed: false`.

**Analysis:**

The frontend sends an asynchronous PATCH request when the user checks a task.<br/>
The original test checked the checkbox and then immediately requested the task<br/>
state through the API.

Checking the checkbox did not guarantee that the PATCH request had completed.<br/>
This created a likely race condition.

**Solution:**

I changed the Playwright test to wait for the matching HTTP PATCH response<br/>
using `page.waitForResponse()`.

The test checks HTTP 200 before requesting the stored task state.

**Verification:**

| Test                       | Result        |
|----------------------------|---------------|
| Initial GitHub Actions run | FAIL: 3/4     |
| Repeated completion test   | PASS: 10/10   |
| Full local E2E suite       | PASS: 4/4     |
| GitHub Actions after fix   | PASS: 4/4 E2E |

**Reflection:**

A test that passes locally can still fail in CI due to differences in request<br/>
timing. The original test verified the browser checkbox but did not synchronise<br/>
with the backend operation.

Waiting for the actual HTTP response is more reliable than adding a fixed<br/>
delay. This was a test synchronisation problem based on the observed behavior,<br/>
and the GitHub Actions rerun passed.

**Evidence:**

- `evidence/playwright-ci-race-failure_1.png`
- `evidence/playwright-ci-race-failure_2.png`
- `evidence/playwright-race-fix-repeat.png`
- `evidence/playwright-ci-success.png`

#### Entry 013 - Release Scripts and Security Checks

**Date:** 19 November 2026

**Objective:** Make the release pipeline easier to understand and test.

I first put the release commands directly into the GitHub Actions YAML. It<br/>
worked as a starting point, but the file became long and difficult for me to<br/>
check. I decided to keep the workflow for job order and permissions, and move<br/>
the longer Bash commands into `scripts/release/`.

I kept two jobs. Verify runs the application tests, Docker checks and Trivy<br/>
scan. Publish runs only if Verify succeeds. It uses the same Docker image<br/>
rather than building another one.

During the review, I found a few things to fix: the Docker image name was<br/>
repeated, the downloaded image needed more checks, and a repeated release could<br/>
try to reuse an existing tag. I updated the scripts to check the image ID and<br/>
labels, look for existing releases and tags, and check the master commit again<br/>
before publishing.

**How I used ChatGPT:**

I planned the pipeline structure and set the requirements for testing, security<br/>
and release behavior. I used ChatGPT to help write the Bash and PowerShell code<br/>
and to review possible errors. I did not simply use the first version it<br/>
produced. Some scripts failed during local checks, including a Windows-to-Bash<br/>
path problem. I tested the changes, reported the failures and had the scripts<br/>
corrected.

**Verification:**

- `actionlint` completed without errors.
- The release scripts passed Bash syntax checks.
- Offline tests passed for tags, master SHA, existing releases and
  image tags, archive checksums and Docker image metadata.

The offline tests use mock commands, so at this stage they did not prove that<br/>
publishing worked on GitHub. I planned a separate tagged release for end-to-end<br/>
verification.

**What I learned:**

ChatGPT helped me write the code faster, but it also made mistakes. I needed to<br/>
decide what the scripts should do and check the results. Keeping the scripts<br/>
separate made those checks easier. A release could still partly succeed if the<br/>
image is pushed but GitHub Release creation fails, so that case needs care<br/>
during the first real release.

#### Entry 014 - Automated Release Script Tests

**Date:** 19 November 2026

**Objective:** Run release-script checks automatically in GitHub Actions before<br/>
attempting the first tagged release.

I added a dedicated `release-tests.yml` workflow to execute Bash syntax checks<br/>
and the existing offline test suite on an Ubuntu runner. The tests use mock<br/>
GitHub and Docker commands; they verify both accepted inputs and expected<br/>
failures without pushing an image or creating a release.

The first local run failed because some Bash scripts had Windows CRLF line<br/>
endings. I converted the release scripts to LF and added a `.gitattributes`<br/>
rule to keep that format. The scripts remained Bash; only their line endings<br/>
changed.

**Verification:**

- All 12 release Bash scripts passed syntax checks locally.
- Offline positive and negative release checks passed locally.
- `actionlint` reported no errors for `release-tests.yml`.
- **Release Script Validation** passed in GitHub Actions on Ubuntu.
- A separate Docker Security run failed during Maven dependency
  resolution, but passed when rerun. Its original cause was not proven.

**Evidence:** `evidence/release-script-tests-github-actions-pass.png`

**Reflection:** A local PASS did not independently demonstrate that the checks<br/>
worked in CI. The GitHub Actions run gives reproducible evidence tied to a<br/>
commit. Negative cases confirm that unsafe release inputs are rejected. These<br/>
tests did not verify GHCR publishing on their own.</br> I checked that<br/>
separately with a tagged release.

#### Entry 015 - First GHCR Release and Security Fix

**Date:** 19 November 2026

**Objective:** Publish the first tested version of the Task Manager through<br/>
GitHub Actions.

I created tag `v0.1.0` on `master` and started the release workflow. The Verify<br/>
job built the application and ran its checks, but Trivy found one HIGH<br/>
vulnerability in the Pebble binary included in the Java 21 base image. The job<br/>
failed, so the Publish job did not release the image.

I looked at the scan result instead of bypassing it. I changed the extract and<br/>
runtime images to `eclipse-temurin:21-jre-noble` while keeping Java 21. The<br/>
base image did not contain Pebble, and the new complete application image<br/>
passed the local Trivy scan with 0 HIGH and 0 CRITICAL findings.

Running the Docker smoke test locally was less straightforward. Git Bash first<br/>
failed on Windows CRLF line endings, so I added a Git rule to keep the Docker<br/>
Bash scripts in LF format. Running the test inside a helper container then<br/>
verified the non-root user and security settings, but its HTTP health check<br/>
timed out. The application itself started in the logs. I used the GitHub<br/>
Actions Docker Security run on Ubuntu for the final smoke-test verification<br/>
rather than claiming that local test passed.

The PR #12 checks passed. After the merge, a separate Docker build on `master`<br/>
failed to resolve a Maven parent POM. It passed when rerun. I could not prove<br/>
why that download failed, so I kept the issue separate from the Trivy<br/>
vulnerability.

**First successful release:** I tagged the merged commit `8a5f21a` as `v0.1.1`.<br/>
The Release and GHCR workflow completed successfully. GitHub Container Registry<br/>
now holds the public versioned image and GitHub Releases records its commit and<br/>
image digest.

**Evidence:**

- `evidence/ghcr-release-v0.1.1-actions.png`
- `evidence/ghcr-release-v0.1.1-package.png`
- `evidence/ghcr-release-v0.1.1-details.png`

**Reflection:** This was a major milestone because the pipeline did more than<br/>
pass tests: it produced a versioned image that can be deployed. The failed<br/>
`v0.1.0` attempt was also useful. It showed that the security gate really stops<br/>
a release when a HIGH vulnerability is found. I kept that failed run as<br/>
evidence and used a new tag for the corrected release, rather than moving the<br/>
old one. The next step is to deploy the published image to Kubernetes and test<br/>
its health and rollback.

#### Entry 016 - Kubernetes and Kustomize

**Date:** 19 November 2026

**Objective:** Prepare Kubernetes deployment files and automate their<br/>
validation before attempting a real deployment.

I used the official Kubernetes documentation to understand Deployments,<br/>
Services and Kustomize.

I started with one Deployment and Service. The first version contained the GHCR<br/>
image version directly in the Deployment. I then moved the image name and<br/>
version into a shared release overlay to avoid repeating them in multiple<br/>
environment files.

Local and production overlays now reuse the same base configuration. Both use<br/>
one replica because the application currently uses H2. Two replicas could have<br/>
different data without a shared database.

I kept port 8080, the non-root user, security restrictions and health endpoints<br/>
in the base because they are common application requirements.

**Verification:**

- `kubectl kustomize` generated both environment manifests.
- Both outputs used the expected `v0.1.1` GHCR image.
- Both outputs configured one replica.
- `actionlint` passed for the Kubernetes validation workflow.

**Reflection:**

I learned that Kustomize does not replace variables inside the original YAML<br/>
files. Instead, it combines a shared base with environment-specific changes to<br/>
produce a final manifest.

This avoids copying entire Deployment files when only a few settings need to<br/>
change.

At that stage I had verified only generated manifests. Later on 19 November, I<br/>
deployed the published image into Docker Desktop Kubernetes. The rollout, Pod<br/>
readiness, health and REST API passed. However, the frontend returned HTTP 404;<br/>
I investigated this in Entry 017. A corrected release and rollback test are<br/>
still pending.

**References:**

- https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/
- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
- https://kubernetes.io/docs/concepts/services-networking/service/
- https://kubernetes.io/docs/concepts/configuration/liveness-readiness-startup-probes/

#### Entry 017 - Docker Frontend Packaging Issue

**Date:** 19 November 2026

**Objective:** Find out why the frontend was missing from the first Kubernetes<br/>
deployment and prevent the same issue in later releases.

The Kubernetes Pod started and became Ready. The health endpoint and REST API<br/>
worked, but the frontend returned HTTP 404. This showed that a successful<br/>
deployment did not mean the whole application was working.

I checked the source files, local Maven JAR, Dockerfile and `.dockerignore`. A<br/>
fresh Maven build included `index.html`, `styles.css` and `app.js`. The problem<br/>
was the Docker build context: `.dockerignore` excluded<br/>
`src/main/resources/static`, so those files were missing from the published<br/>
`v0.1.1` image.

I removed the incorrect exclusions, rebuilt the image locally and added four<br/>
frontend HTTP checks to the existing Docker smoke test. The checks run against<br/>
the actual container, after the health and API checks.

**Local verification:**

- Maven build passed all nine tests and included the frontend files.
- The corrected Docker image built successfully.
- The secure container smoke test passed, including health, REST API and
  all four frontend URLs (HTTP 200).
- The old `v0.1.1` image passed health and API checks but failed the new
  frontend check with HTTP 404 and exit code 1, as expected.

**What I learned:**

Playwright verified the frontend before Docker packaging. It could not catch<br/>
files removed by `.dockerignore` during image creation. Our original container<br/>
smoke test also checked only health and the API. I learned that tests should<br/>
cover the **final packaged image**, not just the source application. The<br/>
negative test was important because it showed that the new check catches the<br/>
actual missing-frontend problem.

**Deployment evidence:** The README includes cluster, rollout and Docker<br/>
Desktop dashboard screenshots from the initial `v0.1.1` deployment. They<br/>
confirm a running Pod, not a working frontend.

**Limitation and next step:** The corrected image has only been tested locally.<br/>
The new smoke test still needs GitHub Actions verification. A corrected GHCR<br/>
release and Kubernetes redeployment have not yet been completed. The existing<br/>
`v0.1.1` release is left unchanged.

#### Entry 018 - Kubernetes Validation Script Refactoring

**Date:** 19 November 2026

**Objective:** Move Kubernetes validation commands out of GitHub Actions YAML<br/>
so they can be tested locally and maintained in one place.

I noticed that the Kubernetes workflow contained a long inline Bash block.<br/>
We had already separated workflow orchestration from implementation in the<br/>
release pipeline, but I had not followed the same approach for Kubernetes.

I created `scripts/k8s/install-kubectl.sh` to download and verify `kubectl`<br/>
using SHA-256 on the Ubuntu CI runner. I moved Kustomize rendering and manifest<br/>
checks to `scripts/k8s/validate-manifests.sh`. The workflow now calls these<br/>
scripts and watches `scripts/k8s/**` for changes.

The validation script reads the expected container image from the rendered<br/>
release overlay. This avoids hard-coding `v0.1.1` in both configuration and<br/>
tests. It checks the local and production manifests against the same image.

**Problem found:** My first image-extraction expression expected `image:` as<br/>
the first YAML field. Kustomize actually generated `- image:`, so the first<br/>
local run failed. I corrected the `awk` expression and repeated validation.

**Local verification:**

- Both Bash scripts passed `bash -n`.
- `actionlint` passed for the shorter workflow.
- Release image extraction succeeded.
- Local and production overlays both passed validation.
- The three new or changed files met the 90-character line limit.
- `git diff --cached --check` passed.

**Reflection:** Smaller workflow files are easier to review, and reusable<br/>
scripts can be tested without triggering GitHub Actions. I also need to<br/>
check the actual generated YAML before writing parsing rules. The new Bash<br/>
scripts need an LF rule in `.gitattributes` to avoid Windows line-ending<br/>
problems encountered in earlier stages.

**Limitation:** The installer was syntax-checked but has not run on Ubuntu<br/>
in this revision. GitHub Actions validation is still required before calling<br/>
the refactored CI workflow verified.

#### Entry 019 - Immutable Kubernetes Image References

**Date:** 20 November 2026

**Objective:** Remove manual image version editing from Kubernetes releases.

I changed the Kustomize release overlay to use the SHA256 digest of the
published `v0.1.2` image. A version tag is easy to read but can point to a
different image later. A digest identifies the exact published image.

I also made a reusable Bash script to update Kustomize. It accepts the full
image reference, checks the input and supports repeated execution. This avoids
duplicating version replacement logic in different GitHub Actions workflows.

**Problem:** Windows had `kubectl`, but WSL could not find it. I installed
the Linux version in WSL to match the Ubuntu CI environment more closely.

**Verified:**

- Linux kubectl v1.36.1 and Kustomize v5.8.1 worked in WSL.
- Local and production Kubernetes manifest validation passed.
- The rendered deployment referenced the published SHA256 digest.
- Offline updater tests passed, including negative cases.

**Release evidence:** The `v0.1.2` GitHub Actions verification and publishing
jobs passed. GitHub Release records the image digest and source commit.
Local Kubernetes checks returned HTTP 200 for the frontend, static files and
REST API. The health endpoint returned `UP`, confirming that the earlier
frontend packaging problem was fixed. Screenshots are linked in README.
These checks do not prove that Kubernetes deployed the digest-based manifest.

**Next work:** Connect to GitHub Actions and verify the
automated release process. No automatic deployment has been implemented.

**Reflection:** Reusing small scripts makes the pipeline easier to test and
maintain. Digest-based deployments also make releases more reproducible.

#### Entry 020 - Automated Digest Release Pull Request

**Date:** 21 November 2026

**Objective:** Propose Kubernetes image updates without editing YAML manually.

I added a release step that reads the published digest and prepares a<br/>
Kustomize update on a separate branch. It creates a PR for human review and<br/>
explicitly dispatches Kubernetes manifest validation for that branch.

**Decision:** I reused the existing image updater instead of copying its<br/>
logic into GitHub Actions. A temporary Git worktree isolates the update.<br/>
Review, merge and deployment remain manual.

**Problem:** PRs created with `GITHUB_TOKEN` do not normally trigger other<br/>
PR workflows. I used `workflow_dispatch` to start manifest validation.

**GitHub configuration:** I enabled the repository setting that allows<br/>
GitHub Actions to create PRs. Default token permissions remain read-only.<br/>
Additional write permissions are scoped to the publishing job.

**Local verification:** Bash syntax and mocked Git/GitHub CLI tests passed.<br/>
The real release-to-PR workflow has not run yet. The screenshot documents<br/>
repository settings, not a successful automated PR.

**Reflection:** Reusing tested scripts kept the workflow smaller and made<br/>
offline validation possible without publishing an image or creating a PR.

#### Entry 021 - Kubernetes Rollback Verification

**Date:** 21 November 2026

**Objective:** Verify recovery from a failed Kubernetes image update.

I confirmed that the local Deployment was healthy on `v0.1.2`. I changed<br/>
the image to a nonexistent tag and observed `ErrImagePull`. I then ran<br/>
`kubectl rollout undo --to-revision=4`, which restored the working image.<br/>
The Deployment returned to 1/1 Ready at revision 6.

**Verification:** After rollback, `/`, `/index.html`, `/styles.css`,<br/>
`/app.js`, `/api/tasks` and `/actuator/health` all returned HTTP 200.<br/>
The health endpoint reported `UP`.

**Problem:** The `last-applied-configuration` annotation still pointed to<br/>
`v0.1.1`. Imperative rollback does not update this annotation, so I need<br/>
to check declarative configuration before future `kubectl apply` actions.

**Decision:** I added a read-only post-recovery verification script and<br/>
offline tests. This avoids repeatedly breaking the cluster merely to<br/>
verify the recovery checks. The live test was performed manually.

**Reflection:** Pod readiness alone is not enough; I verified the actual<br/>
frontend, API and health endpoints after recovery. The live cluster still<br/>
uses the version tag, so digest-based deployment remains unverified.

**Evidence:** `evidence/kubernetes-rollback-http-pass.png` shows the six<br/>
successful HTTP checks after recovery.

#### Entry 022 - Application Monitoring and Metrics

**Date:** 21 November 2026

**Objective:** Introduce measurable application health and performance.

**Implementation:** I added Micrometer Prometheus Registry and<br/>
configured Actuator to expose health and Prometheus metrics.<br/>
I also separated Kubernetes liveness and readiness checks and<br/>
increased probe timeouts to five seconds.

**Research:** Spring Boot documentation explained the available<br/>
metrics and registry configuration. Kubernetes documentation<br/>
helped me understand the different responsibilities of probes.

**Problem:** Prometheus worked in the running application but<br/>
returned HTTP 404 during integration testing.

**Decision:** I consulted the Spring Boot testing documentation<br/>
and added `@AutoConfigureMetrics` to enable metrics export<br/>
in the integration test environment.

**Verification:** All four monitoring tests and all nine existing<br/>
tests passed. Local HTTP checks confirmed health and metrics export.

**Reflection:** I learned that application availability and<br/>
application performance require different measurements.<br/>
Using Micrometer avoids implementing custom metrics collection.<br/>
I also learned that test auto-configuration can differ from<br/>
the configuration of a running application.

**Limitation:** Prometheus collection, Grafana dashboards and<br/>
live verification of the updated Kubernetes probes are pending.

**References:**

- [Spring Boot Metrics][entry022-metrics]
- [Spring Boot Integration Testing][entry022-tests]
- [Kubernetes Health Probes][entry022-probes]


### 3. Future Journal Entries

Each subsequent phase will record its objective, implementation, engineering<br/>
decisions, observed results, evidence, and limitations.

Do not record planned activities as completed work.

### 4. Task 4 Preparation

The reflective report will evaluate tool selection, architecture, engineering<br/>
trade-offs, the effects of automation, testing and security, and the benefits<br/>
and limits of collaboration and reproducible delivery.

The report will compare alternatives and justify future improvements using<br/>
evidence from validated project work.

[pass]: https://img.shields.io/badge/PASS-2ea44f?style=flat-square

[github-dependabot]: https://github.blog/engineering/platform-security/

[reddit-dependencies]: https://www.reddit.com/r/RedditEng/

[entry022-metrics]: https://docs.spring.io/spring-boot/reference/actuator/metrics.html

[entry022-tests]: https://docs.spring.io/spring-boot/4.1/reference/testing/spring-boot-applications.html

[entry022-probes]: https://kubernetes.io/docs/concepts/workloads/pods/probes/
