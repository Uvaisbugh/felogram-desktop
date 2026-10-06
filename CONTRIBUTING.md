# Contributing to Felogram Desktop

Felogram is an independent Telegram Desktop fork for developers and power users. Open Felogram issues and pull requests in `Uvaisbugh/felogram-desktop`. See [the roadmap](ROADMAP.md) and [Windows build instructions](docs/FELOGRAM_BUILD_WINDOWS.md). The inherited Telegram contribution policy in `.github/CONTRIBUTING.md` describes upstream; this file governs contributions to Felogram.

Start with a small issue and an observable acceptance criterion. Product feature contributions are welcome within the roadmap. Keep a pull request focused, preserve upstream behavior, and avoid unrelated formatting or generated files. Explain the user-visible result, meaningful checks, limitations and upstream conflict risk. Preserve licenses and attribution; do not add assistant attribution trailers.

Develop and verify Debug builds. Run `scripts/windows/validate.ps1`, reproduce the relevant native behavior and record your OS/toolchain/source revisions. Fast repository checks do not establish that C++ compiles. Native CI runs manually because dependency preparation is expensive. GUI, account, accessibility and notification behavior need separate evidence on real devices/accounts. Do not post API credentials, session data, message contents or unredacted logs.

Keep Windows project text CRLF and UTF-8 without BOM. Follow `AGENTS.md` and `REVIEW.md` for native source conventions. Keep upstream protocol/session changes minimal and record preference migrations. Coordinate significant UX or storage changes before writing a large patch. See [SECURITY.md](SECURITY.md) for private vulnerability reports.

The required default-branch check is **Windows repository checks**. The native workflow is an explicit maintainer check; its uploaded Debug binaries are temporary development artifacts, not public releases.
