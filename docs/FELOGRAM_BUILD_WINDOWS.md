# Build Felogram Desktop on Windows

This guide builds the upstream-branded **x64 Debug development baseline**, not a production Felogram release. Development uses the upstream limited test API configuration; maintainer API configuration and independent branding are later milestones. Never enter Telegram account codes or credentials in build logs.

## Prerequisites

- Windows x64. The local baseline has been exercised on Windows 11 Home, build 10.0.26300 only; other Windows versions and architectures are unverified for Felogram.
- Git for Windows and Python 3. The verified host used Python 3.14.7; see upstream `building-win.md` for its recommended Python version.
- Visual Studio C++ Build Tools with **MSVC 14.44**, SDK **10.0.26100.0**, and CMake/Ninja tools. The tested host used Visual Studio 18 Build Tools with side-by-side MSVC 14.44.35207. Installing a newer compiler alone does not satisfy this pinned baseline.
- Enough disk space and time: the first prepared dependency/native build is large and can take hours. This PC's native output tree is about 26 GB, excluding dependencies. Start with two workers on a 16 GB host; four were used for the verified local app build.
- Review and accept relevant SDK/tool licenses yourself. The scripts do not install system components or approve prompts.

## Fresh setup

Use a workspace with the source as a direct child; upstream preparation locates dependencies beside the source checkout:

```text
DesktopWork/
  felogram-desktop/
  Libraries/win64/
  ThirdParty/
```

```powershell
git clone https://github.com/Uvaisbugh/felogram-desktop.git DesktopWork/felogram-desktop
Set-Location DesktopWork/felogram-desktop
git config core.longpaths true
git submodule update --init --recursive --depth 1
./scripts/windows/check.ps1
./scripts/windows/prepare.ps1 -Jobs 2
./scripts/windows/check.ps1 -RequireDependencies
./scripts/windows/build.ps1 -Jobs 2
./scripts/windows/run.ps1
```

Run from PowerShell with an execution policy that permits scripts you have reviewed. Preflight is read-only and reports missing compiler/SDK/source prerequisites. It does not prove a successful native build. Preparation initializes MSVC in a child shell, uses upstream's `qt6 skip-release silent` path and preserves completed dependency caches. The upstream preparation script may build optimized third-party libraries as part of its Debug dependency set; the application target here is Debug only.

The build helper restores process environment values, selects MSVC 14.44 explicitly, uses Ninja Multi-Config and produces `out/Debug/Telegram.exe`. Its `out/felogram-build.json` records source/submodule revisions and the executable SHA-256. A launch requires a receipt for this checkout, uses `.local/profile`, and seeds `skip-url-scheme-register=true` before startup so development does not claim Telegram URL associations.

## Existing cache layout on the development PC

The active source is `E:/Explore/telgramRX/projects/felogram-desktop`. Dependencies were already prepared under `E:/Explore/telgramRX/build`; directory junctions expose them under `projects/` without duplication:

```text
projects/Libraries  -> ../build/Libraries
projects/ThirdParty -> ../build/ThirdParty
```

The existing native output directory is reused to avoid a second 26 GB tree. The old baseline source remains for historical evidence, but CMake is reconfigured to compile the independent source checkout. Quit only the development executable, including its tray process, before rebuilding.

From the independent repository, the one-time transition is:

```powershell
./scripts/windows/build.ps1 -OutputPath E:/Explore/telgramRX/build/tdesktop-baseline/out -Jobs 4 -Reconfigure
```

`-Reconfigure` backs up CMake's configuration files, then uses `cmake --fresh`; it does not delete dependency libraries or account profiles. Absolute source-path changes cause application objects to rebuild. Later builds omit `-Reconfigure`:

The Windows application target uses a Felogram-specific compiler PDB name. This keeps its compiler debug database separate from an inherited upstream `vc140.pdb` during a shared-output transition. The old database is retained; application objects rebuild to reference the new database consistently. This is separate from the final linker PDB.

```powershell
./scripts/windows/build.ps1 -OutputPath E:/Explore/telgramRX/build/tdesktop-baseline/out -Jobs 4
./scripts/windows/run.ps1 -OutputPath E:/Explore/telgramRX/build/tdesktop-baseline/out
```

Use that explicit output path on this PC. A fresh contributor checkout uses the default local `out/` path. Do not prepare shared dependencies from two checkouts simultaneously. The helpers coordinate via a workspace lock; a crashed run may leave a lock file. Check that no owned prepare/compiler process is alive and that the lock can be opened exclusively before removing that exact stale lock. Never delete a live lock or kill unrelated Telegram processes.

## Checks and CI

`./scripts/windows/validate.ps1` checks repository documents, PowerShell syntax, forbidden system-variable writes, the pinned submodule manifest and private tracked paths. It is the lightweight required PR check, not C++ compilation.

**Felogram native Windows Debug** is manual (`workflow_dispatch`) on a Windows hosted runner, with two workers and a six-hour timeout. It checks prerequisites, prepares dependencies and builds Debug. Its temporary executable/receipt artifact expires after three days and is not a public release. The runner's available compiler/SDK must pass preflight; the workflow does not silently replace missing prerequisites. A native CI run and GUI verification are distinct checks. This manual workflow has not been claimed as successful until a completed run is recorded.

Inherited upstream workflows are preserved under `.github/upstream-workflows/` rather than executed with their upstream automation, service identities or large multi-platform matrices. Inherited issue forms are preserved separately; active forms point to Felogram.

## Troubleshooting

- Missing `basename`, `sed` or `git-sh-setup`: use a complete Git for Windows installation and ensure its `usr/bin` is available to Git's child shell. The helpers temporarily add this path for submodule inspections.
- Missing MSVC 14.44 or SDK: add the exact component through Visual Studio Installer, approve its administrator prompt yourself, then rerun preflight.
- Cache belongs to another checkout: use an intentional `-Reconfigure` transition; do not hand-edit `CMakeCache.txt`.
- Linker cannot write `Telegram.exe`: quit that exact development app from its tray menu. Do not stop an installed Telegram app or another checkout.
- C1090/PDB error 12 during a checkout transition: the observed recovery uses the dedicated Felogram compiler PDB, keeping all application objects consistent. Do not delete a PDB while compiler processes are active or mix objects that reference incompatible compiler databases.
- Preparation seems to wait for a keypress: the helper supplies upstream's `silent` option and unbuffered Python logging.

See [baseline evidence](WINDOWS_BASELINE.md) for actual results and [upstream build documentation](building-win.md) for dependency details.
