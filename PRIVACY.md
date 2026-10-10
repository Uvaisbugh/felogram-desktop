# Felogram Desktop development privacy statement

Updated 2026-10-10. Felogram is an independent, experimental Telegram Desktop fork maintained in this repository. It is not affiliated with Telegram. This statement describes the development build; review it against each future release artifact.

Telegram account authorization, messages, media and other protocol operations use the inherited Telegram client and Telegram services. Telegram's [privacy policy](https://telegram.org/privacy) governs its services. The native client can also contact upstream-supported services needed for features such as media, links and network connectivity; this fork does not claim that all network requests go to one host. Account credentials and sessions remain in the selected local profile. Do not share that profile or raw logs.

Felogram development builds use separate local app data and Windows identities. Account-mode API configuration is stored in an ignored private file, with generated values confined to local build output rather than compiler command arguments or receipts. The Windows helpers restrict the API file, Account build output and Account profile to the current user and SYSTEM. Compiled binaries/debug symbols may still contain application values and must remain private before distribution review. Baseline mode disables sign-in and uses separate baseline profiles. See [manual account testing and diagnostic redaction](docs/REAL_ACCOUNT_TESTING.md).

Upstream automatic updates and crash report generation are disabled. The upstream crash uploader is removed from this fork's reporting actions. There is no Felogram automatic diagnostic upload, analytics service or external AI processing. Local launch/debug logs and Windows crash reports may contain sensitive metadata. Review and redact diagnostics before sharing anything through public issues; use private vulnerability reporting for security concerns.

The planned workspaces, bookmarks, notes and saved searches are not implemented in the identity baseline. Their agreed design stores account-scoped metadata locally without a new cloud sync backend or hidden copies of bookmarked message bodies. A future implementation must document its storage protection and deletion behavior before release.

Development launch does not register itself as the default `tg:` or `tonsite:` handler. A deliberate manual registration action can change Windows associations; it is optional. The project does not import official Telegram profiles automatically. Deleting local Felogram data can remove local sessions and future local-only notes; it does not delete server messages by itself.

For questions, use [Felogram issues](https://github.com/Uvaisbugh/felogram-desktop/issues). Follow [SECURITY.md](SECURITY.md) for private security reports. No public production binary or account/login verification is claimed by this development statement.
