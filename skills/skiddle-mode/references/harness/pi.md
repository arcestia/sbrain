# SBrain in Pi

Read [the rules for every agent](README.md) first, then map each Cursor name in a skill with the tables below. Pi leaves subagents out by design, so every delegation falls back to the README's rule for agents with no subagents.

## Install and invoke

`<sbrain>/scripts/install.sh --only pi` links every skill into `~/.agents/skills/`, which Pi reads. The user types `/skill:skiddle-mode`.

## Tools

| Cursor | Pi |
| --- | --- |
| `Task` | None. Do the work yourself, in order. For an independent review, run another agent CLI the user has (such as `claude -p` or `codex exec`) on the diff in its own worktree, or leave the review open and say so. |
| `AskQuestion` | Ask in plain text and wait for the answer. |
| Open a todolist, or copy steps into the todolist tool | Keep the list in your reply and update it at each phase. |
| Reading, editing, and searching files (`Grep`, `Glob`) | `read`, `write`, `edit`, and `bash` with `rg` and `find`. |

## Subagent fields

None of these apply, because there is no subagent to pass them to: `subagent_type` (including `generalPurpose`, `skiddle-agent`, and `comment-sicko`), `readonly`, `environment`, `cloud_base_branch`, `run_in_background`, `resume`, and `file_attachments`. When you run a step that a `comment-sicko` subagent would run, read `<sbrain>/skills/skiddle-mode/references/agents/comment-sicko.md` and review as that reviewer, and say that the reviewer and the author were the same agent.

## Models

| Cursor | Pi |
| --- | --- |
| A model slug such as `claude-opus-5-5-xhigh-fast` | Pi runs one model per session. Ignore the slug. A review panel needs other agent CLIs, per the Tools table. |
| `~/.cursor/rules/sbrain-models.mdc` | `~/.agents/sbrain-models.md`, for the models of any other agent CLIs you run. |

## Paths

| Cursor | Pi |
| --- | --- |
| `.cursor/skills/`, `~/.cursor/skills/` | `.pi/skills/` or `.agents/skills/`, and `~/.pi/agent/skills/` or `~/.agents/skills/` |
| `.cursor/rules/*.mdc` | `AGENTS.md` |
| Transcripts in `~/.cursor/projects/<slug>/agent-transcripts/` | Skip the transcript step with the README's skip line. |
| Cursor's `/loop` | No built-in loop. Re-run the check yourself until it passes. |

## Format hook

None. Pi runs hooks only from TypeScript extensions, and SBrain ships none. The language skill's verify step runs the formatter before commit.
