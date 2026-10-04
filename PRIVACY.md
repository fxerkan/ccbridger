# Privacy Policy

**ccBridger** (`ccb`) is a local tool. It runs entirely on your own machine and does **not** collect, transmit, sell, or share any personal data with the author or any third party. There is no telemetry, no analytics, and no account with the author.

## What data is processed and where it goes

- **Local state only.** Session state (pending requests, decisions, transcripts) is stored as plain files under `~/.claude/ccbridger/` on your machine (mode `0700`). Nothing listens on the network.
- **The relay path uses your own Claude account.** When enabled, permission requests, questions, and the final message of a turn are sent to **your own** Claude mobile app through **your own** Claude login (Anthropic's Remote Control). That data is handled under [Anthropic's Privacy Policy](https://www.anthropic.com/legal/privacy), not by ccBridger. The body of a request may include the command or file being requested.
- **Optional `notify_cmd`.** If you configure a `notify_cmd` (e.g. a Slack/ntfy webhook), request text is sent to **whatever endpoint you choose**. You control that destination; send it only somewhere you trust.
- **Provider credentials are never read or exported.** When ccBridger starts its relay it *strips* provider environment variables (`env -u ANTHROPIC_MODEL -u ANTHROPIC_BASE_URL -u AWS_BEARER_TOKEN_BEDROCK …`). It does not read, log, or transmit AWS/Vertex/Foundry credentials.

## Your control

Everything lives under your `~/.claude` directory. Uninstall with `ccb uninstall` (or remove the plugin) and delete `~/.claude/ccbridger/` to remove all local state.

Questions: https://github.com/fxerkan/ccbridger/issues
