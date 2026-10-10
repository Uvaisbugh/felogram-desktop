$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$workspaceRoot = Split-Path -Parent $repoRoot

function Get-FelogramApiConfiguration([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw 'Felogram account setup required. Run scripts/windows/configure-api.ps1, enter your own API values in its private file, then build again. No baseline fallback is enabled.'
    }
    try { $configuration = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json } catch {
        throw 'Private API configuration is not valid JSON. Values were not logged.'
    }
    $apiId = [string]$configuration.api_id
    $apiHash = [string]$configuration.api_hash
    if ($apiId -notmatch '^[1-9][0-9]{0,9}$' -or [long]$apiId -gt [int]::MaxValue -or $apiHash -notmatch '^[0-9a-fA-F]{32}$') {
        throw 'Account setup requires a positive 32-bit api_id and a 32-character hexadecimal api_hash. Values were not logged.'
    }
    if ($apiId -eq '17349' -or $apiHash -eq '344583e45741c457fe1862106095a5eb') {
        throw 'Account testing requires maintainer-owned API configuration; the upstream sample is reserved for explicit Baseline mode.'
    }
    return [pscustomobject]@{ Path = [IO.Path]::GetFullPath($Path); Mode = 'Account'; Configured = $true }
}

function Protect-FelogramPrivatePath([string]$Path) {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent().User
    $acl = Get-Acl -LiteralPath $Path
    $acl.SetAccessRuleProtection($true, $false)
    foreach ($rule in @($acl.Access)) { $acl.RemoveAccessRuleSpecific($rule) }
    $acl.SetOwner($identity)
    $system = [Security.Principal.SecurityIdentifier]::new('S-1-5-18')
    foreach ($principal in @($identity, $system)) {
        $rule = if (Test-Path -LiteralPath $Path -PathType Container) {
            [Security.AccessControl.FileSystemAccessRule]::new($principal, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
        } else {
            [Security.AccessControl.FileSystemAccessRule]::new($principal, 'FullControl', 'Allow')
        }
        $acl.AddAccessRule($rule)
    }
    Set-Acl -LiteralPath $Path -AclObject $acl
}

function Get-FelogramToolchain {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (-not (Test-Path -LiteralPath $vswhere)) { throw 'Install Visual Studio C++ Build Tools, MSVC 14.44 and Windows SDK 10.0.26100.0.' }
    $installations = @(& $vswhere -all -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -format json | ConvertFrom-Json)
    if ($LASTEXITCODE -ne 0) { throw 'Visual Studio inventory failed.' }
    $compiler = $installations | Where-Object {
        @(Get-ChildItem (Join-Path $_.installationPath 'VC\Tools\MSVC') -Directory -Filter '14.44.*' -ErrorAction SilentlyContinue).Count -gt 0
    } | Select-Object -First 1
    if (-not $compiler) { throw 'MSVC 14.44 is required for this pinned source; a newer default toolset does not replace it.' }
    $sdk = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits\10\Lib\10.0.26100.0\um\x64\kernel32.lib'
    if (-not (Test-Path -LiteralPath $sdk)) { throw 'Windows SDK 10.0.26100.0 x64 is missing.' }
    foreach ($command in @('git', 'python')) {
        if (-not (Get-Command $command -ErrorAction SilentlyContinue)) { throw "$command is missing from PATH." }
    }
    $cmakeRoot = Join-Path $compiler.installationPath 'Common7\IDE\CommonExtensions\Microsoft\CMake'
    if (-not (Get-Command cmake -ErrorAction SilentlyContinue) -and -not (Test-Path -LiteralPath (Join-Path $cmakeRoot 'CMake\bin\cmake.exe'))) { throw 'Install the Visual Studio CMake tools component.' }
    if (-not (Get-Command ninja -ErrorAction SilentlyContinue) -and -not (Test-Path -LiteralPath (Join-Path $cmakeRoot 'Ninja\ninja.exe'))) { throw 'Install the Visual Studio Ninja tools component.' }
    return (Join-Path $compiler.installationPath 'VC\Auxiliary\Build\vcvars64.bat')
}

function Get-FelogramSubmodules {
    $oldPath = $env:PATH
    try {
        $gitPath = (Get-Command git -ErrorAction Stop).Source
        $gitUsr = [IO.Path]::GetFullPath((Join-Path (Split-Path $gitPath) '..\usr\bin'))
        if (Test-Path -LiteralPath $gitUsr) { $env:PATH = "$gitUsr;$oldPath" }
        $modules = @(& git -C $repoRoot submodule status --recursive)
        if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect submodules.' }
        if ($modules.Count -eq 0 -or @($modules | Where-Object { $_ -match '^[-+U]' }).Count -gt 0) {
            throw 'Initialize the exact pinned submodules: git submodule update --init --recursive --depth 1'
        }
        return $modules
    } finally { $env:PATH = $oldPath }
}

function Assert-FelogramDependencies {
    $libraryRoot = Join-Path $workspaceRoot 'Libraries\win64'
    foreach ($key in @('qt_6.11.2', 'tg_owt', 'ada', 'tde2e', 'tlottie')) {
        if (-not (Test-Path -LiteralPath (Join-Path $libraryRoot "cache_keys\$key"))) {
            throw "Prepared dependency $key is missing. Run scripts/windows/prepare.ps1 first."
        }
    }
    return $libraryRoot
}

function Invoke-FelogramNativeCommand([string]$Command, [hashtable]$Settings) {
    $previous = @{}
    try {
        foreach ($key in $Settings.Keys) {
            $previous[$key] = [Environment]::GetEnvironmentVariable($key, 'Process')
            [Environment]::SetEnvironmentVariable($key, [string]$Settings[$key], 'Process')
        }
        & "$env:SystemRoot\System32\cmd.exe" /d /v:off /c $Command
        if ($LASTEXITCODE -ne 0) { throw "Native command failed with exit code $LASTEXITCODE." }
    } finally {
        foreach ($key in $previous.Keys) { [Environment]::SetEnvironmentVariable($key, $previous[$key], 'Process') }
    }
}

function Open-FelogramBuildLock {
    $lockPath = Join-Path $workspaceRoot '.felogram-native.lock'
    $stream = [IO.File]::Open($lockPath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
    return [pscustomobject]@{ Path = $lockPath; Stream = $stream }
}
