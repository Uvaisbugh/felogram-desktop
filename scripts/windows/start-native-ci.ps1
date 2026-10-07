[CmdletBinding()]
param(
    [string]$RunnerRoot = 'D:\FelogramNativeRunner',
    [ValidateSet('smoke', 'build')][string]$Mode = 'smoke'
)
$ErrorActionPreference = 'Stop'
$runnerPath = (Resolve-Path -LiteralPath $RunnerRoot).Path
if (-not (Test-Path -LiteralPath (Join-Path $runnerPath '.runner'))) { throw 'Provision the single-job runner before starting native CI.' }
$activeRuns = & gh run list --repo Uvaisbugh/felogram-desktop --workflow felogram-native.yml --status in_progress --json databaseId | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect active native jobs.' }
if (@($activeRuns).Count -gt 0) { throw 'A native workflow is already running.' }
& gh workflow run felogram-native.yml --repo Uvaisbugh/felogram-desktop --ref main -f "mode=$Mode"
if ($LASTEXITCODE -ne 0) { throw 'Native workflow dispatch failed.' }
$arguments = '/d /c ""' + (Join-Path $runnerPath 'run.cmd') + '" --once"'
$process = Start-Process -FilePath "$env:SystemRoot\System32\cmd.exe" -ArgumentList $arguments -WorkingDirectory $runnerPath -WindowStyle Hidden -RedirectStandardOutput (Join-Path $runnerPath 'listener.out.log') -RedirectStandardError (Join-Path $runnerPath 'listener.err.log') -PassThru
Write-Output "Single-job native runner started (PID $($process.Id)). Its output tree is separate from the development app."
