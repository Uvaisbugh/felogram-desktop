# Felogram Desktop

An independent Windows Telegram client for developers and power users, based on official Telegram Desktop. This fork is not affiliated with Telegram.

## Verified foundation

The upstream revision `d8594c011756265de4385408540bd9f7c787a003` built successfully on Windows on 2026-10-06 using MSVC 14.44.35207, Qt 6.11.2, Ninja Multi-Config and Debug configuration. Its welcome screen was visually verified with a separate test profile. The local baseline executable still carries Telegram branding and uses upstream test API configuration. No public Felogram Windows binary is released. Real account, messaging, notification and device tests remain open.

This repository preserves upstream source/history and its GPLv3 license with the OpenSSL exception. The MIT Python prototype is a separate project; its completion status does not apply to this native client.

## First product milestones

See [the full ordered implementation checklist](ROADMAP.md) for steps, dependencies and acceptance gates.

1. Independent Felogram name, icons, About/source links, profile identity and private maintainer API configuration.
2. Verify login, message exchange, files, reconnect, notifications and account isolation.
3. Local project workspaces: collect related groups, channels and saved references into a project view.
4. Code bookmarks: keep a reference to a useful message, with tags and personal notes; preserve message/code text when copying.
5. Reusable searches: save useful queries and filters for technical conversations.
6. Keyboard workflows and measured accessibility/performance improvements.
7. Signed builds, complete notices, installation/update/uninstallation checks and upstream merge rehearsals.

Milestones 1–7 are planned, not implemented features in the running Windows baseline. Local preferences and notes must be account-scoped. No automatic sending or cloud sharing is implied.

## Separate projects

- Windows: https://github.com/Uvaisbugh/felogram-desktop
- Android: https://github.com/Uvaisbugh/felogram-android
- Python prototype and research: https://github.com/Uvaisbugh/felogram

Windows and Android share product goals and acceptance scenarios, with separate platform code, build systems and releases.

## Local baseline on the development PC

The proven build remains at `E:/Explore/telgramRX/build/tdesktop-baseline` while this separate source checkout is established. Its dependencies are cached under `E:/Explore/telgramRX/build/Libraries`; its test profile is `E:/Explore/telgramRX/build/native-desktop-profile`. From the prototype workspace, `scripts/build_native_windows.ps1` reproduces the Debug baseline and `scripts/run_native_baseline.ps1` launches it. Those local paths are evidence for this PC, not a portable build guide for this fresh checkout. Initialize pinned submodules and follow the upstream Windows build documentation for a separate fresh build.
