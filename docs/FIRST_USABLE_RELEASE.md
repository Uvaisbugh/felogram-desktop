# First usable Windows release

Decision date: 2026-10-07. Target: Felogram Desktop experimental alpha for Windows x64. This document defines planned behavior, not implemented features. Windows 11 is the only currently tested OS; expand support only with recorded tests. Android has a separate implementation and release.

## Release scope

Help people follow technical conversations and retrieve useful information while retaining dependable Telegram messaging. Use the native upstream client and its existing protocol/search behavior. Do not replace the messaging stack.

| Capability | First-release commitment | Observable acceptance |
| --- | --- | --- |
| Everyday Telegram use | Maintainer API configuration; manual login; text, replies, edits, deletion, forwarding, reactions, drafts, groups/channels/topics, media/files, voice playback, search, account switching, reconnect and Windows notifications | Two-account matrix passes; no wrong-recipient sends, lost drafts or cross-account records. Exercise upstream-supported calls on actual devices and publish results/limitations. |
| Local workspaces | Create, rename, reorder and remove project views; select existing chats and topics; preserve unread state and drafts | J2 and J5 pass after restart. Membership is local and does not alter Telegram folders, subscriptions or mute/read settings. |
| Bookmarks and notes | Bookmark a message; optional tags and a plain-text personal note; filter by workspace/chat/tag; reopen the original | J1 passes. Store a reference and user-authored metadata, without retaining a hidden message-body snapshot. Deleted/inaccessible originals show an honest unavailable state. |
| Exact code copy | Copy the full raw text of a selected code entity; language label and wrap toggle; keyboard access | J3 passes character-for-character, without injected formatting or executed content. |
| Saved searches | Named local queries using upstream-supported chat, sender, date and type filters; optional workspace association | J4 passes. Rerun against current Telegram search results; saving does not retain a result snapshot or promise offline/global indexing. |
| Keyboard navigation | Discover and invoke implemented workspace/bookmark/search actions from a command palette | J1–J5 can be completed with keyboard-only navigation; Escape restores prior focus and unsent drafts. |

## Representative users

These are design personas, not interviewed users or evidence of demand.

| Persona | Situation | Desired result | Main failure to prevent |
| --- | --- | --- | --- |
| Developer following projects | Follows support, development, topic and release chats for several libraries | Return to the right project and copy a working fix without reformatting it | Lost context, altered snippets or a draft sent to another chat |
| Technical-community participant | Learns from busy groups and revisits answers weeks later | Tag a useful answer, add a personal reminder and reopen its source | A bookmark implying a deleted answer is still available |
| Power user with multiple accounts | Uses work and personal accounts with similar chat names | Clearly see the active account and keep local records and drafts separate | Cross-account access or sending from the wrong account |

## Product rules

- Account context is visible on every Felogram panel and palette. Workspaces, bookmarks, notes and searches belong to one account. No automatic account switching when opening a stale result.
- “All chats” remains available. A workspace changes local navigation only. Removing it removes its association records, not chats or messages; bookmarks/searches remain accessible in their account.
- Refer to stable account, peer and message/topic identifiers, never titles as keys. Topic membership includes the parent chat and topic ID. Warn when an identifier is unavailable instead of silently substituting another chat.
- Writes must be atomic and versioned. A failed write keeps the previous valid state and presents retry; avoid editing upstream protocol/session storage. Protection must follow the upstream local passcode/storage model; review that design before implementing persistence.
- Offline startup can show local metadata and available upstream cached messages. A navigation/search request needing the network explicitly reports offline state; no invented successful result.
- Logout/removed-account cleanup removes that account's Felogram records. Confirm loss of local-only notes in the UI. Lock/passcode behavior also covers Felogram panels and does not leave their contents visible.
- A bookmarked edited message opens its current upstream version; the bookmark is not an immutable archive. Unavailable entries keep removable user metadata without showing retained original content.
- Normal messaging behavior and localization/accessibility conventions remain upstream-compatible. Keep technical setup instructions in development documentation, not everyday product screens.

## Acceptance journeys

Use synthetic conversations and maintainer-owned test accounts A and B. Record exact build/source revision, Windows version, relevant fixture identifiers and observed outcomes. Redact phone numbers, account IDs, credentials and real messages from public evidence. Every journey is currently **not run**.

### J1 — Return to a saved fix

1. In A, bookmark a synthetic solution in a group; add tag `build` and note `Fix for missing include`.
2. Close and reopen Felogram. Open Bookmarks; filter by tag; select the entry and open its original.
3. Repeat after editing the original, then deleting it or making the chat inaccessible.

Pass: metadata survives restart; the available original opens in the correct account/chat/message within three navigation actions from the main window (open Bookmarks, choose entry, open original; text entry is counted separately). Edited content is current. Unavailable originals show an explicit state without an invented copy. B cannot view A's records. Fail on wrong destination, lost metadata or retained hidden message content.

### J2 — Gather project chats

1. In A, create `Compiler project`; add a support group, a development topic and a release channel already accessible to A.
2. Reorder the workspace, switch to another view, restart and return using the switcher.
3. Remove a member, then remove the workspace. Inspect Telegram folders, subscriptions and chats.

Pass: membership/order survive restart; from the main window, opening the project discussion takes at most three actions. Unread indicators agree with upstream. Removing local membership/workspace does not remove chats, change folders or mark messages read merely by selecting a workspace. Inaccessible members are explained and removable.

### J3 — Copy a code snippet exactly

1. Receive code entities containing spaces, tabs, blank lines, Unicode, backticks, long lines and no terminal newline; include a message with multiple separate code entities.
2. Copy one complete entity through the visible action, then through the keyboard action; toggle visual wrapping and repeat.
3. Compare clipboard text with the raw selected entity's source string in a purposeful fixture test; paste into a local plain-text editor for manual confirmation.

Pass: every character matches the selected entity, including indentation and line endings as represented by the message string; no language header, fences, extra newline or text from another entity. Visual wrapping does not change the result. Selection/copy has an accessible name and never executes content. Do not claim original file-byte preservation across Telegram's text encoding.

### J4 — Repeat a search

1. In A, search a project chat for `linker error`, choose an accessible sender, date range and upstream-supported type filter; save as `Build failures`.
2. Restart, open Saved searches and rerun it. Add a new matching message and rerun again.
3. Test no matches, cancel, offline/reconnect and an inaccessible chat; switch to B.

Pass: the query and filters persist per account; rerunning uses current upstream results, including the new match. Selecting a result opens the exact original. Cancellation cannot let late responses overwrite a newer search. Empty/offline/error states differ visibly, with retry where appropriate. B cannot see or execute A's saved query.

### J5 — Switch chats without losing drafts

1. In A, type an unsent multiline draft with a reply target in a project topic. Switch workspace and open another chat using the palette; create a different draft there.
2. Switch to B (with a similarly named chat), then back to A; return to both original chats and restart.
3. Send only after explicitly choosing Send in the intended account/chat; verify the recipient from the other test account.

Pass: each draft, reply target and recipient remain tied to the correct account/chat/topic; switching does not send anything. Palette dismissal restores prior focus. After restart, upstream draft behavior is preserved. No text leaks between accounts and no wrong-recipient send occurs.

## Sketches and interaction contracts

See [the four-panel wireframe board](design/first-release-wireframes.svg). Synthetic labels only; it is a design sketch, not a functioning application or screenshot. Reuse native widgets/styles, rather than embedding these SVG layouts in the app.

| Surface | Placement and main actions | Required states and keyboard behavior |
| --- | --- | --- |
| Workspace switcher | Top of chat navigation, below the visible account selector; All chats, local project rows and Manage workspaces; menu/dialog for edit membership | Empty: create first workspace. Unavailable member: explanation/removal. Tab/arrow/Enter navigation; selection leaves the compose draft intact. Narrow window uses a dropdown, not a second permanent rail. |
| Bookmark panel | Right side on wide windows; replaces chat-list content on narrow windows with Back; filters above entries; original/notes actions per entry | Loading, empty, no filter matches, unavailable original and failed save are distinct. Enter opens selected original, Escape/Back restores previous surface. Notes explicitly say “Local to this account”. |
| Search filters | Upstream search surface with visible query, account/chat scope and sender/date/type chips; Save search opens a name dialog; saved-query list is a local navigation surface | Show results/loading/empty/offline/error and cancel/retry. Reject invalid date ranges before requests. Enter submits; Escape cancels then returns focus. Unsupported upstream filters are omitted instead of simulated. |
| Keyboard palette | Centered modal overlay over the current conversation; proposed Ctrl+K, subject to upstream shortcut audit | Search commands and account-scoped destinations; only implemented actions appear. Arrow/Enter choose, Escape returns focus; no implicit send, account change or executable action. Shortcut conflict blocks adoption until resolved. |

At 100%, 150% and 200% scaling, labels and focus rings must remain visible; no horizontal overflow of primary actions. Give controls accessible names and logical focus order. Include a visible account label even when names are similar. Validate with Narrator and keyboard-only users before claiming accessibility.

## First-release exclusions

The requested exclusions are adopted: arbitrary plugins, bulk automation, executed snippets, automatic external AI processing and a new cloud-sync backend. Felogram metadata remains local to this PC and account; do not suggest that it syncs through Telegram.

Also defer independent conversation windows, local focus/notification profiles, new attachment/log previewers, export/import, translation providers and Android parity to later work. Preserve existing upstream attachment and notification behavior. New telemetry is off by default; a future optional redacted reporting design needs its own review.

## Delivery order and completion evidence

1. Independent identity/coexistence and maintainer API configuration.
2. Real-account everyday messaging matrix, plus full dedicated native build and fresh-machine checks.
3. Account-scoped storage and recovery; workspaces first.
4. Bookmarks/notes, exact code copy and saved searches in separate changes.
5. Command palette; Windows accessibility and representative-user journeys.
6. Performance/upstream update rehearsal; licensed candidate, distribution checks and experimental alpha.

See [the issue/dependency index](FIRST_RELEASE_ISSUES.md). It covers roadmap stages 3–15 and marks deferred work separately. An issue is complete only when its acceptance criteria pass and its body links the implementation PR plus redacted evidence for the exact tested build. Links to this specification are requirements, not proof of implementation. Do not invent test dates, users or measurements.

The Section 2 gate is a **planning gate**: every first-release capability has a concrete user task and observable pass/fail result. It does not certify that J1–J5 have passed. Public alpha requires all first-release implementation and verification issues to close, including the messaging matrix, account isolation, Windows accessibility, performance and distribution checks. No release date is promised.
