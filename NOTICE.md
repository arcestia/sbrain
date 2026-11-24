# Notice

SBrain is a modified fork of **pstack** by Lauren Tan ([poteto](https://x.com/poteto)), copyright (c) 2026 Lauren Tan, released under the MIT License. The license text is in [LICENSE](LICENSE) and applies to SBrain as a whole.

- Upstream: <https://github.com/cursor/plugins/tree/main/pstack>
- Forked from: the generated Claude Code tree `harness/pstack/claude-code`, at the commit and version recorded in [`.upstream-pstack`](.upstream-pstack)

SBrain changes pstack in these ways:

- Renamed identifiers: `poteto-mode` to `skiddle-mode`, `poteto-agent` to `skiddle-agent`, `poteto-help` to `skiddle-help`, `setup-pstack` to `setup-sbrain`, and the `pstack:` command prefix to `sbrain:`. [`scripts/sync-upstream.sh`](scripts/sync-upstream.sh) applies exactly these renames.
- Removed `make-bot-ui` (Cursor-hosted bot) and the duplicate root `plugin.json`.
- Mapped `cursor-team-kit` skills (`/deslop`, `control-ui`, `control-cli`) and Origin's CLI to Claude Code in the router, the playbooks, and the adapter.
- Added language skills for Go, Rust, Ruby, PHP, and React and Next.js, the `polyglot-boundaries` skill, a format-on-edit hook, and keep rules for tool-read comments in `comment-sicko`.
- Made the Shipping and Opening a PR playbooks wait for a teammate's review approval.

pstack's own README, with the author's introduction, is at the upstream link above.
