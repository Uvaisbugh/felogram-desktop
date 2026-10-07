[CmdletBinding()]
param([switch]$RequireDependencies)
. (Join-Path $PSScriptRoot 'common.ps1')
$vcvars = Get-FelogramToolchain
$modules = @(Get-FelogramSubmodules)
$libraries = if ($RequireDependencies) { Assert-FelogramDependencies } else { Join-Path $workspaceRoot 'Libraries\win64' }
$source = & git -C $repoRoot rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw 'Cannot read source revision.' }
[ordered]@{
    sourceRoot = $repoRoot
    sourceRevision = $source
    architecture = 'x64'
    configuration = 'Debug'
    vcvars = $vcvars
    sdk = '10.0.26100.0'
    qt = '6.11.2'
    submoduleCount = $modules.Count
    dependencyRoot = $libraries
    dependenciesRequired = [bool]$RequireDependencies
    nativeBuildVerified = $false
} | ConvertTo-Json
