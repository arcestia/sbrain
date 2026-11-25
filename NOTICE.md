# Notice

SBrain is a modified fork of **pstack** by Lauren Tan ([poteto](https://x.com/poteto)), copyright (c) 2026 Lauren Tan, released under the MIT License. The license text is in [LICENSE](LICENSE) and applies to SBrain as a whole.

- Upstream: <https://github.com/cursor/plugins/tree/main/pstack>
- Forked from: the generated Claude Code tree `harness/pstack/claude-code`, at the commit and version recorded in [`.upstream-pstack`](.upstream-pstack)

SBrain changes pstack in these ways:

- Renamed identifiers: `poteto-mode` to `skiddle-mode`, `poteto-agent` to `skiddle-agent`, `poteto-help` to `skiddle-help`, `setup-pstack` to `setup-sbrain`, and the `pstack:` command prefix to `sbrain:`. Moved the Claude Code adapter into `skills/skiddle-mode/references/harness/` and pointed every skill at "your agent's adapter". [`scripts/sync-upstream.sh`](scripts/sync-upstream.sh) applies exactly these mechanical changes.
- Added adapters for Cursor, Codex, GitHub Copilot, OpenCode, Gemini CLI and Antigravity CLI, Pi, and any other Agent Skills client, plus an installer and a portability check. The design (one shared skill tree, a mapping per agent, generated per-agent files) follows the approach of Michael Denyer's MIT-licensed [pstack-claude](https://github.com/michael-denyer/pstack-claude) port. SBrain copies none of its files.
- Removed `make-bot-ui` (Cursor-hosted bot) and the duplicate root `plugin.json`.
- Mapped `cursor-team-kit` skills (`/deslop`, `control-ui`, `control-cli`) and Origin's CLI to Claude Code in the router, the playbooks, and the adapter.
- Added language skills for Go, Rust, Ruby, PHP, and React and Next.js, the `polyglot-boundaries` skill, a format-on-edit hook, and keep rules for tool-read comments in `comment-sicko`.
- Made the Shipping playbook wait for a teammate's review approval, unless `setup-sbrain` records `review: solo`, and had the Opening a PR playbook write its body for a reviewer and leave picking reviewers to the repository.
- Added production principles (Old and New Run Together, Design for Partial Failure, Evaluate Nondeterministic Changes) in their own group of the `skiddle-mode` Principles index and their own section of the principles guide, plus a check that keeps the index and the `principle-*` skills in step.

pstack's own README, with the author's introduction, is at the upstream link above.
