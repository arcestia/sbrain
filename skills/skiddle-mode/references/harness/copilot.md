# SBrain in GitHub Copilot

This covers the Copilot CLI and VS Code's agent mode, which share one harness. Read [the rules for every agent](README.md) first, then map each Cursor name in a skill with the tables below.

## Install and invoke

`<sbrain>/scripts/install.sh --only copilot` links every skill into `~/.agents/skills/`, which Copilot reads, and writes the `skiddle-agent` and `comment-sicko` agents to `~/.copilot/agents/` as `.agent.md` files. The user types `/skiddle-mode`. Copilot silently drops a skill whose `name` does not match its folder, so `<sbrain>/scripts/check.sh` enforces that match.

## Tools

| Cursor | Copilot |
| --- | --- |
| `Task` | The `task` tool (`agent_type`, `prompt`, optional `model` and `mode`). VS Code also accepts `agent`. |
| `AskQuestion` | `ask_user` with a `choices` list, one question per call. It is single-select, so ask a multi-select question as a sequence. |
| Open a todolist, or copy steps into the todolist tool | The session's todo tool. Otherwise keep the list in your reply and update it at each phase. |
| Reading, editing, and searching files (`Grep`, `Glob`) | `view`, `edit`, `create`, `grep`, `glob`, and `bash`. |

## Subagent fields

| Cursor | Copilot |
| --- | --- |
| `subagent_type: generalPurpose` | `agent_type: "general-purpose"` |
| `subagent_type: "skiddle-agent"`, `"comment-sicko"` | `agent_type` with the same name, from `~/.copilot/agents/`. Where the agent type is rejected, as in some VS Code windows, use the README's general-subagent rule. |
| `readonly: true` | `agent_type: "explore"` for reading code, `"code-review"` for reviewing a diff. When a read-only role needs the shell, use `general-purpose` and say "do not edit files" in the brief. |
| `environment: "cloud"`, `cloud_base_branch: <b>` | Create a git worktree on `<b>` and tell the worker to work only there. |
| `environment: "local"` | Omit. |
| `run_in_background: true` | `mode: "background"`. Read the result with `read_agent` when you are notified. |
| `resume` | Start a new agent with the earlier result in its prompt. |
| `file_attachments` | List the paths in the prompt. |

## Models

| Cursor | Copilot |
| --- | --- |
| A model slug such as `claude-opus-5-5-xhigh-fast` or `gemini-4-neon-xhigh` | Not a Copilot model ID. The models an account can reach depend on its plan. Use the role's line in `~/.agents/sbrain-models.md`, else omit `model`. Pass the role's effort as `reasoning_effort`. |
| `~/.cursor/rules/sbrain-models.mdc` | `~/.agents/sbrain-models.md`. Read it at the start of a `skiddle-mode` run. |

## Paths

| Cursor | Copilot |
| --- | --- |
| `.cursor/skills/`, `~/.cursor/skills/` | `.github/skills/` or `.agents/skills/`, and `~/.agents/skills/` or `~/.copilot/skills/` |
| `.cursor/rules/*.mdc` | `AGENTS.md` or `.github/copilot-instructions.md` |
| Transcripts in `~/.cursor/projects/<slug>/agent-transcripts/` | Copilot's own session history for this workspace, when the session can read it. Otherwise skip the transcript step with the README's skip line. |
| Cursor's `/loop` | No built-in loop. Re-run the check yourself until it passes. |

## Format hook

The installer writes `~/.copilot/hooks/sbrain-format.json`, a `PostToolUse` hook (matcher `edit|create`) that runs `<sbrain>/hooks/format-on-edit.sh`. It is its own file, so it never changes other hooks. VS Code's hook support is a preview.
