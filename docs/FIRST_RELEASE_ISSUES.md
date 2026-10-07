# First-release issue and dependency index

Published 2026-10-07. All entries below are planned work, with acceptance criteria and evidence requirements in their GitHub bodies. Issue status lives on GitHub; a link here does not mean the work is complete.

## Milestones

- First usable Windows alpha: 33 required issues.
- Windows beta and maintenance: two later issues.
- After first usable release: two deferred evaluation issues.

No deadline is committed. Dependencies mean acceptance must pass before the dependent issue can close; preparatory design can proceed earlier.

## Ordered backlog

| ID | Roadmap stage | Work item | Depends on | Scope |
| --- | --- | --- | --- | --- |
| CI1 | 1 | [Verify full dedicated Windows native build](https://github.com/Uvaisbugh/felogram-desktop/issues/5) | Foundation and release plan | First alpha |
| I1 | 3 | [Set independent application and welcome identity](https://github.com/Uvaisbugh/felogram-desktop/issues/6) | Foundation and release plan | First alpha |
| I2 | 3 | [Create and verify Windows icon assets](https://github.com/Uvaisbugh/felogram-desktop/issues/7) | [I1](https://github.com/Uvaisbugh/felogram-desktop/issues/6) | First alpha |
| I3 | 3 | [Separate storage, IPC and Windows associations](https://github.com/Uvaisbugh/felogram-desktop/issues/8) | [I1](https://github.com/Uvaisbugh/felogram-desktop/issues/6) | First alpha |
| I4 | 3 | [Verify coexistence with official Telegram](https://github.com/Uvaisbugh/felogram-desktop/issues/9) | [I2](https://github.com/Uvaisbugh/felogram-desktop/issues/7), [I3](https://github.com/Uvaisbugh/felogram-desktop/issues/8) | First alpha |
| A1 | 4 | [Gate builds on private maintainer API configuration](https://github.com/Uvaisbugh/felogram-desktop/issues/10) | [I3](https://github.com/Uvaisbugh/felogram-desktop/issues/8) | First alpha |
| A2 | 4 | [Verify login and session lifecycle with owned accounts](https://github.com/Uvaisbugh/felogram-desktop/issues/11) | [A1](https://github.com/Uvaisbugh/felogram-desktop/issues/10) | First alpha |
| A3 | 4 | [Define redacted diagnostics and private reporting](https://github.com/Uvaisbugh/felogram-desktop/issues/12) | [A1](https://github.com/Uvaisbugh/felogram-desktop/issues/10) | First alpha |
| M1 | 5 | [Verify text, navigation and draft behavior](https://github.com/Uvaisbugh/felogram-desktop/issues/13) | [A2](https://github.com/Uvaisbugh/felogram-desktop/issues/11) | First alpha |
| M2 | 5 | [Verify media, transfers and upstream call behavior](https://github.com/Uvaisbugh/felogram-desktop/issues/14) | [A2](https://github.com/Uvaisbugh/felogram-desktop/issues/11) | First alpha |
| M3 | 5 | [Verify account, network and Windows notification behavior](https://github.com/Uvaisbugh/felogram-desktop/issues/15) | [M1](https://github.com/Uvaisbugh/felogram-desktop/issues/13), [M2](https://github.com/Uvaisbugh/felogram-desktop/issues/14) | First alpha |
| L1 | 6 | [Design account-scoped local metadata schema](https://github.com/Uvaisbugh/felogram-desktop/issues/16) | [M3](https://github.com/Uvaisbugh/felogram-desktop/issues/15) | First alpha |
| L2 | 6 | [Implement atomic persistence and recovery](https://github.com/Uvaisbugh/felogram-desktop/issues/17) | [L1](https://github.com/Uvaisbugh/felogram-desktop/issues/16) | First alpha |
| W1 | 7 | [Implement workspace creation and membership](https://github.com/Uvaisbugh/felogram-desktop/issues/18) | [L2](https://github.com/Uvaisbugh/felogram-desktop/issues/17) | First alpha |
| W2 | 7 | [Implement workspace navigation and verify J2/J5](https://github.com/Uvaisbugh/felogram-desktop/issues/19) | [W1](https://github.com/Uvaisbugh/felogram-desktop/issues/18), [M1](https://github.com/Uvaisbugh/felogram-desktop/issues/13) | First alpha |
| B1 | 8 | [Implement bookmark references and original navigation](https://github.com/Uvaisbugh/felogram-desktop/issues/20) | [L2](https://github.com/Uvaisbugh/felogram-desktop/issues/17), [W2](https://github.com/Uvaisbugh/felogram-desktop/issues/19) | First alpha |
| B2 | 8 | [Implement bookmark notes, filters and verify J1](https://github.com/Uvaisbugh/felogram-desktop/issues/21) | [B1](https://github.com/Uvaisbugh/felogram-desktop/issues/20) | First alpha |
| C1 | 9 | [Implement exact code-entity clipboard copy](https://github.com/Uvaisbugh/felogram-desktop/issues/22) | [M1](https://github.com/Uvaisbugh/felogram-desktop/issues/13) | First alpha |
| C2 | 9 | [Add accessible code labels and wrapping controls](https://github.com/Uvaisbugh/felogram-desktop/issues/23) | [C1](https://github.com/Uvaisbugh/felogram-desktop/issues/22) | First alpha |
| S1 | 10 | [Implement account-scoped saved-query management](https://github.com/Uvaisbugh/felogram-desktop/issues/24) | [L2](https://github.com/Uvaisbugh/felogram-desktop/issues/17), [W2](https://github.com/Uvaisbugh/felogram-desktop/issues/19) | First alpha |
| S2 | 10 | [Rerun saved searches and verify J4](https://github.com/Uvaisbugh/felogram-desktop/issues/25) | [S1](https://github.com/Uvaisbugh/felogram-desktop/issues/24), [M3](https://github.com/Uvaisbugh/felogram-desktop/issues/15) | First alpha |
| K1 | 11 | [Implement command palette for existing actions](https://github.com/Uvaisbugh/felogram-desktop/issues/26) | [W2](https://github.com/Uvaisbugh/felogram-desktop/issues/19), [B2](https://github.com/Uvaisbugh/felogram-desktop/issues/21), [S2](https://github.com/Uvaisbugh/felogram-desktop/issues/25), [C2](https://github.com/Uvaisbugh/felogram-desktop/issues/23) | First alpha |
| U1 | 12 | [Verify scaling, keyboard use and Narrator](https://github.com/Uvaisbugh/felogram-desktop/issues/27) | [K1](https://github.com/Uvaisbugh/felogram-desktop/issues/26) | First alpha |
| U2 | 12 | [Verify Windows clipboard, lifecycle and interactions](https://github.com/Uvaisbugh/felogram-desktop/issues/28) | [I4](https://github.com/Uvaisbugh/felogram-desktop/issues/9), [K1](https://github.com/Uvaisbugh/felogram-desktop/issues/26) | First alpha |
| U3 | 12 | [Run five journeys with representative testers](https://github.com/Uvaisbugh/felogram-desktop/issues/29) | [U1](https://github.com/Uvaisbugh/felogram-desktop/issues/27), [U2](https://github.com/Uvaisbugh/felogram-desktop/issues/28), [B2](https://github.com/Uvaisbugh/felogram-desktop/issues/21), [S2](https://github.com/Uvaisbugh/felogram-desktop/issues/25), [W2](https://github.com/Uvaisbugh/felogram-desktop/issues/19), [C2](https://github.com/Uvaisbugh/felogram-desktop/issues/23) | First alpha |
| Q1 | 13 | [Measure native performance against upstream](https://github.com/Uvaisbugh/felogram-desktop/issues/30) | [U3](https://github.com/Uvaisbugh/felogram-desktop/issues/29) | First alpha |
| Q2 | 13 | [Verify resilience under interruption and disk pressure](https://github.com/Uvaisbugh/felogram-desktop/issues/31) | [L2](https://github.com/Uvaisbugh/felogram-desktop/issues/17), [S2](https://github.com/Uvaisbugh/felogram-desktop/issues/25) | First alpha |
| Q3 | 13 | [Track patches and rehearse an upstream update](https://github.com/Uvaisbugh/felogram-desktop/issues/32) | [U3](https://github.com/Uvaisbugh/felogram-desktop/issues/29), [Q2](https://github.com/Uvaisbugh/felogram-desktop/issues/31) | First alpha |
| R1 | 14 | [Audit redistribution and candidate source provenance](https://github.com/Uvaisbugh/felogram-desktop/issues/33) | [CI1](https://github.com/Uvaisbugh/felogram-desktop/issues/5), [Q1](https://github.com/Uvaisbugh/felogram-desktop/issues/30), [Q3](https://github.com/Uvaisbugh/felogram-desktop/issues/32), [A3](https://github.com/Uvaisbugh/felogram-desktop/issues/12) | First alpha |
| R2 | 14 | [Configure private signing and release identities](https://github.com/Uvaisbugh/felogram-desktop/issues/34) | [R1](https://github.com/Uvaisbugh/felogram-desktop/issues/33) | First alpha |
| R3 | 14 | [Verify clean-machine install, upgrade and removal](https://github.com/Uvaisbugh/felogram-desktop/issues/35) | [R2](https://github.com/Uvaisbugh/felogram-desktop/issues/34), [I4](https://github.com/Uvaisbugh/felogram-desktop/issues/9) | First alpha |
| R4 | 14 | [Design and verify an authenticated update path](https://github.com/Uvaisbugh/felogram-desktop/issues/36) | [R2](https://github.com/Uvaisbugh/felogram-desktop/issues/34), [Q3](https://github.com/Uvaisbugh/felogram-desktop/issues/32) | First alpha |
| R5 | 14 | [Publish the experimental first usable alpha](https://github.com/Uvaisbugh/felogram-desktop/issues/37) | [R3](https://github.com/Uvaisbugh/felogram-desktop/issues/35), [R4](https://github.com/Uvaisbugh/felogram-desktop/issues/36), [U3](https://github.com/Uvaisbugh/felogram-desktop/issues/29), [Q1](https://github.com/Uvaisbugh/felogram-desktop/issues/30), [Q2](https://github.com/Uvaisbugh/felogram-desktop/issues/31) | First alpha |
| T1 | 15 | [Triage alpha blockers and verify beta readiness](https://github.com/Uvaisbugh/felogram-desktop/issues/38) | [R5](https://github.com/Uvaisbugh/felogram-desktop/issues/37) | After alpha |
| T2 | 15 | [Establish stable release and security maintenance](https://github.com/Uvaisbugh/felogram-desktop/issues/39) | [T1](https://github.com/Uvaisbugh/felogram-desktop/issues/38) | After alpha |
| D1 | 9 | [Evaluate bounded text and log attachment previews](https://github.com/Uvaisbugh/felogram-desktop/issues/40) | [C2](https://github.com/Uvaisbugh/felogram-desktop/issues/23) | Deferred |
| D2 | 11 | [Evaluate focus profiles and independent windows](https://github.com/Uvaisbugh/felogram-desktop/issues/41) | [K1](https://github.com/Uvaisbugh/felogram-desktop/issues/26), [M3](https://github.com/Uvaisbugh/felogram-desktop/issues/15) | Deferred |

## Feature-to-journey coverage

| Release capability | Concrete user task / pass-fail contract | Implementation and verification issues |
| --- | --- | --- |
| Everyday messaging | Use two accounts for messaging, media, drafts, reconnect and notifications; recorded matrix passes | [A1](https://github.com/Uvaisbugh/felogram-desktop/issues/10), [A2](https://github.com/Uvaisbugh/felogram-desktop/issues/11), [M1](https://github.com/Uvaisbugh/felogram-desktop/issues/13), [M2](https://github.com/Uvaisbugh/felogram-desktop/issues/14), [M3](https://github.com/Uvaisbugh/felogram-desktop/issues/15) |
| Workspaces | J2: return to a project after restart; J5: preserve drafts and recipients | [L1](https://github.com/Uvaisbugh/felogram-desktop/issues/16), [L2](https://github.com/Uvaisbugh/felogram-desktop/issues/17), [W1](https://github.com/Uvaisbugh/felogram-desktop/issues/18), [W2](https://github.com/Uvaisbugh/felogram-desktop/issues/19) |
| Bookmarks and notes | J1: find a saved fix after restart and handle deleted/inaccessible originals honestly | [B1](https://github.com/Uvaisbugh/felogram-desktop/issues/20), [B2](https://github.com/Uvaisbugh/felogram-desktop/issues/21) |
| Exact code copy | J3: clipboard characters equal the selected raw entity across formatting fixtures | [C1](https://github.com/Uvaisbugh/felogram-desktop/issues/22), [C2](https://github.com/Uvaisbugh/felogram-desktop/issues/23) |
| Saved searches | J4: rerun persisted filters against current results with correct account context | [S1](https://github.com/Uvaisbugh/felogram-desktop/issues/24), [S2](https://github.com/Uvaisbugh/felogram-desktop/issues/25) |
| Keyboard navigation | Complete J1–J5 without a mouse and restore focus on palette dismissal | [K1](https://github.com/Uvaisbugh/felogram-desktop/issues/26), [U1](https://github.com/Uvaisbugh/felogram-desktop/issues/27), [U3](https://github.com/Uvaisbugh/felogram-desktop/issues/29) |

Detailed setup, actions and failure conditions are in [the release specification](FIRST_USABLE_RELEASE.md#acceptance-journeys). The [wireframes](design/first-release-wireframes.svg) precede implementation.

## Completion evidence

Each issue must link its implementation PR, tested source/artifact hash, Windows/device configuration and redacted logs, fixtures or screenshots covering every criterion. Evidence is currently pending for all new implementation issues. Existing [foundation results](WINDOWS_BASELINE.md) establish baseline setup only.

Issues I1–I4 cover roadmap stage 3; A1–A3 stage 4; M1–M3 stage 5; L1–L2 stage 6; W1–W2 stage 7; B1–B2 stage 8; C1–C2 and deferred D1 stage 9; S1–S2 stage 10; K1 and deferred D2 stage 11; U1–U3 stage 12; Q1–Q3 stage 13; R1–R5 stage 14; T1–T2 stage 15. CI1 closes the outstanding full dedicated native build check from the foundation.

Start with I1 (independent identity). CI1 is independently ready to verify the full native worker build. Account credentials and real-account verification require maintainer participation later; never put secrets in issues.
