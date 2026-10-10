[CmdletBinding()]
param(
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\..\out'),
    [string]$ProfilePath = '',
    [switch]$AllowBaseline
)
. (Join-Path $PSScriptRoot 'common.ps1')
if (Test-Path -LiteralPath (Join-Path $workspaceRoot '.felogram-native.lock')) { throw 'Finish the native build/preparation first.' }
$outputRoot = [IO.Path]::GetFullPath($OutputPath)
$executable = Join-Path $outputRoot 'Debug\Felogram.exe'
$receiptPath = Join-Path $outputRoot 'felogram-build.json'
if (-not (Test-Path -LiteralPath $receiptPath)) { throw 'Build from this checkout first; its build receipt is missing.' }
$receipt = Get-Content -LiteralPath $receiptPath -Raw | ConvertFrom-Json
if ($receipt.apiMode -notin @('Account', 'Baseline')) { throw 'Rebuild with the API mode controls before launching. Legacy baseline receipts cannot authorize account testing.' }
if ($receipt.apiMode -ne 'Account' -or -not $receipt.maintainerApiConfigured -or $receipt.testApi) {
    if (-not $AllowBaseline) { throw 'Account setup required. Configure your private API file and rebuild in Account mode. Use -AllowBaseline only for explicit UI baseline checks; never use the sample API for account testing.' }
} elseif ($AllowBaseline) { throw '-AllowBaseline cannot launch an Account build.' }
if ([IO.Path]::GetFullPath($receipt.sourceRoot) -ne $repoRoot) { throw 'The executable was built from a different checkout.' }
if (-not (Test-Path -LiteralPath $executable)) { throw 'Debug executable is missing.' }
if ((Get-FileHash -LiteralPath $executable -Algorithm SHA256).Hash -ne $receipt.sha256) { throw 'Executable hash differs from the successful build receipt. Rebuild before launching.' }
if (-not $ProfilePath) { $ProfilePath = Join-Path $repoRoot $(if ($AllowBaseline) { '.local\felogram-baseline' } else { '.local\felogram-account' }) }
$profileRoot = [IO.Path]::GetFullPath($ProfilePath)
if (-not $profileRoot.StartsWith((Join-Path $repoRoot '.local') + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'Use a separate owned profile inside this checkout .local directory. Official Telegram profiles must not be imported or modified.' }
if ($profileRoot -eq (Join-Path $repoRoot '.local\felogram-dev') -or
    (-not $AllowBaseline -and $profileRoot -eq (Join-Path $repoRoot '.local\felogram-baseline')) -or
    ($AllowBaseline -and $profileRoot -eq (Join-Path $repoRoot '.local\felogram-account'))) { throw 'Use a separate profile for this API mode. Legacy, baseline and account profiles must not be mixed.' }
New-Item -ItemType Directory -Path $profileRoot -Force | Out-Null
if (-not $AllowBaseline) { Protect-FelogramPrivatePath $profileRoot }
$dataRoot = Join-Path $profileRoot 'tdata'
New-Item -ItemType Directory -Path $dataRoot -Force | Out-Null
$optionsPath = Join-Path $dataRoot 'experimental_options.json'
$options = if (Test-Path -LiteralPath $optionsPath) { Get-Content -LiteralPath $optionsPath -Raw | ConvertFrom-Json } else { [pscustomobject]@{} }
if ($options -isnot [pscustomobject]) { throw 'Unexpected profile-options structure.' }
$options | Add-Member -NotePropertyName 'skip-url-scheme-register' -NotePropertyValue $true -Force
[IO.File]::WriteAllText($optionsPath, ($options | ConvertTo-Json -Depth 32), [Text.UTF8Encoding]::new($false))
Write-Output 'Opening Felogram Dev with an isolated development profile.'
Start-Process -FilePath $executable -ArgumentList @('-workdir', ('"' + $profileRoot + '"')) -WorkingDirectory $profileRoot -PassThru | Select-Object Id, ProcessName
