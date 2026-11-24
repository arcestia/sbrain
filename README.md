# SBrain

SBrain is my agent development process. It is a fork of [pstack](https://github.com/cursor/plugins/tree/main/pstack) by Lauren Tan, with the same router, playbooks, and principles. It is extended for the stacks I ship (TypeScript, React, and Next.js on the frontend, Go, Rust, Ruby, and PHP on the backend) and for every coding agent I use. See [NOTICE.md](NOTICE.md) for attribution and the full list of changes.

## Install

One script sets up every agent it finds on the machine:

```bash
~/sbrain/scripts/install.sh --list
```

```bash
~/sbrain/scripts/install.sh
```

| Agent | What the installer sets up | How you start a task |
| --- | --- | --- |
| Claude Code | The plugin from this folder's marketplace: skills, agents, and the format hook | `/sbrain:skiddle-mode` |
| Cursor | Skill links, `~/.cursor/agents/`, and an `afterFileEdit` hook | `/skiddle-mode` |
| OpenAI Codex | Skill links, `~/.codex/agents/*.toml`, and a `PostToolUse` hook (trust it once with `/hooks`) | `$skiddle-mode` |
| GitHub Copilot (CLI, VS Code) | Skill links, `~/.copilot/agents/`, and `~/.copilot/hooks/sbrain-format.json` | `/skiddle-mode` |
| OpenCode | Skill links and `~/.config/opencode/agents/` | ask for `skiddle-mode` |
| Gemini CLI | Skill links, `~/.gemini/agents/`, and an `AfterTool` hook | ask for `skiddle-mode` |
| Antigravity CLI | Skill links in `~/.gemini/config/skills/` | ask for `skiddle-mode` |
| Pi | Skill links | `/skill:skiddle-mode` |
| Amp, Goose, Devin, any Agent Skills client | Skill links in `~/.agents/skills/` (`--only skills`) | the agent's own skill syntax |

Skill links are symlinks into this folder, so edits here apply at once. The installer never overwrites a file it didn't write, saves a `.sbrain-backup` of any JSON config before its first change, and `--uninstall` removes only what it added. `--only codex,cursor` limits it, and `--dry-run` previews it.

Then run `setup-sbrain` once in each agent to pick a model and reasoning budget per role. Start real work with `skiddle-mode`, a goal, and a check that can pass or fail:

```text
/sbrain:skiddle-mode The /orders endpoint in the Go API returns 500 when the cart is empty.
Done when an empty-cart request returns 422 with our problem+json body, and the Next.js
checkout page shows the validation message.
```

`skiddle-help` answers questions about any skill or playbook.

## What's inside

| Part | What it does |
|---|---|
| `skills/skiddle-mode/` | The router. It matches a task to a playbook (bug fix, feature, refactoring, investigation, perf issue, shipping, and 16 more), applies the principles, delegates code to `skiddle-agent`, and loads the language skill for every file it edits. |
| `skills/skiddle-mode/references/harness/` | One adapter per agent. Each maps the Cursor names the skills use (`Task`, `AskQuestion`, model slugs, paths) to that agent's tools, and says what the agent can't do and what replaces it. `generic.md` covers any agent without its own adapter. |
| `skills/principle-*/` | pstack's 24 one-rule principles, unchanged. |
| Language skills | `typescript-best-practices` (pstack's), plus `react-best-practices` (React and Next.js), `go-best-practices` (`net/http`, Chi, Gin, Echo, Fiber), `rust-best-practices` (Tokio, Axum), `ruby-best-practices` (Rails, Sinatra, Hanami, plain Ruby), and `php-best-practices` (Laravel). Each lists the rules, the framework pitfalls, and the commands that prove a change in that stack. |
| `skills/polyglot-boundaries/` | Contract-first changes to anything two languages share: APIs, messages, webhooks, and tables. It covers int64 IDs in JavaScript, time, money, null versus absent, enums, casing, errors, and the expand, migrate, contract deploy order. |
| Other skills | pstack's understanding, design, verification, and hygiene skills (`how`, `why`, `architect`, `arena`, `swarm`, `interrogate`, `blast-radius`, `tdd`, `create-verification-skill`, `statechart`, `unslop`, `no-comments`, and more). |
| `agents/` | `skiddle-agent` (the delegate that reads the router first) and `comment-sicko` (the comment reviewer behind `no-comments`). Claude Code loads them from the plugin, and the installer writes each other agent's own format. |
| `hooks/format-on-edit.sh` | After an edit, formats the file with gofmt, rustfmt, Biome, Prettier, or RuboCop's Layout cops, only when the language or repository uses that formatter. It reads the edited path from every supported agent's hook payload, including Codex patches. PHP is left to Pint at commit time, because Pint removes unused imports mid-edit. `SBRAIN_FORMAT_ON_EDIT=0` turns it off. |
| `scripts/install.sh` | Installs, updates, and uninstalls SBrain for each agent. |
| `scripts/check.sh` | The portability check. See Change SBrain. |
| `docs/guide/` | pstack's upstream guide, kept for reference with commands renamed. |

## How my workflow differs from pstack's defaults

- **Every agent, one source.** The skills stay in pstack's Cursor wording, and each agent maps it through its adapter. Where an agent has no subagents (Pi) or no hooks (OpenCode, Antigravity, Pi), the adapter says what replaces them, and an independent review is never faked.
- **Polyglot verification.** "Verify on the matching surface" runs each stack's real toolchain. When a toolchain isn't on the host (for example Rust or PHP inside Docker), the language skill runs it in the repository's container, and a skipped check never counts as a pass.
- **Team review.** Teammates review every PR. Opening a PR writes for a reviewer who never saw the session, and Shipping lands only PRs with the required approval.

## Change SBrain

Edit the skills directly. To add a language or framework, copy the shape of an existing `*-best-practices` skill and add one line to the language trigger in `skills/skiddle-mode/SKILL.md`. To add an agent, write its adapter next to the others, list it in the harness `README.md`, and add its target to `scripts/install.sh`. Then run the check:

```bash
~/sbrain/scripts/check.sh --fix
```

It regenerates the generated files (each skill's Codex `agents/openai.yaml` and the portable `comment-sicko` copy), then fails on frontmatter that some agents silently reject, an adapter missing a Cursor name the skills use, a broken link, a script that doesn't parse, or a plugin that `claude plugin validate` rejects.

## Pull a newer pstack

The `upstream/pstack` branch holds pstack's Claude Code tree with only mechanical changes: identifiers renamed, and the adapters moved into the skill tree. Merging it into `main` conflicts only where pstack and SBrain changed the same lines.

```bash
git -C ~/sbrain worktree add ../sbrain-upstream upstream/pstack
```

```bash
~/sbrain/scripts/sync-upstream.sh ~/sbrain-upstream
```

```bash
git -C ~/sbrain-upstream add -A && git -C ~/sbrain-upstream commit -m "chore(upstream): sync pstack"
```

```bash
git -C ~/sbrain merge upstream/pstack
```

`.upstream-pstack` records which pstack commit and version SBrain last merged.
