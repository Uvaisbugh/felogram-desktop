# Felogram Desktop

An independent Windows Telegram client for developers and power users, based on official Telegram Desktop. This fork is not affiliated with Telegram.

## Verified foundation

The independent checkout passed its Windows x64 Debug build, incremental rebuild and visual startup check on 2026-10-07. Dedicated native CI smoke also passed. See [the exact foundation evidence](docs/WINDOWS_BASELINE.md) for source, toolchain, hash and limitations. The native client now uses Felogram Dev branding and independent Windows identities; it still uses upstream test API configuration. See [identity evidence and remaining gates](docs/FELOGRAM_IDENTITY.md). No public Felogram Windows binary is released. Real account, messaging, notification and device tests remain open.

This repository preserves upstream source/history and its GPLv3 license with the OpenSSL exception. The MIT Python prototype is a separate project; its completion status does not apply to this native client.

## First product milestones

See [the full ordered implementation checklist](ROADMAP.md) for steps, dependencies and acceptance gates.

The [first usable release specification](docs/FIRST_USABLE_RELEASE.md) defines scope, personas, five pass/fail journeys and exclusions. Review the [interface sketches](docs/design/first-release-wireframes.svg) and [GitHub issue/dependency index](docs/FIRST_RELEASE_ISSUES.md) before starting feature implementation.

1. Independent Felogram name, icons, About/source links, profile identity and private maintainer API configuration.
2. Verify login, message exchange, files, reconnect, notifications and account isolation.
3. Local project workspaces: collect related groups, channels and saved references into a project view.
4. Code bookmarks: keep a reference to a useful message, with tags and personal notes; preserve message/code text when copying.
5. Reusable searches: save useful queries and filters for technical conversations.
6. Keyboard workflows and measured accessibility/performance improvements.
7. Signed builds, complete notices, installation/update/uninstallation checks and upstream merge rehearsals.

The identity portion of milestone 1 is implemented. Maintainer API configuration and the functional/distribution milestones remain open. Local preferences and notes must be account-scoped. No automatic sending or cloud sharing is implied.

## Separate projects

- Windows: https://github.com/Uvaisbugh/felogram-desktop
- Android: https://github.com/Uvaisbugh/felogram-android
- Python prototype and research: https://github.com/Uvaisbugh/felogram

Windows and Android share product goals and acceptance scenarios, with separate platform code, build systems and releases.

## Local baseline on the development PC

The active source is `E:/Explore/telgramRX/projects/felogram-desktop`. This PC reuses the prepared caches and output under `E:/Explore/telgramRX/build`; the independent development profile is `.local/felogram-dev` inside this checkout. The prototype workspace's `Run Native Windows.cmd` opens the verified executable through this repository's receipt-checking launch helper. Follow [the Windows build guide](docs/FELOGRAM_BUILD_WINDOWS.md), which separates fresh setup from this PC's existing-cache commands.
