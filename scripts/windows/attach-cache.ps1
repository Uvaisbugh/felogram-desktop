[CmdletBinding()]
param([Parameter(Mandatory = $true)][string]$CacheRoot)
. (Join-Path $PSScriptRoot 'common.ps1')
$cachePath = (Resolve-Path -LiteralPath $CacheRoot).Path
foreach ($directory in @('Libraries', 'ThirdParty')) {
    $target = Join-Path $cachePath $directory
    if (-not (Test-Path -LiteralPath $target -PathType Container)) { throw "Missing prepared cache directory: $target" }
    $link = Join-Path $workspaceRoot $directory
    if (Test-Path -LiteralPath $link) {
        $item = Get-Item -LiteralPath $link
        if ($item.LinkType -ne 'Junction' -or [IO.Path]::GetFullPath(@($item.Target)[0]) -ne [IO.Path]::GetFullPath($target)) {
            throw "Existing cache path has a different owner or target: $link"
        }
    } else {
        New-Item -ItemType Junction -Path $link -Target $target | Out-Null
    }
}
Assert-FelogramDependencies | Out-Null
Write-Output 'Prepared dependencies attached without copying or rebuilding them.'
