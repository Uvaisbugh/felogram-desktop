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

Build output and dependency caches are reused according to [the build guide](FELOGRAM_BUILD_WINDOWS.md). Results on 2026-10-07:

- Active CMake source: `E:/Explore/telgramRX/projects/felogram-desktop`; receipt source revision `04fa9c75853ce8e34b8a6d455da968e9d502b2b5`, with all 39 pinned recursive submodules recorded.
- Independent Debug compilation completed with exit 0 using the baseline compiler, SDK, Qt and generator above. Prepared dependency caches were reused without duplication.
- The inherited compiler PDB reached its limit during the first attempt. A scoped `COMPILE_PDB_NAME_DEBUG` change gave the application its own compiler database; all application objects were rebuilt consistently and the recovery completed successfully.
- Executable: 508,073,472 bytes; SHA-256 `01AB42DD362A045E12229992ED63A0C12B461033DDD32EF6915731F018FFB839`.
- Incremental helper invocation completed with exit 0 in 51.95 seconds, including configuration and build receipt generation. Ninja reported `no work to do`; the executable hash stayed unchanged.
- The independently built executable was opened and its welcome screen visually verified. Development profile: `projects/felogram-desktop/.local/profile`, with URL registration disabled. It retains upstream branding and test API configuration; it is not ready for distribution.
- Local evidence: `build/independent-desktop-pdb-recovery.log`, `build/independent-desktop-incremental.log`, and `build/tdesktop-baseline/out/felogram-build.json`. These generated artifacts remain outside tracked source.

This verifies an existing-cache setup on this PC. Fresh dependency preparation from the independent checkout, clean-machine setup and signed-in client journeys remain unverified.

## Dedicated native CI runner

- Date: 2026-10-07. Official GitHub Actions Windows x64 runner 2.337.0, installed under `D:/FelogramNativeRunner` with its own checkout/output tree.
- [Smoke run 37569850185](https://github.com/Uvaisbugh/felogram-desktop/actions/runs/37569850185) succeeded: source checkout, exact recursive submodules, prepared-cache attachment and native toolchain preflight.
- The single-job runner deregistered after completion; it is provisioned again for each owner-requested job. No Windows service was installed.
- Full native CI compilation and artifact upload were not run by this smoke check. Local native compilation is recorded separately.

## Compatibility scope

Felogram development testing currently covers only Windows 11 Home 10.0.26300 on x64. Windows 10, older Windows versions, ARM64, x86, clean-machine installation, multiple monitor/scaling combinations and production distribution are unverified. Upstream support statements are not automatically Felogram test results.
