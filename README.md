# SBrain

One command, `skiddle-mode`, that makes your coding agent work like a careful senior engineer: it restates the goal, picks a plan, writes less code, proves the change works, and opens a reviewable PR. It runs in Claude Code, Cursor, Codex, GitHub Copilot, OpenCode, Gemini CLI, Antigravity, Pi, and any other agent that reads Agent Skills, and it knows TypeScript, React, Next.js, Go, Rust, Ruby, and PHP.

SBrain is a fork of [pstack](https://github.com/cursor/plugins/tree/main/pstack) by Lauren Tan. See [NOTICE.md](NOTICE.md).

## Quick start

**1. Install.** One line sets up every agent it finds on your machine (macOS, Linux, or WSL, with `git` and `python3`):

```bash
curl -fsSL https://raw.githubusercontent.com/arcestia/sbrain/main/scripts/bootstrap.sh | bash
```

**2. Set it up in your agent.** Run `setup-sbrain` once. It asks for a reasoning budget and whether a teammate approves your PRs.

**3. Give it a real task.** State the goal and how you'll know it's done:

```text
/skiddle-mode The /orders endpoint in the Go API returns 500 when the cart is empty.
Done when an empty-cart request returns 422 with our problem+json body, and the
checkout page shows the validation message.
```

How you type it depends on the agent:

| Agent | Type |
| --- | --- |
| Claude Code | `/sbrain:skiddle-mode` |
| Codex | `$skiddle-mode` |
| Pi | `/skill:skiddle-mode` |
| Cursor, Copilot, and most others | `/skiddle-mode` |
| OpenCode, Gemini CLI, Antigravity | ask for `skiddle-mode` by name |

Stuck? Ask `skiddle-help`, for example "which skill reviews a PR?"

## Three more things to try

```text
/skiddle-mode Why do checkout requests time out under load? Don't change code.
```

```text
/skiddle-mode Add a `discount_code` field to orders, from the Laravel API through the
Next.js checkout form. Done when a valid code lowers the total in the browser.
```

```text
/skiddle-mode babysit PR 482
```

The first runs a read-only investigation. The second is a feature that crosses a language boundary, so SBrain changes the API contract first and checks both sides. The third drives a PR to merge-ready: fixing CI, answering review threads, and stopping before the merge.

## Keep it working

From your SBrain folder (`~/.sbrain` if you used the one-line install):

| Command | What it does |
| --- | --- |
| `scripts/install.sh --update` | Pull the latest SBrain and reinstall. Safe to run any time. |
| `scripts/install.sh --doctor` | Show which agents have SBrain, which toolchains exist, and what's missing. |
| `scripts/install.sh --only codex,cursor` | Set up only those agents. `--list` shows what was detected. |
| `scripts/install.sh --uninstall` | Remove only what SBrain added. |

Other ways in:

- **Claude Code only:** `/plugin marketplace add arcestia/sbrain`, then `/plugin install sbrain@sbrain`.
- **Skills only, any agent:** `npx skills add arcestia/sbrain`. You get the skills and adapters, but not the agent files or the format hook.

## What the installer sets up

| Agent | Skills | `skiddle-agent` and `comment-sicko` | Format-on-edit hook |
| --- | --- | --- | --- |
| Claude Code | plugin | plugin | yes |
| Cursor | `~/.agents/skills/` | `~/.cursor/agents/` | `afterFileEdit` in `~/.cursor/hooks.json` |
| Codex | `~/.agents/skills/` | `~/.codex/agents/*.toml` | `PostToolUse` in `~/.codex/hooks.json` (trust it once with `/hooks`) |
| GitHub Copilot (CLI, VS Code) | `~/.agents/skills/` | `~/.copilot/agents/` | `~/.copilot/hooks/sbrain-format.json` |
| OpenCode | `~/.agents/skills/` | `~/.config/opencode/agents/` | none (the language skill formats before commit) |
| Gemini CLI | `~/.agents/skills/` | `~/.gemini/agents/` | `AfterTool` in `~/.gemini/settings.json` |
| Antigravity CLI | `~/.gemini/config/skills/` | none (uses a general subagent) | none |
| Pi | `~/.agents/skills/` | none (Pi has no subagents) | none |
| Amp, Goose, Devin, others | `~/.agents/skills/` (`--only skills`) | `~/.agents/agents/` (Goose) | none |

Skills are symlinks into your SBrain folder, so `--update` changes every agent at once. The installer never overwrites a file it didn't write, and it backs up a JSON config once before its first change.

## What's inside

| Part | What it does |
|---|---|
| `skiddle-mode` | The router. It matches your task to a playbook (bug fix, feature, refactoring, investigation, perf issue, shipping, and 16 more), applies 24 engineering principles, delegates code to a subagent, and loads the language skill for every file it edits. |
| Language skills | `typescript-`, `react-`, `go-`, `rust-`, `ruby-`, and `php-best-practices`: the rules, the framework pitfalls (Next.js, Chi, Gin, Echo, Fiber, Axum, Rails, Hanami, Laravel), and the commands that prove a change. |
| `polyglot-boundaries` | Contract-first changes to anything two languages share, such as an API between a Next.js frontend and a Go backend. |
| Other skills | `how`, `why`, `architect`, `arena`, `swarm`, `interrogate`, `blast-radius`, `tdd`, `unslop`, `no-comments`, and more. `skiddle-help` explains each. |
| Adapters | `skills/skiddle-mode/references/harness/`: how each agent maps SBrain's tool names, and what replaces what it lacks. |
| Format hook | Formats each edited file with gofmt, rustfmt, Biome, Prettier, or RuboCop's layout rules, only where your repository uses them. `SBRAIN_FORMAT_ON_EDIT=0` turns it off. |

## How SBrain differs from pstack

- **Every agent, one source.** The skills keep pstack's wording, and each agent maps it through its adapter. Where an agent has no subagents or hooks, the adapter says what replaces them, and an independent review is never faked.
- **Polyglot verification.** "Verify on the matching surface" runs each stack's real toolchain. A toolchain missing on your machine (such as Rust or PHP in Docker) runs in the repository's container, and a skipped check never counts as a pass.
- **Review you choose.** With `review: team`, Shipping lands a PR only after a teammate approves it. With `review: solo`, your own go-ahead is enough.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for changing skills, adding an agent or a language, the checks, and pulling a newer pstack.
