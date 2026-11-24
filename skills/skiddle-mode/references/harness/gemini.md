# SBrain in Gemini CLI and Antigravity CLI

Google is moving Gemini CLI users to Antigravity CLI (`agy`). Both are covered here. Read [the rules for every agent](README.md) first, then map each Cursor name in a skill with the tables below.

## Install and invoke

- **Gemini CLI.** `<sbrain>/scripts/install.sh --only gemini` links every skill into `~/.agents/skills/`, which Gemini CLI reads, and writes the `skiddle-agent` and `comment-sicko` agents to `~/.gemini/agents/`. Gemini CLI loads a skill through `activate_skill`, which asks the user to consent.
- **Antigravity CLI.** `<sbrain>/scripts/install.sh --only antigravity` links every skill into `~/.gemini/config/skills/`, because Antigravity does not read `~/.agents/skills/`. SBrain writes no Antigravity agent files, so its subagents follow the README's general-subagent rule.

## Tools

| Cursor | Gemini CLI | Antigravity CLI |
| --- | --- | --- |
| `Task` | Call the agent's own tool (`skiddle-agent`, `comment-sicko`), or `@name`. | `invoke_subagent`. A worker that writes files runs as `self` with the brief from the README's general-subagent rule. |
| `AskQuestion` | Ask in plain text and wait for the answer. | Ask in plain text and wait for the answer. |
| Open a todolist, or copy steps into the todolist tool | `write_todos` when the session has it. Otherwise keep the list in your reply. | Keep the list in your reply and update it at each phase. |
| Reading, editing, and searching files (`Grep`, `Glob`) | `read_file`, `write_file`, `replace`, `glob`, `search_file_content`, `run_shell_command` | Antigravity's file tools and shell |

## Subagent fields

| Cursor | Both |
| --- | --- |
| `subagent_type: generalPurpose` | Gemini CLI's general agent, or `self` in Antigravity. |
| `subagent_type: "skiddle-agent"`, `"comment-sicko"` | Gemini CLI: the agents of the same name. Antigravity: the README's general-subagent rule. |
| `readonly: true` | Say "do not edit files" in the brief, then check `git status` afterward. |
| `environment: "cloud"`, `cloud_base_branch: <b>` | Create a git worktree on `<b>` and tell the worker to work only there. |
| `environment: "local"`, `run_in_background: true` | Omit. |
| `resume` | Start a new subagent with the earlier result in its brief. |
| `file_attachments` | List the paths in the brief. |

## Models

| Cursor | Both |
| --- | --- |
| A model slug such as `claude-opus-5-5-xhigh-fast` | Not a Gemini model. Use the role's line in `~/.agents/sbrain-models.md`, else `inherit`. Antigravity's agent models are `inherit`, `flash_lite`, `flash`, and `pro`. |
| `gemini-4-neon-xhigh` (a panel seat) | The strongest Gemini model the session can reach. |
| `~/.cursor/rules/sbrain-models.mdc` | `~/.agents/sbrain-models.md`. Read it at the start of a `skiddle-mode` run. |

## Paths

| Cursor | Both |
| --- | --- |
| `.cursor/skills/`, `~/.cursor/skills/` | Gemini CLI: `.agents/skills/`, `~/.agents/skills/`. Antigravity: `.agents/skills/`, `~/.gemini/config/skills/`. |
| `.cursor/rules/*.mdc` | `GEMINI.md`. Antigravity also reads `AGENTS.md`. |
| Transcripts in `~/.cursor/projects/<slug>/agent-transcripts/` | Skip the transcript step with the README's skip line, unless the session can read its own history. |
| Cursor's `/loop` | No built-in loop. Re-run the check yourself until it passes. |

## Format hook

- **Gemini CLI.** The installer adds an `AfterTool` entry (matcher `write_file|replace`) to `~/.gemini/settings.json`. It keeps every other setting.
- **Antigravity CLI.** None. The language skill's verify step runs the formatter before commit.
