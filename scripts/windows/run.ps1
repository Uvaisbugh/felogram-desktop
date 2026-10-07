[CmdletBinding()]
param(
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\..\out'),
    [string]$ProfilePath = (Join-Path $PSScriptRoot '..\..\.local\felogram-dev')
)
. (Join-Path $PSScriptRoot 'common.ps1')
if (Test-Path -LiteralPath (Join-Path $workspaceRoot '.felogram-native.lock')) { throw 'Finish the native build/preparation first.' }
$outputRoot = [IO.Path]::GetFullPath($OutputPath)
$executable = Join-Path $outputRoot 'Debug\Felogram.exe'
$receiptPath = Join-Path $outputRoot 'felogram-build.json'
if (-not (Test-Path -LiteralPath $receiptPath)) { throw 'Build from this checkout first; its build receipt is missing.' }
$receipt = Get-Content -LiteralPath $receiptPath -Raw | ConvertFrom-Json
if ([IO.Path]::GetFullPath($receipt.sourceRoot) -ne $repoRoot) { throw 'The executable was built from a different checkout.' }
if (-not (Test-Path -LiteralPath $executable)) { throw 'Debug executable is missing.' }
if ((Get-FileHash -LiteralPath $executable -Algorithm SHA256).Hash -ne $receipt.sha256) { throw 'Executable hash differs from the successful build receipt. Rebuild before launching.' }
$profileRoot = [IO.Path]::GetFullPath($ProfilePath)
$dataRoot = Join-Path $profileRoot 'tdata'
New-Item -ItemType Directory -Path $dataRoot -Force | Out-Null
$optionsPath = Join-Path $dataRoot 'experimental_options.json'
$options = if (Test-Path -LiteralPath $optionsPath) { Get-Content -LiteralPath $optionsPath -Raw | ConvertFrom-Json } else { [pscustomobject]@{} }
if ($options -isnot [pscustomobject]) { throw 'Unexpected profile-options structure.' }
$options | Add-Member -NotePropertyName 'skip-url-scheme-register' -NotePropertyValue $true -Force
[IO.File]::WriteAllText($optionsPath, ($options | ConvertTo-Json -Depth 32), [Text.UTF8Encoding]::new($false))
Write-Output 'Opening Felogram Dev with an isolated development profile.'
Start-Process -FilePath $executable -ArgumentList @('-workdir', ('"' + $profileRoot + '"')) -WorkingDirectory $profileRoot -PassThru | Select-Object Id, ProcessName
