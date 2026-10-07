[CmdletBinding()]
param(
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\..\out'),
    [ValidateRange(1, 16)][int]$Jobs = 2,
    [switch]$Reconfigure
)
. (Join-Path $PSScriptRoot 'common.ps1')
$vcvars = Get-FelogramToolchain
Get-FelogramSubmodules | Out-Null
Assert-FelogramDependencies | Out-Null
$outputRoot = [IO.Path]::GetFullPath($OutputPath)
$executable = Join-Path $outputRoot 'Debug\Felogram.exe'
$running = @(Get-Process Felogram -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $executable })
if ($running.Count -gt 0) { throw 'Quit this development executable from its tray menu before rebuilding. Other Telegram installations can remain open.' }
$cacheFile = Join-Path $outputRoot 'CMakeCache.txt'
if (Test-Path -LiteralPath $cacheFile) {
    $sourceEntries = @(Get-Content -LiteralPath $cacheFile | Where-Object { $_ -like 'CMAKE_HOME_DIRECTORY:INTERNAL=*' })
    if ($sourceEntries.Count -ne 1) { throw 'Existing CMake cache has no unique source root.' }
    $oldSource = ($sourceEntries[0] -split '=', 2)[1]
    if ([IO.Path]::GetFullPath($oldSource) -ne $repoRoot -and -not $Reconfigure) {
        throw 'The output belongs to another source checkout. Use -Reconfigure for an intentional CMake --fresh transition.'
    }
}
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
$buildLock = Open-FelogramBuildLock
try {
    $previousReceipt = Join-Path $outputRoot 'felogram-build.json'
    if (Test-Path -LiteralPath $previousReceipt) { Remove-Item -LiteralPath $previousReceipt }
    if ($Reconfigure -and (Test-Path -LiteralPath $cacheFile)) {
        $backup = Join-Path $outputRoot ('configuration-backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
        New-Item -ItemType Directory -Path $backup | Out-Null
        foreach ($file in @('CMakeCache.txt', 'build.ninja', 'build-Debug.ninja', '.ninja_log')) {
            $filePath = Join-Path $outputRoot $file
            if (Test-Path -LiteralPath $filePath) { Copy-Item -LiteralPath $filePath -Destination $backup }
        }
    }
    $fresh = if ($Reconfigure) { '--fresh ' } else { '' }
    $command = 'call "%FELOGRAM_VCVARS%" -vcvars_ver=14.44 && cmake ' + $fresh + '-S "%FELOGRAM_SOURCE%" -B "%FELOGRAM_OUTPUT%" -G "Ninja Multi-Config" -D CMAKE_BUILD_TYPE=Debug -D CMAKE_CONFIGURATION_TYPES=Debug -D TDESKTOP_API_TEST=ON -D DESKTOP_APP_DISABLE_AUTOUPDATE=ON -D DESKTOP_APP_DISABLE_CRASH_REPORTS=ON && cmake --build "%FELOGRAM_OUTPUT%" --config Debug --target Telegram --parallel %FELOGRAM_JOBS%'
    Invoke-FelogramNativeCommand $command @{
        FELOGRAM_VCVARS = $vcvars
        FELOGRAM_SOURCE = $repoRoot
        FELOGRAM_OUTPUT = $outputRoot
        FELOGRAM_JOBS = $Jobs
        QT = '6.11.2'
        CMAKE_BUILD_PARALLEL_LEVEL = $Jobs
        PSModulePath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\Modules;$env:ProgramFiles\WindowsPowerShell\Modules"
    }
    if (-not (Test-Path -LiteralPath $executable)) { throw 'Expected Debug executable is missing.' }
    $receipt = [ordered]@{
        builtAt = (Get-Date).ToUniversalTime().ToString('o')
        sourceRoot = $repoRoot
        sourceRevision = (& git -C $repoRoot rev-parse HEAD)
        submodules = @(Get-FelogramSubmodules)
        outputRoot = $outputRoot
        product = 'Felogram Dev'
        productVersion = '0.1.0-dev'
        executableName = 'Felogram.exe'
        configuration = 'Debug'
        architecture = 'x64'
        sha256 = (Get-FileHash -LiteralPath $executable -Algorithm SHA256).Hash
        testApi = $true
        distributionReady = $false
    }
    [IO.File]::WriteAllText((Join-Path $outputRoot 'felogram-build.json'), ($receipt | ConvertTo-Json -Depth 4), [Text.UTF8Encoding]::new($false))
    Write-Output "Built: $executable"
    Write-Output ('SHA-256: ' + $receipt.sha256)
} finally {
    $buildLock.Stream.Dispose()
    Remove-Item -LiteralPath $buildLock.Path
}
