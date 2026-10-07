# Windows foundation evidence

## Verified original baseline

- Upstream source: `d8594c011756265de4385408540bd9f7c787a003`.
- Date: 2026-10-06; Windows 11 Home 10.0.26300, x64; 16 GB installed RAM.
- Compiler: MSVC 14.44.35207, selected through VS 18 Build Tools `vcvars64.bat -vcvars_ver=14.44`.
- SDK: 10.0.26100.0; Qt: 6.11.2 Debug; generator: Ninja Multi-Config.
- All 32 dependency preparation stages completed. Native target `Telegram`, Debug, exit 0.
- Executable: 508,063,744 bytes; SHA-256 `1D6A696BC43565BF6D0520EF67C764A3927CA1957B7689B5547D7ECA800AFEC0`.
- Startup: the upstream Telegram welcome screen was visually verified and brought to the foreground with a separate profile and URL registration disabled.
- No login, messaging, notification or accessibility claims follow from this startup check.

## Independent checkout

Active source: `projects/felogram-desktop`, with all 39 recursive submodules checked out to their pinned revisions. See [the submodule manifest](windows-submodules.txt). The manifest must be refreshed and validated when gitlinks change.

Build output and dependency caches are reused according to [the build guide](FELOGRAM_BUILD_WINDOWS.md). Independent compilation, incremental build and startup results will be recorded here after each verification completes. They remain pending until that evidence is added.

## Compatibility scope

Felogram development testing currently covers only Windows 11 Home 10.0.26300 on x64. Windows 10, older Windows versions, ARM64, x86, clean-machine installation, multiple monitor/scaling combinations and production distribution are unverified. Upstream support statements are not automatically Felogram test results.
