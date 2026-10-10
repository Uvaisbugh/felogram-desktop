# Real account setup and verification

Felogram's account-testing gate requires a maintainer API build and manual verification with owned accounts. A successful compilation or a baseline welcome screen does not prove account authorization works.

## Private API setup on Windows

Use an active Telegram account you control to obtain an application `api_id` and `api_hash` from [API development tools](https://my.telegram.org/apps), following [Telegram's official instructions](https://core.telegram.org/api/obtaining_api_id). These are client application values, not a BotFather bot token. Telegram's sample API ID is limited to testing and must not be used for a distributed client.

For the application form, use **Felogram Desktop**, a unique short name such as **felogramdesktop**, the [public source repository](https://github.com/Uvaisbugh/felogram-desktop) as its URL, **Desktop** as the platform, and a factual description: “Independent open-source Telegram desktop client for developers and power users.” Telegram validates the form; a generic ERROR does not establish which field failed. If it persists, record only the error text and whether it happened before or after form submission. Do not share an authenticated page capture or repeatedly submit account codes.

From this checkout:

```powershell
./scripts/windows/configure-api.ps1 -OpenEditor
```

Enter the values directly into `.local/telegram-api.local.json` in the editor. The helper preserves an existing file, checks Git ignores it, and restricts access to the current Windows user and SYSTEM. It creates these empty placeholders when needed:

```json
{
  "api_id": 0,
  "api_hash": ""
}
```

Never put real values in command arguments, issues, chat, screenshots or committed files. Do not change the template into a credential-bearing tracked example.

```powershell
./scripts/windows/check.ps1 -RequireDependencies
./scripts/windows/build.ps1 -Jobs 2
./scripts/windows/run.ps1
```

`Account` is the default mode. Missing, malformed, empty or upstream sample configuration stops setup with a value-free error; it never silently switches to the sample. CMake reads the private JSON and generates an ignored build header. API values are absent from compiler definitions, CMake cache values and the build receipt. Generated headers, binaries and debug symbols can still contain compiled application values; keep account-development output private until the distribution audit. `FELOGRAM_DISTRIBUTION=ON` rejects Baseline mode. Signed installer compilation additionally requires an explicitly verified maintainer configuration; all current Debug receipts remain `distributionReady=false`.

The default account profile is `.local/felogram-account/`, restricted before launch. Custom test profiles must be inside this checkout's `.local/` directory and remain separate from legacy/baseline profiles. Preserve official Telegram profiles and the earlier `.local/felogram-dev/` profile; there is no automatic import.

## Explicit UI baseline

```powershell
./scripts/windows/check.ps1 -RequireDependencies -ApiMode Baseline
./scripts/windows/build.ps1 -Jobs 2 -ApiMode Baseline
./scripts/windows/run.ps1 -AllowBaseline
```

Baseline mode uses only the upstream sample for development checks. Its welcome screen describes the setup state and offers **Set up account testing** instead of account sign-in. QR/phone intro entry points return to that setup screen. About identifies the mode. Its helper profile is `.local/felogram-baseline/`; direct Windows launch uses `%APPDATA%/Felogram Dev Baseline/`, with a separate `FelogramBaselineForcePortable` opt-in folder. These paths avoid reopening account/legacy profiles implicitly. Never use a baseline build to test a real login or publish it as an end-user client.

## Manual account acceptance journeys

Run a verified Account build. Use private aliases **Account A** and **Account B** in records. The maintainer performs authentication, enters every phone number/code/password, handles account-security dialogs and performs logout. Automation must not type or capture those details. Ordinary app behavior may be inspected after the user confirms authorization, with account identifiers and message contents kept private.

| Check | User action | Observable pass result | Current result |
| --- | --- | --- | --- |
| QR login | Scan the app's current QR from official Telegram's Devices flow | Authorized chat list opens for the intended owned account | Pending maintainer configuration and manual test |
| QR refresh/expiry | Allow the displayed token to expire naturally, then use the refreshed token | Refresh remains usable and the expired token does not authorize a new session | Pending |
| Phone login | Use the phone path and enter the delivered code manually | Authorized chat list opens; back/cancel remains usable | Pending |
| Two-step verification | Use an owned account already protected by a password; enter it manually | Password step is shown and correct authorization succeeds | Pending; record Not tested if no such owned account exists |
| Authorization error | Observe a naturally expired code/token or a single controlled invalid code on an owned test attempt | Clear error, no accidental authorization, usable recovery path | Pending; do not force repeated attempts or rate limits |
| Session persistence | Quit Felogram normally, then reopen the same Account profile | Same account opens without re-entering account codes; draft/local settings are preserved | Pending |
| Account switch | Add Account B manually and switch A → B → A | Each account's chats, drafts and settings remain scoped correctly | Pending; requires two owned accounts |
| Logout | Log out the selected test account manually and reopen | That account requires authorization again; other accounts and official Telegram remain usable | Pending |

Record the tested source revision, executable SHA-256, API mode, Windows build, account aliases, action, pass/fail result and any error **name**. Do not record codes, passwords, account IDs, phone numbers, QR tokens, sessions or real messages. Inspect official Telegram before and after the test to finish the remaining identity coexistence gate. Test-server authorization and the upstream sample are not substitutes for these checks.

## Diagnostics and redaction

Profiles contain authorization keys, encrypted local account state, caches and settings. Treat the entire `tdata` tree and portable/profile folders as sensitive; never attach them to GitHub. A local passcode does not make a profile safe to share.

Logs and Windows crash reports may expose phone/account identifiers, usernames, peer/message IDs, file paths, device information, network addresses, protocol request details and user content. Debug dumps/symbols and generated API headers may also expose application configuration or memory. Login screenshots can contain live QR tokens, recovery information or account identifiers. Do not publish these raw artifacts.

For a public issue, write a small reproduction using synthetic content, the source/build hash, API mode and a redacted error name. Replace sensitive identifiers consistently with aliases and remove tokens, paths revealing identities, headers and message bodies. Review the final text manually; a simple regex cannot guarantee safe redaction. Do not enable verbose MTProto/auth logging to collect login secrets. Security reports follow [SECURITY.md](../SECURITY.md).

Upstream automatic updates and crash uploads remain disabled. Windows can create its own local crash reports; this is distinct from a Felogram upload service. No account/session files or credentials are included in CI artifacts.

## Gate status

The manual rows above stay open until their results are actually observed. Private configuration validation, sample rejection and distribution checks can be tested without logging into an account; those tests do not verify QR/phone login, two-step verification, persistence, logout or switching.
