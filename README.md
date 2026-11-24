# SBrain

SBrain is my agent development process for Claude Code. It is a fork of [pstack](https://github.com/cursor/plugins/tree/main/pstack) by Lauren Tan, with the same router, playbooks, and principles, extended for the stacks I ship: TypeScript, React, and Next.js on the frontend, and Go, Rust, Ruby, and PHP on the backend. See [NOTICE.md](NOTICE.md) for attribution and the full list of changes.

## Install

SBrain's folder is its own Claude Code marketplace:

```bash
claude plugin marketplace add ~/sbrain
```

```bash
claude plugin install sbrain@sbrain
```

Then, in a new session, run `/sbrain:setup-sbrain` once to pick a model and reasoning budget per role. Start real work with `/sbrain:skiddle-mode`, a goal, and a check that can pass or fail:

```text
/sbrain:skiddle-mode The /orders endpoint in the Go API returns 500 when the cart is empty.
Done when an empty-cart request returns 422 with our problem+json body, and the Next.js
checkout page shows the validation message.
```

`/sbrain:skiddle-help` answers questions about any skill or playbook.

## What's inside

| Part | What it does |
|---|---|
| `skills/skiddle-mode/` | The router. It matches a task to a playbook (bug fix, feature, refactoring, investigation, perf issue, shipping, and 16 more), applies the principles, delegates code to `skiddle-agent`, and loads the language skill for every file it edits. |
| `skills/principle-*/` | pstack's 24 one-rule principles, unchanged. |
| Language skills | `typescript-best-practices` (pstack's), plus `react-best-practices` (React and Next.js), `go-best-practices` (`net/http`, Chi, Gin, Echo, Fiber), `rust-best-practices` (Tokio, Axum), `ruby-best-practices` (Rails, Sinatra, Hanami, plain Ruby), and `php-best-practices` (Laravel). Each one lists the rules, the framework pitfalls, and the commands that prove a change in that stack. |
| `skills/polyglot-boundaries/` | Contract-first changes to anything two languages share: APIs, messages, webhooks, and tables. It covers int64 IDs in JavaScript, time, money, null versus absent, enums, casing, errors, and the expand, migrate, contract deploy order. |
| Other skills | pstack's understanding, design, verification, and hygiene skills (`/how`, `/why`, `/architect`, `/arena`, `/swarm`, `/interrogate`, `/blast-radius`, `/tdd`, `/create-verification-skill`, `/statechart`, `/unslop`, `/no-comments`, and more). |
| `agents/` | `skiddle-agent` (the delegate that reads the router first) and `comment-sicko` (the comment reviewer behind `/no-comments`). |
| `hooks/format-on-edit.sh` | After each `Write` or `Edit`, formats the file with gofmt, rustfmt, Biome, Prettier, or RuboCop's Layout cops, only when the language or repository uses that formatter. Missing tools are skipped. PHP is left to Pint at commit time, because Pint removes unused imports mid-edit. Set `SBRAIN_FORMAT_ON_EDIT=0` to turn it off. |
| `docs/harness/claude-code.md` | Maps the Cursor names that pstack skills still use to Claude Code tools, models, and paths. |
| `docs/guide/` | pstack's upstream guide, kept for reference with commands renamed. |

## How my workflow differs from pstack's defaults

- **Claude Code only.** No Cursor Custom Modes, Automations, or cloud agents. The adapter maps or skips each.
- **Polyglot verification.** "Verify on the matching surface" runs each stack's real toolchain. When a toolchain isn't on the host (for example Rust or PHP inside Docker), the language skill runs it in the repository's container, and a skipped check never counts as a pass.
- **Team review.** Teammates review every PR. Opening a PR writes for a reviewer who never saw the session, and Shipping lands only PRs with the required approval.

## Change SBrain

Edit the skills directly. Each skill is a `SKILL.md` with frontmatter. To add a language or framework, copy the shape of an existing `*-best-practices` skill and add one line to the language trigger in `skills/skiddle-mode/SKILL.md`. Validate after any change:

```bash
claude plugin validate ~/sbrain
```

## Pull a newer pstack

The `upstream/pstack` branch holds pstack's Claude Code tree with only its identifiers renamed, so merging it into `main` conflicts only where pstack and SBrain changed the same lines.

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
