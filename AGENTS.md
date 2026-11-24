# Working on SBrain

This repository is SBrain, a fork of pstack that runs in many coding agents. These rules are for an agent changing SBrain itself, not for using it.

- **Keep pstack's text where you can.** Every line changed in a file that came from pstack is a merge conflict waiting for the next upstream sync. Prefer a new file, an adapter row, or a change to `scripts/sync-upstream.sh` (for mechanical, repeatable changes) over editing an upstream file. `NOTICE.md` lists the deliberate forks.
- **Skills stay in Cursor wording.** Write `Task`, `AskQuestion`, and `subagent_type` as pstack does, and put each agent's mapping in `skills/skiddle-mode/references/harness/<agent>.md`. A new Cursor name in a skill needs a row in every adapter, and `scripts/check.sh` fails until it has one.
- **Principles trigger from the index.** A new `principle-<name>` skill needs a line in `skiddle-mode`'s Principles index, and its description starts with "Apply" and says when it applies. SBrain's own principles go in the "Production (SBrain)" group, so pstack's groups stay untouched. `scripts/check.sh` fails on a leaf without a line or a line without a leaf.
- **Skills are Agent Skills.** `name` matches the folder (lowercase, hyphens, at most 64 characters), and `description` is 1 to 1024 characters. Some agents silently drop a skill that breaks this.
- **Generated files.** Each skill's `agents/openai.yaml` and `skills/skiddle-mode/references/agents/comment-sicko.md` are generated. Change the source (the skill's `disable-model-invocation`, or `agents/comment-sicko.md`) and run `scripts/check.sh --fix`.
- **Done means checked.** Run `scripts/check.sh` before you finish. For an installer or hook change, also run `scripts/test-install.sh`, and add an assertion there for the behavior you changed.
- **Shell portability.** Scripts run on macOS's bash 3.2 and on Linux. No associative arrays, no `mapfile`, and guard empty arrays under `set -u`.
