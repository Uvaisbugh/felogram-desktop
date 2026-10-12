# Everyday Telegram verification

Prepared 2026-10-12. Execution status: **blocked pending Account build and manual authorization; required two-account/device setup unavailable**. The maintainer selected “One account or no second device.” This is a test procedure, not a passing messaging report. Related issues: [M1](https://github.com/Uvaisbugh/felogram-desktop/issues/13), [M2](https://github.com/Uvaisbugh/felogram-desktop/issues/14), [M3](https://github.com/Uvaisbugh/felogram-desktop/issues/15).

## Prerequisites and boundaries

Complete [real account setup](REAL_ACCOUNT_TESTING.md) first. Use a verified Windows x64 Debug Account receipt with `testApi=false`; Baseline cannot perform these tests. The maintainer signs in manually. Use Account A and Account B, a private test conversation between them, and a second device for receipt, media and calls. Keep identifiers, codes, passwords, QR tokens and sessions out of published evidence.

Use owned test-only groups, channels and topics, with no unrelated participants. The maintainer creates these spaces, identifies the intended recipients and authorizes the concrete test sends before any automated UI action. Delete only disposable synthetic messages after confirming the selected message and deletion scope. Do not modify personal chats, contact lists or memberships. The maintainer handles authentication, microphone/camera permissions, mute/privacy changes, network changes and sleep/resume manually. Avoid interruptions to other work on this PC. Do not force rate limits or account restrictions.

Generate synthetic transfer fixtures without reading any account data:

```powershell
python scripts/testing/prepare_messaging_fixtures.py
```

The helper creates a fresh ignored `.local/messaging-fixtures/<run>/` folder, containing UTF-8 text/code, a PNG, a short tone WAV and a 32 MiB transfer file. `manifest.json` records their sizes and SHA-256 hashes. Downloaded files sent as **files** must match those hashes. Photo/video compression is intentional; check rendered content, orientation and duration instead. Use a maintainer-created synthetic video and an actual recorded synthetic voice message for the separate video/voice tests; sending the WAV does not verify voice recording. The helper never connects to Telegram or sends anything.

## Execution matrix

Every row currently has result **Not run**. Run both A → B and B → A where applicable. Record results per row; a successful send does not establish edit, delete or retry behavior.

| ID | Action | Observable pass condition |
| --- | --- | --- |
| M01 | Send unique synthetic text in both directions | Intended recipient receives one matching message; sent/received state updates correctly |
| M02 | Edit one synthetic message | Sender and recipient see the revised text and edited state; neighboring messages are unchanged |
| M03 | Reply and forward to an owned test destination | Reply points to the correct original; forwarded content and attribution follow upstream behavior |
| M04 | Add, change and remove a reaction | Both accounts show the expected reaction/count without applying it to another message |
| M05 | Delete one disposable message for self, then a different one for both | Visibility follows the chosen scope; unrelated messages remain intact |
| M06 | Leave distinct unsent drafts in two chats, switch and reopen | Each draft stays with its intended account/chat and is never sent automatically |
| M07 | Send Unicode/emoji/multiline text and a formatted code block | Both ends retain characters, line breaks, tabs and visible formatting; clipboard code matches the fixture's logical text |
| M08 | Send a link, photo caption and file caption | Correct preview/text and caption association; opening a result targets the intended message |
| M09 | Send/navigate in an owned group, channel and two topics | Messages appear in the right destination/topic; reply/navigation/unread behavior stays correctly scoped |
| M10 | Use folders, archive/unread state and jump navigation | Correct chats/counts appear; opening a chat or message does not select another recipient |
| M11 | Upload/download the PNG as a photo and as a file | Photo is visually correct; file download has the manifest hash; caption and save destination are correct |
| M12 | Upload/download a synthetic video | Content, duration, orientation, caption and playback are correct on both devices; file-mode copy retains its hash |
| M13 | Send/download the transfer file; cancel an active upload and download | Completed file has matching size/hash; cancellation stops the selected transfer and UI remains usable |
| M14 | Retry a cancelled transfer and interrupt another mid-transfer | Recovery is usable; final file is complete and matches the hash; no unintended duplicate send or wrong destination |
| M15 | Record/send/play a synthetic voice message | Actual recording reaches the intended recipient; sound, duration, seek/play/pause behave correctly |
| M16 | Play the tone WAV as an audio/file attachment | Playback and seeking work; downloaded file matches the manifest |
| M17 | Initiate/answer/end an upstream-supported voice/video call on actual devices | Intended peer rings; audio/video works as applicable; ending from either end releases the call and devices |
| M18 | Search a unique marker locally and globally; choose a result | Correct result/account/chat/message opens; empty results, back navigation and cancellation remain usable |
| M19 | Switch Account A → B → A with distinct drafts and test conversations | Recipients, drafts, unread state and results remain scoped; no cross-account send or disclosure |
| M20 | Maintainer disconnects/reconnects network during a synthetic send | Offline state is clear; reconnect delivers the intended message without unintended duplicates |
| M21 | Launch offline, reconnect and change networks | Existing session remains usable; queued work recovers; connection state updates accurately |
| M22 | Maintainer sleeps/resumes this PC during an active transfer | App reconnects and recovers or offers a usable retry; final completed file has matching hash |
| M23 | Quit normally during an active transfer, then reopen | No session corruption or crash; recovery is usable and no partial file is presented as complete |
| M24 | Receive a synthetic message while unfocused/minimized/in tray | Windows notification and sound follow the intended settings; click opens the correct account/chat/message |
| M25 | Maintainer mutes/unmutes the owned test chat and checks notifications | Notification/sound behavior follows the selected setting; other test chats remain unaffected |
| M26 | Minimize, close to tray, restore and Quit from tray | Restore preserves the correct account/chat/draft; Quit exits normally rather than leaving a hidden process |

## Evidence and failure handling

### Limited smoke test with one owned account

After manual sign-in, the maintainer may authorize synthetic sends to Saved Messages and check text/code display, edit, reply, reactions, search, file upload/download, drafts and normal quit/reopen. Use the same fixture hashes and record these as separate smoke results. A Saved Messages round trip does not verify another recipient, inter-account isolation, notifications from another account or calls between devices. Delete only selected disposable test messages with confirmed scope. All two-account/device rows remain blocked until those prerequisites become available.

Record Windows build, source revision from About and the receipt, executable SHA-256, Account mode, device types, run alias and fixture manifest hash. Keep a local table with columns `ID | direction/device | result | expected | observed | redacted evidence`. Results are Pass, Fail, Blocked or Not tested; give a reason for the last two. Publish only redacted summaries and synthetic content. Raw screenshots, logs, profile trees and crash dumps are not public evidence.

For every failure, record the smallest synthetic reproduction, affected row, build hash and observed error name. Wrong-recipient sends, account leakage, draft loss, corrupt downloads, crashes and unrecoverable reconnects block this gate. Stop dependent testing after such a failure, fix the regression, then rerun the affected rows and relevant account/session checks. Feature availability inferred from inherited source code is not a device test.

Gate: all applicable matrix rows pass with owned accounts and actual devices, stage 4 authorization/session checks pass, and no blocking regressions remain. Any unsupported or untested call/device behavior must be recorded explicitly and reviewed before the gate is accepted. The welcome screen, generated fixtures and compilation do not satisfy this gate.

## Current record

- 2026-10-12: private API syntax/sample checks and file restrictions pass. Initial Account configuration stopped because the prepared Qt install was missing resource/plugin objects. Thirty-five absent objects were rebuilt from the existing pinned Qt 6.11.2 Debug sources, restored to their exact install paths and hash-verified. Account compilation is being retried; no verified Account executable has been launched yet.
- Synthetic fixtures were generated locally. All five manifest sizes/hashes pass; PNG dimensions are 640×480 and WAV duration is three seconds. These checks do not send or receive Telegram content.
- No send, edit, deletion, transfer, call, search, account-switch, network or notification journey has been executed. The maintainer confirmed the full two-account/second-device setup is unavailable. Limited smoke tests are also pending the Account build and manual authorization.
