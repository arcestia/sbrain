### Opening a PR

Invoked at the end of every other playbook.

Work from a git worktree off trunk, and keep unrelated work out of it. Rebase into small, landable commits. Strip slop from the diff before commit, per the skiddle-mode Non-negotiables.

Title: `type(scope): subject`, naming a real symbol when one carries the change. Body: a one-minute briefing under 40 lines with these `##` headings in order, dropping empty ones: `## Why`, `## What changed`, `## Scope`, `## Tradeoffs` (only rejected alternatives a reviewer would otherwise ask about), `## Blast Radius`, `## Verification`.

Write the body for a reviewer who never saw this session, whether a teammate or the user weeks from now. Name in `## Verification` what you ran and what the reviewer can rerun.

Stack follow-ups by base branch. Open PRs ready, through the run's PR tool with `draft: false`. Without one, use `gh pr create` without `--draft`. Let the repository's CODEOWNERS or review rules pick reviewers, and add one by hand only when the user names them. Opening a PR does not start a babysit.
