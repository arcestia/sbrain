# SBrain in OpenCode

This covers OpenCode V2. Read [the rules for every agent](README.md) first, then map each Cursor name in a skill with the tables below.

## Install and invoke

`<sbrain>/scripts/install.sh --only opencode` links every skill into `~/.agents/skills/`, which OpenCode reads, and writes the `skiddle-agent` and `comment-sicko` agents to `~/.config/opencode/agents/` with `mode: subagent`. OpenCode loads a skill through its `skill` tool. It honors `disable-model-invocation`, so the user asks for `skiddle-mode` by name.

## Tools

| Cursor | OpenCode |
| --- | --- |
| `Task` | The `subagent` tool. |
| `AskQuestion` | The `question` tool. A subagent cannot ask the user, so it reports the question to you. |
| Open a todolist, or copy steps into the todolist tool | `todowrite`. |
| Reading, editing, and searching files (`Grep`, `Glob`) | OpenCode's file tools, `patch` for edits, and `shell` for `rg` and `find`. |

## Subagent fields

| Cursor | OpenCode |
| --- | --- |
| `subagent_type: generalPurpose` | OpenCode's general subagent. |
| `subagent_type: "skiddle-agent"`, `"comment-sicko"` | The agents of the same name in `~/.config/opencode/agents/`. |
| `readonly: true` | Say "do not edit files" in the brief, then check `git status` afterward. |
| `environment: "cloud"`, `cloud_base_branch: <b>` | Create a git worktree on `<b>` and tell the worker to work only there. |
| `environment: "local"` | Omit. |
| `run_in_background: true` | Omit, and keep working while the subagent runs when the tool allows it. |
| `resume` | Start a new subagent with the earlier result in its brief. |
| `file_attachments` | List the paths in the brief. |

## Models

| Cursor | OpenCode |
| --- | --- |
| A model slug such as `claude-opus-5-5-xhigh-fast` or `gemini-4-neon-xhigh` | Use the role's line in `~/.agents/sbrain-models.md`, written as `provider/model` (with `#variant` for an effort level), else omit the model. |
| `~/.cursor/rules/sbrain-models.mdc` | `~/.agents/sbrain-models.md`. Read it at the start of a `skiddle-mode` run. |

## Paths

| Cursor | OpenCode |
| --- | --- |
| `.cursor/skills/`, `~/.cursor/skills/` | `.opencode/skills/` or `.agents/skills/`, and `~/.config/opencode/skills/` or `~/.agents/skills/` |
| `.cursor/rules/*.mdc` | `AGENTS.md`, or `~/.config/opencode/AGENTS.md` for every project |
| Transcripts in `~/.cursor/projects/<slug>/agent-transcripts/` | OpenCode's own session storage for this project, when the session can read it. Otherwise skip the transcript step with the README's skip line. |
| Cursor's `/loop` | No built-in loop. Re-run the check yourself until it passes. |

## Format hook

None. OpenCode runs hooks only from code plugins, and SBrain ships none. The language skill's verify step runs the formatter before commit.
