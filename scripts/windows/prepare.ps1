[CmdletBinding()]
param([ValidateRange(1, 16)][int]$Jobs = 2)
. (Join-Path $PSScriptRoot 'common.ps1')
$vcvars = Get-FelogramToolchain
Get-FelogramSubmodules | Out-Null
$buildLock = Open-FelogramBuildLock
try {
    Invoke-FelogramNativeCommand 'call "%FELOGRAM_VCVARS%" -vcvars_ver=14.44 && python -u "%FELOGRAM_PREPARE%" qt6 skip-release silent' @{
        FELOGRAM_VCVARS = $vcvars
        FELOGRAM_PREPARE = Join-Path $repoRoot 'Telegram\build\prepare\prepare.py'
        CMAKE_BUILD_PARALLEL_LEVEL = $Jobs
        PSModulePath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\Modules;$env:ProgramFiles\WindowsPowerShell\Modules"
    }
} finally {
    $buildLock.Stream.Dispose()
    Remove-Item -LiteralPath $buildLock.Path
}
