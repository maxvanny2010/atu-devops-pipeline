# Offline tests: kubectl and HTTP requests are mocked. No cluster is contacted.
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$scriptPath = Join-Path $PSScriptRoot 'verify-rollback.ps1'
if (-not (Test-Path -LiteralPath $scriptPath)) { throw 'Verifier is missing.' }
$expected = 'ghcr.io/maxvanny2010/atu-devops-pipeline:v0.1.2'
$global:mockImage = $expected
$global:mockContext = 'docker-desktop'
$global:mockFailPath = ''
$global:mockHealth = 'UP'
$global:requests = 0

function kubectl {
    $global:LASTEXITCODE = 0
    if ($args.Count -eq 2 -and $args[0] -eq 'config' -and
        $args[1] -eq 'current-context') { return $global:mockContext }
    if ($args.Count -eq 6 -and $args[0] -eq '-n' -and
        $args[1] -eq 'default' -and $args[2] -eq 'get' -and
        $args[3] -eq 'deployment' -and $args[4] -eq 'task-manager' -and
        $args[5] -eq '-o') { throw 'Unexpected kubectl call.' }
    if ($args.Count -eq 7 -and $args[0] -eq '-n' -and
        $args[1] -eq 'default' -and $args[2] -eq 'get' -and
        $args[3] -eq 'deployment' -and $args[4] -eq 'task-manager' -and
        $args[5] -eq '-o' -and $args[6] -eq 'json') {
        return (@{
            spec = @{ replicas = 1; template = @{
                spec = @{ containers = @(@{name='task-manager';image=$global:mockImage}) }
            }}
            status = @{ readyReplicas = 1; availableReplicas = 1; updatedReplicas = 1 }
            metadata = @{ annotations = @{
                'kubectl.kubernetes.io/last-applied-configuration' =
                    '{"spec":{"template":{"spec":{"containers":[{"image":"ghcr.io/maxvanny2010/atu-devops-pipeline:v0.1.1"}]}}}}'
            }}
        } | ConvertTo-Json -Depth 12)
    }
    throw "Unexpected kubectl invocation: $($args -join ' ')"
}

function Invoke-WebRequest {
    param([string]$Uri, [switch]$UseBasicParsing,
          [int]$TimeoutSec, [object]$ErrorAction)
    $global:requests++
    if ($Uri.EndsWith($global:mockFailPath) -and $global:mockFailPath) {
        throw 'Simulated HTTP error'
    }
    $content = if ($Uri.EndsWith('/actuator/health')) {
        '{"status":"' + $global:mockHealth + '"}'
    } else { '{}' }
    return [pscustomobject]@{ StatusCode = 200; Content = $content }
}

function Expect-Failure {
    param([string]$Label)
    $failed = $false
    try { & $scriptPath -ExpectedImage $expected | Out-Null }
    catch { $failed = $true }
    if (-not $failed) { throw "Expected rejection did not occur: $Label" }
    Write-Host "PASS: rejected $Label"
}

& $scriptPath -ExpectedImage $expected | Out-Null
if ($global:requests -ne 6) { throw 'Expected exactly six HTTP requests.' }
Write-Host 'PASS: working image and six HTTP responses'

$global:mockImage = 'ghcr.io/maxvanny2010/atu-devops-pipeline:v0.1.1'
Expect-Failure 'wrong image'
$global:mockImage = $expected
$global:mockContext = 'unexpected-context'
Expect-Failure 'wrong Kubernetes context'
$global:mockContext = 'docker-desktop'
$global:mockFailPath = '/app.js'
Expect-Failure 'HTTP connection error'
$global:mockFailPath = ''
$global:mockHealth = 'DOWN'
Expect-Failure 'unhealthy Actuator status'
Write-Host 'PASS: offline rollback-verification tests'
