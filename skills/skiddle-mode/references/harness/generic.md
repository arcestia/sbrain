# SBrain in any other agent

Use this for any agent without its own SBrain adapter: Amp, Goose, Devin, Kiro, or anything else that reads Agent Skills. Read [the rules for every agent](README.md) first. Then find your agent's tool for each capability below and map each Cursor name to it.

## Install and invoke

`<sbrain>/scripts/install.sh --only skills` links every skill into `~/.agents/skills/`, which most agents read. The user asks for `skiddle-mode` by name, with the agent's own skill syntax.

Known notes:

- **Amp** also reads skills from Claude Code's plugin cache. If SBrain is installed in Claude Code too, Amp sees every skill twice. Keep one of the two.
- **Goose** reads agents from `~/.agents/agents/`. The installer's `skills` target writes `skiddle-agent` and `comment-sicko` there.
- **Devin** turns off model invocation with `triggers: [user]` instead of `disable-model-invocation`, so it may load SBrain skills on its own. Ask for `skiddle-mode` by name to keep the router in charge.

## Capabilities

| Cursor | What to use |
| --- | --- |
| `Task` | Your agent's subagent tool (Amp: `Task`. Goose: its delegation tool. Devin: `run_subagent`). With none, follow the README's rule for agents with no subagents. |
| `AskQuestion` | Your agent's question tool, or a plain-text question. |
| Open a todolist, or copy steps into the todolist tool | Your agent's todo tool, or a list in your reply that you update at each phase. |
| Reading, editing, and searching files (`Grep`, `Glob`) | Your agent's file tools and shell. |
| `subagent_type: generalPurpose` | Your agent's default subagent. |
| `subagent_type: "skiddle-agent"`, `"comment-sicko"` | Agents of that name when your agent loads them (Goose does, from `~/.agents/agents/`). Otherwise the README's general-subagent rule. |
| `readonly: true` | Say "do not edit files" in the brief, then check `git status` afterward. |
| `environment: "cloud"`, `cloud_base_branch: <b>` | Create a git worktree on `<b>` and tell the worker to work only there. |
| `environment: "local"`, `run_in_background: true` | Omit. |
| `resume` | Start a new subagent with the earlier result in its brief. |
| `file_attachments` | List the paths in the brief. |
| A model slug such as `claude-opus-5-5-xhigh-fast` | The role's line in `~/.agents/sbrain-models.md`, else omit the model. |
| `~/.cursor/rules/sbrain-models.mdc` | `~/.agents/sbrain-models.md`. Read it at the start of a `skiddle-mode` run. |
| `.cursor/rules/*.mdc` | `AGENTS.md`, which nearly every agent reads. |
| Transcripts in `~/.cursor/projects/<slug>/agent-transcripts/` | Skip the transcript step with the README's skip line, unless your agent can read its own history for this workspace. |
| Cursor's `/loop` | Your agent's loop or scheduler, or re-run the check yourself until it passes. |

## Format hook

`<sbrain>/hooks/format-on-edit.sh` reads the edited path from most hook payloads (see its header). If your agent can run a command after a file edit, point that hook at the script. Otherwise the language skill's verify step runs the formatter before commit.
