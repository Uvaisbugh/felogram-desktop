[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$required = @('README.md', 'FELOGRAM.md', 'ROADMAP.md', 'CONTRIBUTING.md', 'SECURITY.md', 'docs\FELOGRAM_BUILD_WINDOWS.md', 'docs\WINDOWS_BASELINE.md', 'LICENSE', 'LEGAL')
foreach ($file in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $file))) { throw "Missing contributor/release document: $file" }
}
foreach ($script in Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.ps1') {
    $parseErrors = $null
    $tokens = $null
    $ast = [Management.Automation.Language.Parser]::ParseFile($script.FullName, [ref]$tokens, [ref]$parseErrors)
    if ($parseErrors.Count -gt 0) { throw ($parseErrors | Out-String) }
    $reservedWrites = $ast.FindAll({
        param($node)
        $node -is [Management.Automation.Language.AssignmentStatementAst] -and
        $node.Left -is [Management.Automation.Language.VariableExpressionAst] -and
        $node.Left.VariablePath.UserPath -match '^(HOME|CODEX_HOME|PID|PSHOME|Host|Error)$'
    }, $true)
    if ($reservedWrites.Count -gt 0) { throw "Reserved system-variable assignment in $($script.Name)." }
}
$manifest = Join-Path $root 'docs\windows-submodules.txt'
$modules = @(Get-Content -LiteralPath $manifest)
if ($modules.Count -eq 0 -or @($modules | Where-Object { $_ -notmatch '^ [0-9a-f]{40} ' }).Count -gt 0) { throw 'Invalid or uninitialized pinned submodule manifest.' }
$oldPath = $env:PATH
try {
    $gitPath = (Get-Command git).Source
    $gitUsr = [IO.Path]::GetFullPath((Join-Path (Split-Path $gitPath) '..\usr\bin'))
    if (Test-Path -LiteralPath $gitUsr) { $env:PATH = "$gitUsr;$oldPath" }
    $status = @(& git -C $root ls-files)
    if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect tracked paths.' }
    if (@($status | Where-Object { $_ -match '(^|/)(\.env|\.felogram\.properties|custom_api_id\.h)$|\.(pfx|p12)$|^\.local/' }).Count -gt 0) { throw 'Private configuration or signing files are tracked.' }
} finally { $env:PATH = $oldPath }
Write-Output 'Repository documents, PowerShell syntax, reserved variables, pinned manifest and private-path checks passed. Native compilation is a separate check.'
