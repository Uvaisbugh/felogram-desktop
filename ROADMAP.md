# Felogram Desktop implementation checklist

Date: 2026-10-06. Product: an independent Windows Telegram client for developers and power users. Deliver a reliable everyday messenger, then make technical conversations easier to organize and revisit. These are planned steps, not completed feature claims. Check off a step only when its acceptance evidence exists.

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

- [ ] Write the first-release scope: normal Telegram use plus local workspaces, bookmarks, exact code copy and saved searches.
- [ ] Define representative users: a developer following several projects, a technical-community participant and a power user with multiple accounts.
- [ ] Define five practical acceptance journeys: return to a saved fix; gather project chats; copy a code snippet; repeat a search; switch chats without losing drafts.
- [ ] Design sketches for the workspace switcher, bookmark panel, search filters and keyboard palette before implementation.
- [ ] Agree on first-release exclusions: arbitrary plugins, bulk automation, executed snippets, automatic external AI processing and a new cloud-sync backend.
- [ ] Convert the stages below into small issues with dependencies, acceptance criteria and evidence links.

Gate: every first-release feature has a concrete user task and an observable pass/fail result.

## 3. Establish Felogram identity

- [ ] Set independent app/window names, executable identity, version metadata and development-build labels.
- [ ] Create Felogram launcher, taskbar, tray and installer icons; verify light/dark backgrounds and scaling.
- [ ] Replace upstream welcome claims with an accurate independent-client description.
- [ ] Add About links to source, license, privacy statement, issue reporting and exact build/version information.
- [ ] Define app data, installation, shortcuts, IPC and Windows AppUserModelID identities that coexist with official Telegram.
- [ ] Verify official Telegram sessions and settings are unaffected by installing, launching and removing Felogram.
- [ ] Decide optional `tg:` link registration behavior; avoid changing default associations on a development launch.
- [ ] Remove or replace upstream update-service, crash-service and other product-specific identities that must not be used by this fork.
- [ ] Keep upstream attribution and all relevant license notices.

Gate: the app clearly identifies itself as Felogram and can coexist with Telegram without profile or installation collisions.

## 4. Configure real account testing

- [ ] Obtain maintainer-owned Telegram API configuration and document private local configuration without committing credentials.
- [ ] Make missing configuration produce a clear development setup state; prevent an unconfigured build from being distributed.
- [ ] Keep upstream test API configuration limited to baseline testing.
- [ ] Have the user sign in manually; do not collect phone numbers, codes or passwords through project issues or chat.
- [ ] Verify supported QR/phone login paths, two-step verification and authorization error states.
- [ ] Verify close/reopen session persistence, logout and account switching.
- [ ] Document what diagnostics may contain and provide redaction guidance.

Gate: owned test accounts can sign in, reopen and log out reliably; configuration and session secrets remain private.

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

- [ ] Create, rename, reorder and remove a workspace.
- [ ] Add/remove existing chats, groups, channels and topics; define overlap with Telegram folders without changing server-side membership unexpectedly.
- [ ] Add a compact workspace switcher and keyboard access.
- [ ] Display workspace-specific chat navigation with accurate unread state and clear current account.
- [ ] Persist workspace membership and ordering locally.
- [ ] Handle archived, deleted and inaccessible chats and changes of account.
- [ ] Verify drafts and recipients remain correct during workspace switching.
- [ ] Test a realistic project with support, development and release chats.

Gate: reopen the app and return to a project's discussion in three actions, without losing a draft or mixing accounts.

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
- [ ] Provide bounded, read-only previews for supported text/log attachments; handle encoding and oversized files with a safe fallback.
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
- [ ] Evaluate independent conversation windows only after navigation/state correctness is established.
- [ ] Implement local focus profiles using existing notification behavior, with visible state and an explicit end time.
- [ ] Verify required notifications still arrive and server-side read/mute semantics remain correct.

Gate: common workflows work without a mouse and focus mode does not silently lose important notifications.

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

1. Reproduce development from the separate Windows checkout.
2. Implement independent identity and private API configuration.
3. Complete real-account messaging/coexistence checks.
4. Implement and verify project workspaces before starting another differentiator.
