# Contributing to SBrain

[AGENTS.md](AGENTS.md) has the rules for an agent changing SBrain. This page is the same, for people. Commands run from the root of your SBrain clone.

## Change a skill

Edit `skills/<name>/SKILL.md`. Keep pstack's wording where you can, because every changed upstream line is a future merge conflict. The skills use Cursor's tool names (`Task`, `AskQuestion`), and the adapters in `skills/skiddle-mode/references/harness/` map them for each agent.

- **New language or framework.** Copy the shape of an existing `*-best-practices` skill, then add one line to the language trigger in `skills/skiddle-mode/SKILL.md`.
- **New principle.** Add `skills/principle-<name>/SKILL.md` (a description that starts with "Apply when", and a short body), plus one line in the "Production (SBrain)" group of `skiddle-mode`'s Principles index. The check fails until both exist.
- **New agent.** Write `skills/skiddle-mode/references/harness/<agent>.md` next to the others, list it in that folder's `README.md`, and add a target to `scripts/install.sh` (its detection, install, uninstall, and doctor lines).

## Check your change

```bash
scripts/check.sh --fix
```

```bash
scripts/test-install.sh
```

`check.sh --fix` regenerates the generated files (each skill's Codex `agents/openai.yaml` and the portable `comment-sicko` copy). It then fails on:

- skill frontmatter that some agents silently reject;
- an adapter missing a Cursor name the skills use;
- a broken link, or a script that doesn't parse;
- a plugin that `claude plugin validate` rejects.

`test-install.sh` installs, reinstalls, and uninstalls SBrain in a throwaway home folder, with stub agent CLIs. It checks that every agent gets its files, that existing user files survive, and that uninstall leaves only what was there before. CI runs both on macOS and Linux for every push.

## Release

Bump `version` in `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`, add a section to [CHANGELOG.md](CHANGELOG.md), and tag the commit `v<version>`.

## Pull a newer pstack

The `upstream/pstack` branch holds pstack's Claude Code tree with only mechanical changes: identifiers renamed, and the adapters moved into the skill tree. `scripts/sync-upstream.sh` makes those changes, so merging the branch into `main` conflicts only where pstack and SBrain changed the same lines.

```bash
git worktree add ../sbrain-upstream upstream/pstack
```

```bash
scripts/sync-upstream.sh ../sbrain-upstream
```

```bash
git -C ../sbrain-upstream add -A && git -C ../sbrain-upstream commit -m "chore(upstream): sync pstack"
```

```bash
git merge upstream/pstack
```

`.upstream-pstack` records which pstack commit and version SBrain last merged.
