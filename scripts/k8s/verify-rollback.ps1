# Read-only verification of a Kubernetes Deployment after rollback.
# Requires an existing kubectl port-forward on the selected BaseUrl.
[CmdletBinding()]
param(
    [string]$BaseUrl = 'http://127.0.0.1:18080',
    [string]$ExpectedImage = 'ghcr.io/maxvanny2010/atu-devops-pipeline:v0.1.2'
)

$ErrorActionPreference = 'Stop'

if ($BaseUrl -notmatch '^http://127\.0\.0\.1:[0-9]{1,5}$') {
    throw 'BaseUrl must be an HTTP loopback address with a port.'
}
if ($ExpectedImage -notmatch '^ghcr\.io/maxvanny2010/atu-devops-pipeline(:v[0-9]+\.[0-9]+\.[0-9]+|@sha256:[0-9a-f]{64})$') {
    throw 'Unexpected expected image reference.'
}

$context = kubectl config current-context
if ($LASTEXITCODE -ne 0 -or $context -ne 'docker-desktop') {
    throw 'The current Kubernetes context is not docker-desktop.'
}

$json = kubectl -n default get deployment task-manager -o json
if ($LASTEXITCODE -ne 0) {
    throw 'Could not read the task-manager Deployment.'
}
$deployment = $json | Out-String | ConvertFrom-Json
$containers = @($deployment.spec.template.spec.containers)
if ($containers.Count -ne 1 -or $containers[0].name -ne 'task-manager') {
    throw 'Unexpected Deployment container configuration.'
}
if ($containers[0].image -cne $ExpectedImage) {
    throw "Wrong Deployment image: $($containers[0].image)"
}
if ($deployment.spec.replicas -ne 1 -or
    $deployment.status.readyReplicas -ne 1 -or
    $deployment.status.availableReplicas -ne 1 -or
    $deployment.status.updatedReplicas -ne 1) {
    throw 'Deployment does not have exactly one updated, ready and available replica.'
}
Write-Host "PASS: Deployment image and readiness ($ExpectedImage)" -ForegroundColor Green

$paths = @('/', '/index.html', '/styles.css', '/app.js',
           '/api/tasks', '/actuator/health')
foreach ($path in $paths) {
    $uri = "$BaseUrl$path"
    try {
        $response = Invoke-WebRequest -Uri $uri -UseBasicParsing `
            -TimeoutSec 10 -ErrorAction Stop
    }
    catch {
        throw "HTTP request failed for $path : $($_.Exception.Message)"
    }
    if ($response.StatusCode -ne 200) {
        throw "Unexpected HTTP response for $path : $($response.StatusCode)"
    }
    if ($path -eq '/actuator/health') {
        $health = $response.Content | ConvertFrom-Json
        if ($health.status -ne 'UP') {
            throw "Health status is not UP: $($health.status)"
        }
    }
    Write-Host "PASS: HTTP 200 $path" -ForegroundColor Green
}

$annotation = $deployment.metadata.annotations.'kubectl.kubernetes.io/last-applied-configuration'
if ($annotation) {
    $lastApplied = $annotation | ConvertFrom-Json
    $previous = @($lastApplied.spec.template.spec.containers)[0].image
    if ($previous -cne $ExpectedImage) {
        Write-Warning "Last-applied image differs: $previous"
        Write-Warning 'Review declarative configuration before future kubectl apply.'
    }
}
Write-Host 'PASS: POST-ROLLBACK VERIFICATION COMPLETE' -ForegroundColor Green
