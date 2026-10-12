# Project workspaces

Workspaces gather existing Telegram discussions for a project in an account-local navigation panel. A chat or topic can belong to several workspaces. They do not change Telegram folders, group/channel membership, messages, unread flags or drafts.

## Use

1. Sign in manually to an Account build of Felogram Dev.
2. Click **Workspaces** above the chat list, or press **Ctrl+Alt+W**. Use Tab and Enter/Space to operate the controls; Escape closes the panel.
3. Choose **Create workspace**, enter a unique name and save. Names are trimmed and limited to 80 characters. Each account supports 32 workspaces with 200 entries each.
4. Open an existing chat, group, channel or topic through Telegram’s normal navigation. Open Workspaces and choose **Add current chat or topic**. Repeat for your support, development and release discussions.
5. Open Workspaces to see the selected workspace’s entries. Choose an entry to open its existing Telegram history or topic. The panel names the current account and refreshes available unread counts every second; unknown state is labeled as loading.
6. Use **Choose workspace** to select another workspace. Rename, move up/down, remove entries or remove a workspace in the panel. Removing a workspace requires confirmation and only removes its local associations.
7. **All chats** clears the workspace selection and returns to normal Telegram navigation, retaining the current Telegram folder. The workspace panel is an additional navigator; it does not filter the ordinary chat list.

The last selected workspace and workspace/member ordering survive restart. Returning to the selected project discussion requires two actions after login and chat loading: open Workspaces, then choose the discussion. When no workspace is selected, open Workspaces, choose the project, then choose the discussion (three actions). Choosing a different project from an already selected workspace also requires the Choose workspace control.

## Account and unavailable-entry behavior

Storage is per Telegram account. The record contains a schema version, owner ID, workspace UUIDs/names, selected workspace and stable peer/topic identifiers. Numeric identifiers are stored as decimal strings to preserve all 64 bits. Message contents, draft text, phone numbers, API values and credentials are not stored in workspace records.

The file is `felogram/workspaces` beneath that account’s existing encrypted storage directory. It uses Telegram Desktop’s local encryption key and verified decryption routine. A dedicated subdirectory keeps upstream legacy cleanup from deleting it. Atomic QSaveFile replacement with direct-write fallback disabled, a lock and comparison against the previous encrypted bytes prevent partial replacements and stale overwrites. Logout/reset removes the workspace file. Account removal follows the existing account cleanup; owner validation refuses records from another account.

Passcode lock blocks opening or changing workspaces. Panels close with their session controller. Topic lookup callbacks and unread refreshes guard against a destroyed controller or closed panel.

Archived chats retain their association. A deleted, left, inaccessible or not-yet-loaded entry remains removable and displays an unavailable state. Load a reachable chat through normal navigation and retry. Missing forum topics are requested on demand; deleted topics remain unavailable. Entries are never silently rebound to a different peer/account or automatically deleted from the workspace.

Unread state is read from Telegram’s existing history/topic objects. Navigation calls the existing showPeerHistory/showTopic functions; workspace code does not write the composer, recipient, messages, drafts or server folder configuration.

## Automated verification

The Debug test executes the production workspace model and atomic file helper with synthetic data. It covers CRUD, duplicate and invalid input, limits, Unicode names, workspace overlap, distinct chat/topic entries, full-width identifiers, selection/order/membership round trips, wrong owners, truncated records, unknown schemas, stale writes, held locks, cancelled QSaveFile replacements and inaccessible destinations.

With this repository’s prepared Windows dependencies:

```powershell
./scripts/windows/test-workspaces.ps1 -QtPrefixPath <Libraries>/win64/Qt-6.11.2
```

On this PC:

```powershell
./scripts/windows/test-workspaces.ps1 -QtPrefixPath E:/Explore/telgramRX/build/Libraries/win64/Qt-6.11.2 -OutputPath E:/Explore/telgramRX/build/felogram-workspace-tests
```

With an installed Qt6 Core development package on another platform:

```sh
cmake -S scripts/testing/workspaces -B .local/workspace-tests -DCMAKE_BUILD_TYPE=Debug
cmake --build .local/workspace-tests
ctest --test-dir .local/workspace-tests --output-on-failure
```

The full native CMake configuration also exposes the explicit `test_felogram_workspaces` target. Hosted checks run the small Qt Core test; the dedicated Windows native build runs it with prepared dependencies. Neither needs Telegram API credentials or sessions.

## Live acceptance matrix

Use owned test chats/accounts. Do not publish account identifiers, message contents, login screenshots, workspace records or session files as evidence. Record build revision, case ID, action count and pass/fail only.

| Case | Steps | Observable pass condition | Status |
| --- | --- | --- | --- |
| W1 CRUD | Create two workspaces, rename, reorder, remove one | Names/order persist; other workspace and chats survive | Pending live run |
| W2 project navigation | Add support, development and release chats; reopen app; open project discussion | Selected project survives; correct discussion opens in at most three actions | Pending live run |
| W3 topic/folder overlap | Add parent chat and topic; put chat in two workspaces and a Telegram folder | Correct topic opens; local removal leaves other workspace/folder/server membership intact | Pending live run |
| W4 draft/recipient | Type an unsent synthetic draft in support; navigate to development via Workspaces; return | Exact draft remains in support; development composer has its own recipient/draft; nothing sent | Pending live run |
| W5 unread | Receive a test message while panel is open; open entry | Count/mark follows upstream state; no unknown state displayed as zero | Pending live run |
| W6 unavailable | Archive a member; leave/delete a disposable owned test discussion; retry/remove entry | Archive still opens after loading; unavailable entry is explicit/removable; no wrong destination | Pending live run |
| W7 accounts | Create workspaces on account A; switch to B; switch back; reset disposable account | No A entry in B; A selection persists; reset removes only that account’s store | Blocked: second owned account unavailable |
| W8 keyboard/layout | Ctrl+Alt+W, Tab/Enter/Space/Escape; search, narrow layout, forum and animation | Workspace controls work without covering search/forum content or stealing draft text | Pending live run |

Gate remains open until the live journeys pass. Synthetic storage tests and compilation do not prove draft preservation, real unread delivery, layout quality or multi-account runtime isolation.
