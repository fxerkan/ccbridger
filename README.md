<p align="center">
  <img src="https://raw.githubusercontent.com/fxerkan/ccbridger/main/docs/assets/hero-7.jpg" alt="ccBridger — Remote Control for API-based Claude Code sessions on Bedrock, Vertex and Foundry" width="820">
</p>

# ccBridg**er**

> **Remote Control for API-based Claude Code sessions — Bedrock, Vertex, Foundry.**
> In your pocket. No server, no open ports, one Python file.

Claude Code's Remote Control only works when you are signed in with a Claude subscription. Sessions that
run through an API provider — **AWS Bedrock, Google Vertex AI or Microsoft Foundry** — are stuck in the
terminal where you started them: walk away from the desk and a single permission prompt stalls the whole job.

`ccbridger` (short: `ccb`) bridges that gap. It lets you watch those sessions, approve or reject their
permission prompts, answer their questions and send them new instructions **from the Claude mobile app** —
with no server, no open ports and no extra account. One Python file, standard library only.

```
 terminal (API provider)                    your Mac / Linux box                    your phone
┌────────────────────┐  hooks   ┌──────────────────────────────┐  Remote   ┌──────────────────────┐
│ claude             │ ───────▶ │ ~/.claude/ccbridger (files)  │  Control  │ Claude app           │
│ Bedrock · Vertex · │ ◀─────── │ relay session (your Claude   │ ◀───────▶ │ "Approval - deploy   │
│ Foundry            │ decision │ login, AskUserQuestion only) │           │  - my-project"       │
└────────────────────┘          └──────────────────────────────┘           └──────────────────────┘
```

## Which sessions it covers

| Provider | How Claude Code is switched to it | Bridged by `--global` |
|---|---|---|
| AWS Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` | yes |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | yes |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` | yes |
| Claude subscription login | — | no: it already has Remote Control |

Nothing in the bridge is provider-specific: it works through Claude Code's hooks, which behave the same
whichever API serves the model. A per-project install bridges that project regardless of provider.

Developed and tested end to end on **AWS Bedrock**. Vertex AI and Foundry use the same code path and are
detected the same way, but have not been exercised with live sessions yet — reports are welcome.

## What you get

- **Approvals on your phone.** A permission prompt that sits unanswered for 15 seconds shows up in the
  Claude app as a native question with *Approve* / *Reject*. Answer it locally first and nothing is sent.
- **Questions too.** When the session asks you something (`AskUserQuestion`), the same question and
  options appear on the phone; your choice is mapped back by position, so it cannot drift.
- **A two-way conversation.** Type anything into that conversation and it is forwarded to the terminal
  session; the session's reply comes back into the same conversation. If the session is busy you are told
  what it is doing and that your message is queued.
- **One conversation per session**, titled by topic (`Approval - Prod upgrade - my-project`), so the
  history of what was asked and what you answered stays readable.
- **A CLI for everything else**: `ccb ls`, `ccb show`, `ccb send`, `ccb ok`, `ccb no`, `ccb answer`.

## Requirements

- macOS or Linux, `python3`, `tmux`
- Claude Code 2.1.x or newer (uses the `PermissionRequest` hook and `asyncRewake` hooks)
- For the phone side: a Claude subscription login on the same machine (`claude` → `/login`) and the
  Claude mobile app. Without one you can still use the CLI and a notifier — see below.

Developed and tested on macOS with Claude Code 2.1.195. Linux should work but has not been tested.

## Install

```bash
git clone https://github.com/fxerkan/ccbridger.git
cd ccbridger
ln -s "$PWD/ccbridger" ~/.local/bin/ccbridger    # anywhere on your PATH
ln -s "$PWD/ccbridger" ~/.local/bin/ccb          # short alias used below
ccb selftest                                     # offline check, prints "selftest OK"

ccb install --global                             # bridge every Bedrock / Vertex / Foundry session
# or only chosen projects, whatever provider they use:
ccb install ~/code/project-a ~/code/project-b
```

`--global` writes to `~/.claude/settings.json` and stays out of the way of sessions that run on a Claude
login. Per-project installs go to `.claude/settings.local.json`. Restart the sessions you want bridged.
`ccb uninstall` takes the same arguments.

Optional — teach your normal Remote Control session the commands, so you can just say
"what are my sessions doing?" or "approve the infra one":

```bash
mkdir -p ~/.claude/skills/ccb && cp skill/SKILL.md ~/.claude/skills/ccb/
```

## Use

| Command | What it does |
|---|---|
| `ccb ls` | Live sessions: id, status (`idle` / `busy` / `ASKING`), whether the bridge is active, directory |
| `ccb show <id> [n]` | Last n transcript entries and the full pending request |
| `ccb send <id> <message>` | Send a message to a session; wakes it if it is idle |
| `ccb ok <id>` · `ccb no <id> [why]` | Approve / reject the pending permission request |
| `ccb answer <id> <n\|text>` | Answer the question the session asked |
| `ccb open <id>` | Open the session's phone conversation without waiting for a request |
| `ccb ask <id>` | Push the pending request to the phone right now |

`<id>` is a session id prefix or any part of the project directory name.

## Teams: many people, one cloud account

API access is usually shared — one AWS account, one GCP project or one Azure resource for a whole team,
sometimes a single API key. The bridge is not shared: everything lives under each person's own `~/.claude`,
and the relay session runs on **that person's own Claude login**. So every developer installs ccBridger on
their own machine and gets their own approvals in their own Claude app; nobody sees or can answer anyone
else's prompts, and there is nothing central to run or secure.

Per-user settings go in `~/.claude/ccbridger/config.json`:

```json
{
  "lang": "en",
  "relay": true,
  "relay_model": "haiku",
  "relay_after": 15,
  "notify_cmd": "curl -s -d \"$CCB_BODY\" -H \"Title: $CCB_TITLE\" https://ntfy.sh/my-private-topic"
}
```

- `lang` — language of what you read on the phone: `en` or `tr`.
- `relay` — set to `false` if you have no Claude subscription; requests then only go to `notify_cmd`
  and you answer with `ccb ok` / `ccb no` / `ccb answer` (for example over SSH).
- `relay_after` — seconds a request waits locally before it is sent to the phone.
- `notify_cmd` — any shell command, run once per request with `CCB_TITLE`, `CCB_BODY`, `CCB_PROJECT`
  and `CCB_SESSION` in its environment. Use it for Slack, ntfy, Gotify, a pager — one per person.
  The body contains the command or file being requested, so send it only somewhere you trust.

## How it works

- **Hooks, not a wrapper.** A `PermissionRequest` hook records the request and waits for a decision
  file; the terminal prompt stays usable the whole time. `Stop`, `SessionStart`, `UserPromptSubmit` and
  `Notification` hooks keep one background waiter per session alive; when a message arrives it exits
  with code 2, which wakes the session (`asyncRewake`).
- **The relay.** A small helper session started in `tmux` on your Claude login, with Remote Control on
  and only the `AskUserQuestion` tool. The provider variables of the bridged session (Bedrock, Vertex,
  Foundry) are stripped from its environment. It turns each request into a native prompt in the Claude
  app. The model only phrases the question; **the decision is read by a hook, not by the model**, and
  only the exact *Approve* label counts as approval.
- **State** is plain files under `~/.claude/ccbridger/`, mode 0700. Nothing listens on the network.

## Limits you should know about

- A session started with `--dangerously-skip-permissions` never asks for permission, so there is nothing
  to approve; watching and messaging still work.
- Only the final message of a turn comes back to the phone, not every intermediate step.
- Answers to questions are delivered to the session as text ("the user answered: …"), which shows in the
  terminal as a denied tool call. The session continues with your answer.
- Remote messages appear in the terminal as "Stop hook feedback".
- The relay model may shorten a question's wording on the phone; the original text is in the message
  above it, and your choice is mapped by position.
- ccBridger reads Claude Code's session registry and drives the relay through `tmux`, so a future Claude
  Code release can break it. `ccb selftest` covers the queue logic, not the live integration.

## License

MIT
