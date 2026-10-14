# Felogram Desktop implementation checklist

Updated: 2026-10-14. Product: an independent Windows Telegram client for developers and power users. Deliver a reliable everyday messenger, then make technical conversations easier to organize and revisit. These are planned steps, not completed feature claims. Check off a step only when its acceptance evidence exists.

## 1. Establish the independent project

- [x] Create the public `Uvaisbugh/felogram-desktop` fork with upstream history and licensing.
- [x] Create a separate local source folder: `E:/Explore/telgramRX/projects/felogram-desktop`.
- [x] Keep Android in `Uvaisbugh/felogram-android` and its own source folder.
- [x] Build the pinned upstream Windows Debug baseline and visually verify its welcome screen.
- [x] Make this new source checkout the active desktop development checkout; initialize pinned submodules and document how it uses prepared dependencies without duplicating or damaging caches.
- [x] Reproduce the Debug build from this independent checkout, then verify incremental rebuilding.
- [x] Put portable build, preflight and launch instructions in this repository; distinguish fresh setup from this PC's existing cache layout.
- [x] Document supported Windows versions and architectures from actual tests; start with Windows x64.
- [x] Configure contributor guidance, issue templates, security reporting and contribution expectations.
- [x] Add appropriate Windows CI checks, artifact retention limits and default-branch protections. Separate lightweight PR checks from expensive native builds.

Gate: a contributor can follow the documented setup, build Debug and open the app; source/toolchain/submodule revisions are recorded.

Evidence: [Windows foundation results](docs/WINDOWS_BASELINE.md). Build, incremental rebuild and startup pass on this existing-cache Windows x64 setup; dedicated CI smoke passes. Fresh-machine setup and full native CI compilation remain unverified.

## 2. Define the first usable release

- [x] Write the first-release scope: normal Telegram use plus local workspaces, bookmarks, exact code copy and saved searches.
- [x] Define representative users: a developer following several projects, a technical-community participant and a power user with multiple accounts.
- [x] Define five practical acceptance journeys: return to a saved fix; gather project chats; copy a code snippet; repeat a search; switch chats without losing drafts.
- [x] Design sketches for the workspace switcher, bookmark panel, search filters and keyboard palette before implementation.
- [x] Agree on first-release exclusions: arbitrary plugins, bulk automation, executed snippets, automatic external AI processing and a new cloud-sync backend.
- [x] Convert the stages below into small issues with dependencies, acceptance criteria and evidence links.

Gate: every first-release feature has a concrete user task and an observable pass/fail result.

Evidence: [first-release specification and five journeys](docs/FIRST_USABLE_RELEASE.md), [four interface sketches](docs/design/first-release-wireframes.svg), and [published issue/dependency index](docs/FIRST_RELEASE_ISSUES.md). This completes the planning gate; feature implementation and journey execution remain open.

## 3. Establish Felogram identity

- [x] Set independent app/window names, executable identity, version metadata and development-build labels.
- [x] Create Felogram launcher, taskbar, tray and installer icons; verify light/dark backgrounds and scaling.
- [x] Replace upstream welcome claims with an accurate independent-client description.
- [x] Add About links to source, license, privacy statement, issue reporting and exact build/version information.
- [x] Define app data, installation, shortcuts, IPC and Windows AppUserModelID identities that coexist with official Telegram.
- [ ] Verify official Telegram sessions and settings are unaffected by installing, launching and removing Felogram.
- [x] Decide optional `tg:` link registration behavior; avoid changing default associations on a development launch.
- [x] Remove or replace upstream update-service, crash-service and other product-specific identities that must not be used by this fork.
- [x] Keep upstream attribution and all relevant license notices.

Gate: the app clearly identifies itself as Felogram and can coexist with Telegram without profile or installation collisions.

Evidence: [identity and verification record](docs/FELOGRAM_IDENTITY.md), [icon sizes on light/dark backgrounds](docs/design/felogram-icon-review.png) and [local installer procedure](docs/IDENTITY_INSTALLER_TEST.md). Icon asset scaling covers 16/24/32 px (100/150/200%); full mixed-monitor DPI testing remains open. The reproduced Felogram shutdown crash is fixed and three clean-quit cycles pass. The gate still requires an installed signed-in official Telegram account to verify real session preservation; none was available on this PC. See [I4](https://github.com/Uvaisbugh/felogram-desktop/issues/9).

## 4. Configure real account testing

- [x] Document private maintainer API configuration, create an ignored local configuration helper and restrict its file permissions without committing credentials.
- [x] Obtain private Telegram API configuration from the maintainer and validate its format and rejection of upstream sample values. The saved file passed on 2026-10-12; credentials remain ignored and private. Manual authorization and a working signed-in chat list were observed on 2026-10-12.
- [x] Make missing configuration produce a clear development setup state; prevent an unconfigured build from being distributed through the supported build/packaging workflow.
- [x] Keep upstream test API configuration limited to explicit baseline testing, with sign-in disabled and a separate profile.
- [x] Have the user sign in manually; sign-in and a working chat list were observed on 2026-10-12. No phone numbers, codes or passwords were collected through issues or chat.
- [ ] Verify supported QR/phone login paths, two-step verification and authorization error states.
- [ ] Verify close/reopen session persistence, logout and account switching.
- [x] Document what diagnostics may contain and provide redaction guidance.

Gate: owned test accounts can sign in, reopen and log out reliably; configuration and session secrets remain private.

Status (2026-10-14): **manual authorization passed; full account gate pending**. The private API workflow is implemented in [PR #44](https://github.com/Uvaisbugh/felogram-desktop/pull/44). The maintainer signed in manually on 2026-10-12; the signed-in chat list and Saved Messages composer were observed. Windows Account Debug build `a47d51d2d9a8f688307ed7ebac1d4d3cffb0dc70` completed and its executable matched the build receipt. Ten configuration/ACL fixtures pass. QR versus phone path, two-step verification, authorization errors, logout and account switching have not all been exercised. Reopening the same profile on 2026-10-14 retained the signed-in session. Those rows remain open; credentials and session files remain private.

## 5. Verify everyday Telegram behavior

- [ ] Test send/receive, edit, delete, reply, forward, reactions and drafts between two test accounts.
- [ ] Check Unicode, emoji, multiline text, formatted code, links and captions.
- [ ] Verify groups, channels, topics, folders, unread state and message navigation.
- [ ] Test photo/video/file upload, download, cancellation, retry and interrupted transfers.
- [ ] Check voice messages, playback and upstream-supported call behavior on actual devices.
- [ ] Test local/global search, result selection and jump-to-message.
- [ ] Verify account isolation, recipient correctness and draft preservation while switching accounts/chats.
- [ ] Test reconnect, offline launch, network changes, sleep/resume and shutdown during transfers.
- [ ] Verify notification delivery, sound, mute settings, click-through, tray restore and close/minimize behavior.
- [ ] Record failures and supported behavior; fix regressions before adding differentiators.

Gate: the messaging/account/network test matrix passes with real accounts. A welcome-screen test alone does not satisfy this stage.

Status (2026-10-14): **single-account testing available; full matrix pending**. The [26-case messaging matrix and synthetic fixtures](docs/EVERYDAY_TELEGRAM_TESTING.md) are ready. The Account build linked successfully and manual sign-in passed. An empty Saved Messages composer accepted an unsent synthetic draft during workspace testing; no message was sent. The run was interrupted before its navigation/persistence checks finished. Two owned accounts and a second device remain unavailable, so cross-account messaging and device/call cases cannot pass yet. No messaging row is completed solely from compilation or fixtures.

## 6. Build account-scoped local storage

- [ ] Design versioned storage for workspaces, bookmarks, notes and saved queries.
- [ ] Use stable account/chat/message identifiers and preserve upstream session/protocol storage boundaries.
- [ ] Define encryption/protection appropriate to the upstream client and prevent cross-account access to local notes.
- [ ] Implement atomic writes, migration, recovery from interruption and clear error reporting.
- [ ] Define behavior on logout, removed accounts, deleted messages and inaccessible chats.
- [ ] Add purposeful tests for isolation, migrations, partial writes and corrupt records using synthetic data.
- [ ] Make diagnostic export exclude message contents and secrets by default.

Gate: local preferences survive restart and upgrades without leaking across accounts or corrupting Telegram data.

## 7. Implement project workspaces — first differentiator

- [x] Create, rename, reorder and remove a workspace.
- [x] Add/remove existing chats, groups, channels and topics; define overlap with Telegram folders without changing server-side membership unexpectedly.
- [x] Add a compact workspace switcher and keyboard access.
- [x] Display workspace-specific chat navigation with accurate unread state and clear current account.
- [x] Persist workspace membership and ordering locally.
- [ ] Handle archived, deleted and inaccessible chats and changes of account.
- [ ] Verify drafts and recipients remain correct during workspace switching.
- [ ] Test a realistic project with support, development and release chats.

Gate: reopen the app and return to a project's discussion in three actions, without losing a draft or mixing accounts.

Status (2026-10-14): **implementation built; live acceptance in progress**. [PR #46](https://github.com/Uvaisbugh/felogram-desktop/pull/46) contains the workspace implementation. The clean Windows x64 Account Debug build at `a47d51d2d9a8f688307ed7ebac1d4d3cffb0dc70` passed, as did both Windows workspace test targets, repository/API checks and [hosted Windows/Qt Core checks](https://github.com/Uvaisbugh/felogram-desktop/actions/runs/38241778114). Live checks passed creation, rename, moving a workspace up/down, restoring order, opening the switcher by mouse/Ctrl+Alt+W, Escape, and current-account display. The user's workspace was preserved. On 2026-10-14, session, workspace selection and the exact Saved Messages draft survived reopen; adding that chat by Tab/Space passed and prevented duplicates. Different-chat draft return, the representative project/action count, topics and unavailable entries still need live evidence. W1–W8 in [Project workspaces](docs/PROJECT_WORKSPACES.md) track partial results; W7 needs a second account. The Stage 5 gate remains open.

## 8. Implement bookmarks and personal notes

- [ ] Bookmark/unbookmark a message from a clear context action.
- [ ] Add optional tags and personal notes with visible local-only status.
- [ ] Build a searchable bookmark panel with chat, sender and date context.
- [ ] Jump back to the correct original message and account.
- [ ] Define reference versus locally retained content behavior; show unavailable/deleted originals honestly.
- [ ] Provide edit/remove actions and workspace association.
- [ ] Verify restart, account switching, message edits/deletions and stale references.

Gate: a user can save a useful solution and find it after restart without searching the entire conversation.

## 9. Improve code and log handling

- [ ] Add exact copy actions for code entities that preserve whitespace, tabs, Unicode, newlines and backticks.
- [ ] Show language labels, readable monospace text and wrapping controls without altering the underlying message.
- [ ] Support keyboard selection/copy and accessible labels for code actions.
- [ ] After the first usable release: provide bounded, read-only previews for supported text/log attachments; handle encoding and oversized files with a safe fallback.
- [ ] Never execute snippets or launch attachments automatically.
- [ ] Verify copy output against original content, including long lines and nested backticks.

Gate: the copied snippet matches the original text and large/unsupported files do not freeze the interface.

## 10. Implement saved searches

- [ ] Reuse upstream search behavior and define supported chat/sender/date/type filters.
- [ ] Save, name, edit, reorder and delete a query locally per account.
- [ ] Rerun searches and show pagination, cancellation, retry and empty/error states.
- [ ] Associate searches with a workspace where useful.
- [ ] Keep result links tied to the correct account/chat/message.
- [ ] Verify stale queries, inaccessible chats, reconnect and repeated runs.

Gate: the user can repeat a technical search and reliably return to the matching conversation.

## 11. Add keyboard productivity and focus controls

- [ ] Build a command palette for navigation and implemented Felogram actions, with shortcut discovery.
- [ ] Add workspace/bookmark/search shortcuts without conflicting with common upstream actions.
- [ ] Preserve focus and drafts; test navigation with multiple accounts and open dialogs.
- [ ] After the first usable release: evaluate independent conversation windows only after navigation/state correctness is established.
- [ ] After the first usable release: implement local focus profiles using existing notification behavior, with visible state and an explicit end time.
- [ ] Verify required notifications still arrive and server-side read/mute semantics remain correct.

First-release gate: common workflows work without a mouse, preserve focus and drafts, and keep account context visible.

Later focus-profile gate: focus mode does not silently lose important notifications.

## 12. Polish Windows usability and accessibility

- [ ] Verify resize behavior, minimum sizes, scrolling, themes and readable empty/error states.
- [ ] Test 100%, 150% and 200% scaling, mixed-DPI monitors and monitor removal.
- [ ] Test keyboard-only use, focus indicators, Narrator, contrast and large text.
- [ ] Verify touchpad interactions, clipboard, drag/drop and safe file-opening behavior.
- [ ] Test tray/taskbar restore, multiple instances, startup settings and sleep/resume.
- [ ] Have representative users perform the five acceptance journeys and record friction.

Gate: actual Windows users can complete the journeys with keyboard, screen reader and enlarged text; all critical usability failures are resolved.

## 13. Measure quality and maintain upstream compatibility

- [ ] Compare startup, idle memory and responsiveness with the same upstream build on identical hardware and data.
- [ ] Aim to stay within 15% of upstream startup/idle-memory measurements; document any justified tradeoff.
- [ ] Exercise large synthetic histories and bookmarks; record search/scroll latency and frame times.
- [ ] Test disk pressure, malformed local records, interruption and graceful shutdown.
- [ ] Track every Felogram patch, its rationale, migrations and upstream conflict risk.
- [ ] Rehearse an upstream merge and rerun meaningful regression checks.
- [ ] Define optional, redacted crash reporting only with explicit user control; add no telemetry by default.

Gate: published measurements support performance claims, and an upstream update preserves features and user data.

## 14. Prepare distribution and public alpha

- [ ] Document intended portable and installer distribution paths and supported OS versions.
- [ ] Configure private maintainer signing and release identities outside source control.
- [ ] Review third-party redistribution, required notices and corresponding-source publication for the exact artifact.
- [ ] Produce a versioned candidate with source revision and SHA-256 recorded; follow repository build restrictions during development.
- [ ] Test on a clean Windows machine without developer toolchains.
- [ ] Verify install, first run, coexistence, upgrade, rollback/recovery and uninstall with clear data-retention choices.
- [ ] Implement and test an authenticated update path before enabling automatic updates.
- [ ] Publish release notes, known limitations, installation instructions and matching source with each binary.
- [ ] Start with an explicitly experimental alpha and a small group of voluntary testers.

Gate: the exact release artifact passes clean-machine and update tests, carries the required notices/source, and is described accurately.

## 15. Advance to beta and maintain stable releases

- [ ] Triage alpha feedback and resolve login, data-loss, recipient, crash and update blockers first.
- [ ] Repeat the acceptance matrix across supported Windows/device configurations.
- [ ] Verify preference migrations and account isolation through multiple upgrades.
- [ ] Establish a security-report response process and upstream-update/release ownership.
- [ ] Promote to beta only after messaging, accessibility, performance and distribution gates pass.
- [ ] Promote to stable after repeated update rehearsals and resolved release blockers; do not promise a date without evidence.
- [ ] Maintain compatibility notes, regression fixtures, changelogs and a small reviewed patch set.

Gate: release quality and maintenance are repeatable, rather than a one-time successful build.

## Later, after the first useful release

- [ ] Design explicit workspace/bookmark export/import with schema versioning and no account/session secrets.
- [ ] Align shared concepts with Android while keeping separate platform implementations and tests.
- [ ] Evaluate cross-device sync only with a defined privacy, conflict-resolution and service-maintenance design.
- [ ] Evaluate translation, AI providers or integrations separately with clear data disclosure and user choice.

## Immediate next steps

1. Finish workspace acceptance with a suitable existing test discussion. Saved Messages membership, duplicate prevention and reopen/session/draft persistence now pass; verify different-chat recipients and draft return. Preserve user-created workspaces and existing drafts.
2. Verify controlled close/reopen and the three-action journey; the user controls the running test process. Complete topic, archive/unavailable and keyboard/layout cases, recording actual results rather than inferring them from code.
3. Complete remaining account, messaging and official Telegram coexistence gates. Keep two-account/device cases blocked until that setup is available. Run full dedicated native CI when its prerequisite branches are integrated.
4. Extend the reviewed account-local storage for bookmarks/notes and saved queries, with versioning, atomic writes, corruption/isolation tests and private diagnostics. Workspace storage already implements these protections for its own schema; Stage 6 is not complete for all feature types.
5. Implement bookmarks/notes, exact code copy, saved searches and the command palette in that order, each in a small reviewable change with its own acceptance evidence. Keep distribution and beta gates closed until real-account, accessibility, performance and clean-machine checks pass.
