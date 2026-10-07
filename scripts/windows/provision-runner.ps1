[CmdletBinding()]
param([string]$RunnerRoot = 'D:\FelogramNativeRunner')
$ErrorActionPreference = 'Stop'
$runnerPath = [IO.Path]::GetFullPath($RunnerRoot)
if ($runnerPath -eq [IO.Path]::GetPathRoot($runnerPath)) { throw 'Choose a dedicated runner folder, not a drive root.' }
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw 'GitHub CLI authentication is required.' }
New-Item -ItemType Directory -Path $runnerPath -Force | Out-Null
if (Test-Path -LiteralPath (Join-Path $runnerPath '.runner')) { throw 'This runner is already registered; finish its current job before provisioning again.' }
if (-not (Test-Path -LiteralPath (Join-Path $runnerPath 'config.cmd'))) {
    $release = & gh api repos/actions/runner/releases/latest | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0) { throw 'Cannot read the official GitHub runner release.' }
    $asset = @($release.assets | Where-Object { $_.name -match '^actions-runner-win-x64-[0-9.]+\.zip$' })
    if ($asset.Count -ne 1 -or $asset[0].digest -notmatch '^sha256:[0-9a-f]{64}$') { throw 'Official runner package checksum is unavailable.' }
    $zipPath = Join-Path $runnerPath $asset[0].name
    Invoke-WebRequest -Uri $asset[0].browser_download_url -OutFile $zipPath
    $digest = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ('sha256:' + $digest -ne $asset[0].digest) { throw 'Runner package checksum verification failed.' }
    Expand-Archive -LiteralPath $zipPath -DestinationPath $runnerPath
    [IO.File]::WriteAllText((Join-Path $runnerPath 'felogram-package.json'), (@{ version = $release.tag_name; sha256 = $digest } | ConvertTo-Json), [Text.UTF8Encoding]::new($false))
}
$registration = & gh api --method POST repos/Uvaisbugh/felogram-desktop/actions/runners/registration-token | ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or -not $registration.token) { throw 'Runner registration could not be authorized.' }
Push-Location $runnerPath
try {
    & (Join-Path $runnerPath 'config.cmd') --unattended --url https://github.com/Uvaisbugh/felogram-desktop --token $registration.token --name felogram-native-windows --labels felogram-native --work _work --ephemeral
    if ($LASTEXITCODE -ne 0) { throw 'Official runner configuration failed.' }
} finally {
    $registration = $null
    Pop-Location
}
Write-Output 'Dedicated repository runner registered. It remains offline until a trusted main-branch manual job is started; each registration accepts one job.'
