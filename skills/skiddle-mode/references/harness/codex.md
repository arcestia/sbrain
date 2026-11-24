# SBrain in OpenAI Codex

Read [the rules for every agent](README.md) first, then map each Cursor name in a skill with the tables below.

## Install and invoke

`<sbrain>/scripts/install.sh --only codex` links every skill into `~/.agents/skills/`, which Codex reads, and writes the `skiddle-agent` and `comment-sicko` agents as TOML files in `~/.codex/agents/`. The user types `$skiddle-mode`, or picks it from `/skills`. Each SBrain skill that pstack marks `disable-model-invocation` also carries `agents/openai.yaml` with `allow_implicit_invocation: false`, so Codex loads it only when the user or another skill asks for it.

## Tools

| Cursor | Codex |
| --- | --- |
| `Task` | Spawn a subagent (`spawn_agent`, then `wait_agent` for its result). If no spawn tool exists, the session has subagents turned off. Follow the README's rule for agents with no subagents. |
| `AskQuestion` | Ask in plain text and wait for the answer. Codex has no fixed-choice question tool. |
| Open a todolist, or copy steps into the todolist tool | `update_plan`. |
| Reading, editing, and searching files (`Grep`, `Glob`) | The shell (`cat`, `rg`, `find`) and `apply_patch`. |

## Subagent fields

| Cursor | Codex |
| --- | --- |
| `subagent_type: generalPurpose` | A plain subagent. |
| `subagent_type: "skiddle-agent"`, `"comment-sicko"` | The custom agents of the same name in `~/.codex/agents/`. Without them, use the README's general-subagent rule. |
| `readonly: true` | Say "do not edit files" in the brief, then check `git status` afterward. |
| `environment: "cloud"`, `cloud_base_branch: <b>` | Create a git worktree on `<b>` and tell the worker to work only there. |
| `environment: "local"` | Omit. |
| `run_in_background: true` | Omit. Spawned agents already run alongside you. Collect results with `wait_agent`. |
| `resume` | Spawn a new agent with the earlier result in its brief. |
| `file_attachments` | List the paths in the brief. |

## Models

| Cursor | Codex |
| --- | --- |
| A model slug such as `claude-opus-5-5-xhigh-fast` or `gemini-4-neon-xhigh` | Not a Codex model. Use the role's line in `~/.agents/sbrain-models.md`, else omit the model. Pass the role's effort as the reasoning effort. |
| `~/.cursor/rules/sbrain-models.mdc` | `~/.agents/sbrain-models.md`. Read it at the start of a `skiddle-mode` run. `/setup-sbrain` writes it, listing the Codex models the user names. |

## Paths

| Cursor | Codex |
| --- | --- |
| `.cursor/skills/`, `~/.cursor/skills/` | `.agents/skills/`, `~/.agents/skills/` |
| `.cursor/rules/*.mdc` | `AGENTS.md` |
| Transcripts in `~/.cursor/projects/<slug>/agent-transcripts/` | `${CODEX_HOME:-~/.codex}/sessions/YYYY/MM/DD/*.jsonl`. The first line of each file is a `session_meta` record. Read only files whose `cwd` is this workspace or one of its worktrees. |
| Cursor's `/loop` | No built-in loop. Re-run the check yourself until it passes. |

## Format hook

The installer adds a `PostToolUse` entry (matcher `apply_patch|Edit|Write`) to `~/.codex/hooks.json`. It keeps any hooks already in that file. Codex runs a new hook only after the user trusts it through `/hooks`. The script reads the edited paths from the patch text.
