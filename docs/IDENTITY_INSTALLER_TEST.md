# Local development installer identity check

This checks Windows packaging boundaries using the Debug executable. It does not authorize a public binary release: the baseline uses upstream test API configuration, has no signing certificate and has no Felogram update service.

## Prepare and compile

Use the verified native build receipt and a dedicated staging directory outside the source checkout. Copy its `Debug/Felogram.exe` into that directory and the Windows SDK redistributable `Redist/D3D/x64/d3dcompiler_47.dll` into `modules/x64/d3d/`. Compare the staged executable's SHA-256 with `felogram-build.json` before compiling. Do not package sessions, profiles, logs, PDBs or API credentials.

Install Inno Setup from its [official download page](https://jrsoftware.org/isdl.php), and verify the installer's valid Authenticode signature. The local identity check uses Inno Setup 6.7.3. From the repository root, substitute your compiler and staging paths:

```powershell
& 'C:/path/to/Inno Setup 6/ISCC.exe' `
  '/DMyBuildTarget=win64' `
  '/DFelogramUnsignedDevelopment' `
  '/DReleasePath=C:\path\to\identity-candidate' `
  'Telegram/build/setup.iss'
```

The explicit unsigned-development flag produces a filename ending `-unsigned-local.exe`. Without that flag, the existing `sha256` signing-tool requirement remains enabled. Never upload this local candidate as a public release.

## Observe install, launch and removal

1. Record whether the Felogram install directory, installer AppId and Felogram shortcuts already exist. Do not overwrite an existing user's installation for this test.
2. Record digests of existing Telegram `tg:`/`tonsite:` registration and UserChoice keys, and settings in owned Telegram test profiles. Keep profile files and raw registry values private.
3. Install the candidate for the current user. Verify `%LOCALAPPDATA%/Programs/Felogram Dev/`, the Felogram executable/icon, its independent uninstall AppId, and the Felogram Start menu shortcut target. For unattended tests use `/VERYSILENT /SUPPRESSMSGBOXES /SP- /NORESTART /NOCLOSEAPPLICATIONS /NOFORCECLOSEAPPLICATIONS /NORESTARTAPPLICATIONS` and an explicit log path. Do not enable post-install launching through an unchecked script.
4. Launch the installed executable in an owned empty profile using `-workdir`. Verify the Felogram welcome screen and profile path while the upstream client remains open. Use a signed-in official Telegram test account in a separate pass to check actual session survival.
5. Quit only the candidate test process with its owner's permission. Resolve the uninstall executable path and ensure it belongs to this test installation before invoking it. Uninstall with `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART` and an explicit log path.
6. Verify the candidate executable, installer registration and candidate shortcuts are removed, roaming Felogram data is preserved, Telegram still runs, and the boundary digests remain unchanged. Inspect the install/uninstall logs for failures.

The [identity record](FELOGRAM_IDENTITY.md) distinguishes completed evidence from remaining account, DPI and distribution checks. Merely compiling or removing an empty-profile candidate does not prove signed-in Telegram session preservation.
