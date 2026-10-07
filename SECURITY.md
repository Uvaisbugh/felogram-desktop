# Security reporting

No Felogram production Windows release is available. The current Debug baseline uses upstream test API configuration and remains experimental.

For a suspected Felogram vulnerability, use GitHub's private vulnerability reporting at https://github.com/Uvaisbugh/felogram-desktop/security/advisories/new. Do not publish session files, login codes, passwords, API configuration, signing keys, personal messages or unredacted logs in an issue. Include the affected source revision, Windows version, reproduction with synthetic data where possible, impact and a suggested mitigation if known.

Reports will be reviewed by the project maintainer; no response-time guarantee is established yet. Upstream-only Telegram vulnerabilities should follow upstream's reporting policy. Felogram cannot restore banned accounts or provide Telegram service support.

Build credentials and future signing keys must stay outside tracked source. Public CI must not receive maintainer session data. Development profiles must remain separate from installed Telegram profiles.
