# Felogram Windows development identity

The identity baseline is Felogram Dev 0.1.0-dev, based on upstream Telegram Desktop 7.2.10. It is an independent, experimental client, not affiliated with Telegram. This identity is for development; production and Store identities need their own distribution review. Source copyright headers, LICENSE and LEGAL retain upstream attribution.

## Identity boundaries

| Surface | Felogram development value |
| --- | --- |
| App/window name | Felogram Dev; conversation/account titles retain a Felogram suffix |
| Native executable | Felogram.exe; CMake target remains Telegram for upstream build compatibility |
| Windows file/product version | 0.1.0.0 / 0.1.0-dev; upstream protocol/build version is recorded separately |
| About version | Felogram development version, upstream version, architecture and existing Debug marker |
| About build | Full source revision captured at configure time; tracked edits add `-dirty` |
| Qt application name | FelogramDesktopDev |
| Default app data | `%APPDATA%/Felogram Dev/`; no automatic official Telegram profile import |
| Helper test profile | `.local/felogram-dev/` in this checkout |
| Portable opt-in folder | FelogramDevForcePortable beside the executable |
| Installer directory | `%LOCALAPPDATA%/Programs/Felogram Dev/` |
| Installer / uninstall AppId | `{AB551605-20C7-4F1B-9B10-FE103A0DE001}` |
| Single-instance / executable lock GUID | `{AB551605-20C7-4F1B-9B10-FE103A0DE002}`; IPC also scopes the working directory |
| AppUserModelID base | Uvaisbugh.Felogram.Desktop.Dev; upstream logic may append a profile-specific suffix |
| Toast activation CLSID | `{AB551605-20C7-4F1B-9B10-FE103A0DE003}`; standard Windows callback interface IDs remain unchanged |
| Start menu / desktop shortcuts | Felogram Dev.lnk, in Felogram-owned locations |
| Startup / Send to shortcuts | Felogram.lnk, derived from AppFile; distinct from Telegram.lnk |

The installer source carries the independent identity and icon, excludes the disabled Updater executable and preserves roaming Felogram app data on uninstall by default. Installer compilation, signing, install/upgrade/removal and real installed-session verification remain distribution gates; editing an installer definition does not satisfy them. No installer is published by this identity change.

## Link and service policy

Automatic `tg:` and `tonsite:` registration is skipped by default in the native app, including direct executable launch. The helper additionally seeds the skip option in its isolated profile. Deliberate manual registration uses a Felogram-specific registration name; the development verification must not activate that action or change existing associations. Opt-in registration behavior needs a separate test before distribution.

Windows CMake forces upstream automatic updates and crash report generation off. The crash-report actions no longer query or upload to upstream endpoints; the dialog offers local saving and points to Felogram source. Felogram has no verified update service yet. The private API configuration and distribution gating work remains in roadmap stage 4; this baseline still uses test API configuration.

About links point to Felogram source, LICENSE, PRIVACY.md and issues, with an additional upstream source/attribution link. Clicking the version opens the recorded source commit rather than upstream changelog or private-alpha download services. Review [the development privacy statement](../PRIVACY.md).

## Icon source and regeneration

`Telegram/Resources/art/felogram/mark.svg` is an original vector F/code-bracket mark created for this project, licensed with the repository under GPLv3 and its existing exception. It uses a teal tile, white F and mint bracket. Upstream image assets are retained, and Qt aliases select the Felogram logos without overwriting the originals.

The Windows ICO contains 16, 20, 24, 32, 40, 48, 64, 128 and 256 px images. The same mark supplies native launcher/taskbar resources, Qt window/tray logos, welcome art and the installer definition. PNG/ICO files are checked in; normal native builds do not need Python graphics packages.

To regenerate with Python and PySide6 installed:

```powershell
python scripts/windows/generate_icons.py
python scripts/windows/generate_icons.py E:/Explore/telgramRX/build/felogram-icon-review.png
```

The optional contact sheet checks the actual rendered icon sizes on light/dark backgrounds, including 16/24/32 px for 100/150/200% small icons. It is asset evidence, not a full mixed-DPI Windows usability test.

## Verification record

- Source implementation and icon asset review are complete; native compilation/startup/About/IPC/association checks are pending until results are added here.
- The development PC has no classic installed Telegram executable/profile in the standard inspected locations. A signed-in installed-session and installer removal test cannot be inferred from the upstream welcome-screen baseline.
- Earlier baseline compiler/linker symbols were archived to `D:/FelogramSymbolArchive/20261007-baseline` to free E: space; no dependencies or profiles were removed. The renamed executable and a separate compiler PDB avoid replacing the running Telegram test binary.

Related issues: [I1](https://github.com/Uvaisbugh/felogram-desktop/issues/6), [I2](https://github.com/Uvaisbugh/felogram-desktop/issues/7), [I3](https://github.com/Uvaisbugh/felogram-desktop/issues/8), [I4](https://github.com/Uvaisbugh/felogram-desktop/issues/9). Close each only when its own acceptance evidence is recorded.
