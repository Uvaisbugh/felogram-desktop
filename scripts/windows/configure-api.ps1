[CmdletBinding()]
param([switch]$OpenEditor)
. (Join-Path $PSScriptRoot 'common.ps1')
$configurationPath = Join-Path $repoRoot '.local\telegram-api.local.json'
New-Item -ItemType Directory -Force (Split-Path -Parent $configurationPath) | Out-Null
if (-not (Test-Path -LiteralPath $configurationPath)) {
    [IO.File]::WriteAllText($configurationPath, "{`r`n  `"api_id`": 0,`r`n  `"api_hash`": `"`"`r`n}`r`n", [Text.UTF8Encoding]::new($false))
}
& git -C $repoRoot check-ignore --quiet .local/telegram-api.local.json
if ($LASTEXITCODE -ne 0) { throw 'Private API file is not ignored by Git. Fix that before entering credentials.' }
Protect-FelogramPrivatePath $configurationPath
Write-Output 'Private API file is ready and restricted to your Windows account and SYSTEM.'
Write-Output 'Enter maintainer-owned api_id and api_hash directly in .local/telegram-api.local.json. Never put values or account verification codes in issues, chat or commands.'
if ($OpenEditor) { Start-Process notepad.exe -ArgumentList ('"' + $configurationPath + '"') }
