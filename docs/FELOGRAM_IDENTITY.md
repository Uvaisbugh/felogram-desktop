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

The installer carries the independent identity and icon, excludes the disabled Updater executable and preserves roaming Felogram app data on uninstall by default. A local unsigned Debug candidate passed compilation, installation, welcome-screen startup and removal on 2026-10-09. The first run also exposed a shutdown crash, subsequently reproduced and fixed as recorded below. Signing, upgrades and real installed-session verification remain distribution gates. No installer is published by this identity change. See the [repeatable local installer procedure](IDENTITY_INSTALLER_TEST.md).

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

- Windows x64 Debug compilation passed on 2026-10-07 at `a72fd71c9faa4461206cfbd06fdbe2474bf61d0f`. The 508,008,448-byte `Felogram.exe` has SHA-256 `72F3BDC7F228D6831B704714673C3D87278EFC4B81D206331AED9192DEF0CB5D`. An immediate incremental build reported no work and preserved that hash (38.67 seconds including configuration and receipt generation).
- On 2026-10-09, direct launch used `%APPDATA%/Felogram Dev/`; the receipt-checking helper used `.local/felogram-dev/`. Welcome and About visibly identify Felogram Dev 0.1.0-dev, retain upstream attribution and show the full build revision. The About version link opened the matching GitHub commit. [Welcome](design/felogram-welcome.jpg), [dark About](design/felogram-about.jpg), [light About](design/felogram-about-light.jpg) and [icon sizes/backgrounds](design/felogram-icon-review.png) are accountless visual evidence.
- The existing upstream `Telegram.exe` and Felogram ran simultaneously in distinct empty profiles. Logs recorded separate AUMID bases (`Telegram.TelegramDesktop` and `Uvaisbugh.Felogram.Desktop.Dev`) and IPC GUIDs. This checks development-process coexistence, not authenticated installed sessions.
- Read-only digests of six current-user/machine `tg:` and `tonsite:` association locations, official classic-profile presence and earlier native-profile settings were identical before/after direct launch, helper launch and the coexistence check. Raw snapshots remain local and contain no published registry values or session files.
- Inno Setup 6.7.3 compiled `Telegram/build/setup.iss` at `ce02fc985c0299fe2ab401262c630fcb733df13e` with the explicit unsigned-development flag and the above `a72fd71` Debug binary. The local candidate SHA-256 is `58768A489DFCAC097A279BA0600D8629D48BF0DE92B9F81B124B6F2361724687` (86,375,621 bytes). Installation exited 0; the installed executable matched the staged hash, its shortcut targeted the independent installation and its log recorded the Felogram AUMID/IPC. [Installed welcome evidence](design/felogram-installed-welcome.jpg).
- Candidate removal exited 0 and reported all files removed with no restart. Its executable, installation directory, Start menu shortcut and uninstall registration were absent afterward. All 275 checked roaming `tdata` files were unchanged, as were the Telegram association and earlier-profile digests.
- **Shutdown regression found and fixed:** Windows Application event 1000 recorded access violations (`0xc0000005`) for the first installed Felogram candidate and the upstream test executable before uninstall began. The upstream fault offset `0xbdfb808` resolves with its matching archived PDB to `base::LogWriteMain + 0x28`; the Felogram event reported offset `0xbdf9ad8`. A fresh Felogram profile reproduced exit `-1073741819` after its supported `-quit` command. The launcher now restores Qt/FFmpeg global logging callbacks before their `BaseIntegration` target is destroyed. Three fresh-profile start/quit cycles then returned 0 for both the application and quit helper. The unchanged upstream test binary still has its original shutdown behavior; no claim is made that this fixes official Telegram.
- Final native build: clean source `3a8f56367c4fd980faf08d9719259c6af8114fc0`, Windows x64 Debug, 508,025,344-byte `Felogram.exe`, SHA-256 `98E1C02215484E34B7D625AEA1123A082234C45927F51F4D4BF206EFD015582F`. Incremental rebuilding reported no work, preserved that hash and took 52.84 seconds including configuration and receipt generation. The helper reopened this binary successfully; the user's sign-in window was left under their control. Earlier screenshots intentionally identify their earlier tested revision.
- The corrected local candidate is 86,367,157 bytes with SHA-256 `88B3D54B4831975080B03994D7CCD2E3AC138F29ACA5B4F0D55A02ABCCF89EC5`. Repeat installation, application quit, quit helper and removal all exited 0. The upstream empty-profile client stayed running before and after removal. Association/earlier-profile digests and all 275 checked roaming files were unchanged; the candidate directory, shortcut and uninstall key were absent afterward. This passes the owned empty-profile packaging boundary check, while signed-in official-session preservation remains open.
- No classic installed Telegram executable/profile was found in the standard inspected locations, and the current-user Store package query returned none. A signed-in installed-session test remains open; an empty upstream test profile cannot prove session preservation.
- Earlier baseline compiler/linker symbols were archived to `D:/FelogramSymbolArchive/20261007-baseline` to free E: space; no dependencies or profiles were removed. The renamed executable and a separate compiler PDB avoid replacing the running Telegram test binary.

Related issues: [I1](https://github.com/Uvaisbugh/felogram-desktop/issues/6), [I2](https://github.com/Uvaisbugh/felogram-desktop/issues/7), [I3](https://github.com/Uvaisbugh/felogram-desktop/issues/8), [I4](https://github.com/Uvaisbugh/felogram-desktop/issues/9). Close each only when its own acceptance evidence is recorded.
