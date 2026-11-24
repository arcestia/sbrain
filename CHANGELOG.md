# Changelog

## 0.2.0

- **Every agent.** SBrain runs in Cursor, Codex, GitHub Copilot, OpenCode, Gemini CLI, Antigravity CLI, Pi, and any Agent Skills client, alongside Claude Code. Each agent has an adapter in `skills/skiddle-mode/references/harness/`.
- **One-line install.** `scripts/bootstrap.sh` clones SBrain into `~/.sbrain` and runs the installer. `scripts/install.sh` sets up each detected agent, and gains `--update`, `--doctor`, `--uninstall`, `--only`, `--dry-run`, and `--list`.
- **Review you choose.** `setup-sbrain` asks whether a teammate approves PRs (`review: team`, the default) or you do (`review: solo`), and Shipping follows the answer.
- **Format hook for every agent.** `hooks/format-on-edit.sh` reads the edited path from each agent's hook payload, including Codex patches.
- **Checks.** `scripts/check.sh` (portability) and `scripts/test-install.sh` (installer, bootstrap, and hook) run in CI on macOS and Linux.
- Synced with pstack 0.15.48: the harness adapters moved into the skill tree.

## 0.1.0

- Forked pstack 0.15.48 as SBrain. The router is `skiddle-mode`, with `skiddle-agent` and `skiddle-help`.
- Added language skills for Go, Rust, Ruby, PHP, and React and Next.js, plus `polyglot-boundaries`.
- Shipping waits for a teammate's approval.
- Added the format-on-edit hook for Claude Code.
