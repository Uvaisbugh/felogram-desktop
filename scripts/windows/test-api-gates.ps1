[CmdletBinding()]
param()
. (Join-Path $PSScriptRoot 'common.ps1')
$cmakeCommand = Get-Command cmake -ErrorAction SilentlyContinue
$cmake = if ($cmakeCommand) { $cmakeCommand.Source } else {
    $vcvars = Get-FelogramToolchain
    [IO.Path]::GetFullPath((Join-Path (Split-Path $vcvars) '..\..\..\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe'))
}
if (-not (Test-Path -LiteralPath $cmake)) { throw 'CMake is required for API gate checks.' }
$fixtureRoot = Join-Path ([IO.Path]::GetTempPath()) ('felogram-api-gates-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fixtureRoot | Out-Null
$canary = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
$cases = @(
    @{ Name='missing'; Json=$null; Mode='Account'; Pass=$false },
    @{ Name='empty'; Json='{"api_id":0,"api_hash":""}'; Mode='Account'; Pass=$false },
    @{ Name='malformed'; Json=('{"api_hash":"' + $canary + '",'); Mode='Account'; Pass=$false },
    @{ Name='out-of-range'; Json=('{"api_id":2147483648,"api_hash":"' + $canary + '"}'); Mode='Account'; Pass=$false },
    @{ Name='invalid-hash'; Json='{"api_id":123456,"api_hash":"bad"}'; Mode='Account'; Pass=$false },
    @{ Name='upstream-sample'; Json='{"api_id":17349,"api_hash":"344583e45741c457fe1862106095a5eb"}'; Mode='Account'; Pass=$false },
    @{ Name='synthetic-valid'; Json=('{"api_id":123456,"api_hash":"' + $canary + '"}'); Mode='Account'; Pass=$true },
    @{ Name='baseline'; Json=$null; Mode='Baseline'; Pass=$true },
    @{ Name='baseline-distribution'; Json=$null; Mode='Baseline'; Distribution=$true; Pass=$false }
)
$results = @()
foreach ($case in $cases) {
    $folder = Join-Path $fixtureRoot $case.Name
    New-Item -ItemType Directory -Path $folder | Out-Null
    $json = Join-Path $folder 'fixture.json'
    if ($null -ne $case.Json) { [IO.File]::WriteAllText($json, $case.Json, [Text.UTF8Encoding]::new($false)) }
    if ($case.Mode -eq 'Account') {
        $accepted = $false
        try { Get-FelogramApiConfiguration $json | Out-Null; $accepted = $true } catch {
            if ($_.Exception.Message.Contains($canary)) { throw 'PowerShell API validation exposed a fixture value.' }
        }
        if ($accepted -ne $case.Pass) { throw "PowerShell API gate mismatch: $($case.Name)" }
    }
    $cmakeJson = $json.Replace('\','/')
    $cmakeFolder = $folder.Replace('\','/')
    $module = (Join-Path $repoRoot 'Telegram\cmake\felogram_api.cmake').Replace('\','/')
    $distribution = if ($case.Distribution) { 'ON' } else { 'OFF' }
    $script = "cmake_minimum_required(VERSION 3.25)`nset(CMAKE_BINARY_DIR `"$cmakeFolder`")`nset(FELOGRAM_API_MODE $($case.Mode))`nset(FELOGRAM_API_CONFIG `"$cmakeJson`")`nset(FELOGRAM_DISTRIBUTION $distribution)`ninclude(`"$module`")`nfelogram_configure_api()`n"
    $scriptPath = Join-Path $folder 'check.cmake'
    [IO.File]::WriteAllText($scriptPath, $script, [Text.UTF8Encoding]::new($false))
    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $output = @(& $cmake -P $scriptPath 2>&1 | ForEach-Object { [string]$_ })
        $exitCode = $LASTEXITCODE
    } finally { $ErrorActionPreference = $previousPreference }
    if (($output -join "`n").Contains($canary)) { throw 'CMake API validation exposed a fixture value.' }
    if (($exitCode -eq 0) -ne $case.Pass) { throw "CMake API gate mismatch: $($case.Name)" }
    $results += [pscustomobject]@{ Case=$case.Name; Result='PASS' }
}
$results | Format-Table
Write-Output 'API gate fixtures passed without account authorization. Synthetic configuration never contacts Telegram.'
