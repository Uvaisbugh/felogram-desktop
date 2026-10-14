[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$QtPrefixPath,
    [string]$ZlibPath = (Join-Path $QtPrefixPath "../zlib"),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\..\.local\workspace-tests')
)
. (Join-Path $PSScriptRoot 'common.ps1')
$vcvars = Get-FelogramToolchain
$command = 'call "%FELOGRAM_VCVARS%" -vcvars_ver=14.44 && cmake -S "%FELOGRAM_TEST_SOURCE%" -B "%FELOGRAM_TEST_OUTPUT%" -G "Ninja Multi-Config" -D CMAKE_CONFIGURATION_TYPES=Debug -D CMAKE_PREFIX_PATH="%FELOGRAM_TEST_QT%" -D ZLIB_INCLUDE_DIR="%FELOGRAM_TEST_ZLIB%" -D ZLIB_LIBRARY_DEBUG="%FELOGRAM_TEST_ZLIB%/Debug/libzsd.lib" -D ZLIB_LIBRARY_RELEASE="%FELOGRAM_TEST_ZLIB%/Release/libzs.lib" && cmake --build "%FELOGRAM_TEST_OUTPUT%" --config Debug --parallel 2 && ctest --test-dir "%FELOGRAM_TEST_OUTPUT%" -C Debug --output-on-failure'
Invoke-FelogramNativeCommand $command @{
    FELOGRAM_VCVARS = $vcvars
    FELOGRAM_TEST_SOURCE = (Join-Path $repoRoot 'scripts/testing/workspaces')
    FELOGRAM_TEST_OUTPUT = [IO.Path]::GetFullPath($OutputPath)
    FELOGRAM_TEST_ZLIB = [IO.Path]::GetFullPath($ZlibPath)
    FELOGRAM_TEST_QT = [IO.Path]::GetFullPath($QtPrefixPath)
}
