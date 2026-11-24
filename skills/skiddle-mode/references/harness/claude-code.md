# SBrain in Claude Code

Read [the rules for every agent](README.md) first, then map each Cursor name in a skill with the tables below. In Claude Code, SBrain installs as a plugin, so skills, agents, and commands carry the `sbrain:` prefix.

## Tools

| Cursor | Claude Code |
| --- | --- |
| `Task` | `Agent` |
| `AskQuestion` | `AskUserQuestion`. In `-p` mode it is absent, so ask in plain text. |
| Open a todolist, or copy steps into the todolist tool | Use `TodoWrite` if the session offers it. Otherwise keep the list in your reply and update it at each phase. |
| Run another SBrain skill (`/name` or "the **name** skill") | `Read` `<sbrain>/skills/<name>/SKILL.md` and follow it. The `Skill` tool refuses most SBrain skills. When you tell the user to type it, write `/sbrain:<name>`. |
| `Grep`, `Glob` | `Bash` with `rg` when the session has no `Grep` or `Glob`. |

## Subagent fields

| Cursor | Claude Code |
| --- | --- |
| `subagent_type: generalPurpose` | `subagent_type: "general-purpose"` |
| `skiddle-agent`, `comment-sicko` | `sbrain:skiddle-agent`, `sbrain:comment-sicko` |
| A Cursor model slug in a skill, such as `claude-opus-5-5-xhigh-fast` | Pass `model` and `effort` on every `Agent` call that spawns `sbrain:skiddle-agent`, mapped with the Models table. The agent file's own `model: opus` is only the fallback. |
| `readonly: true` | `subagent_type: "Explore"`. It keeps `Bash`, so the brief also says "do not edit files", and you check `git status` afterward. |
| `readonly: false` | `general-purpose`. It keeps the session's MCP servers. |
| `environment: "cloud"` | `isolation: "worktree"`. Name the branch or commit the worker checks out. |
| `environment: "local"` | Omit. |
| `cloud_base_branch: <b>` | Tell the worker to check out `<b>` first. |
| `run_in_background: true` | Omit. Subagents run in the background by default and notify you when they finish. |
| `resume` | Spawn a new agent and paste the earlier result into its brief. |
| `file_attachments` | List the paths in the brief. |

## Models

| Cursor | Claude Code |
| --- | --- |
| `claude-<family>-<version>-<effort>[-fast]`, such as `claude-opus-5-5-xhigh` | `model: "opus"` and `effort: "xhigh"`. `model` takes only `opus`, `sonnet`, `haiku`, `fable`. Drop `-fast`. |
| A `gemini-*` or other non-Claude slug | Omit `model` so the agent runs on the session model, and say so. |
| `auto` or `inherit-parent` | Omit `model`. |
| The `sbrain-models.mdc` rule, `~/.cursor/rules/sbrain-models.mdc` | `~/.claude/rules/sbrain-models.md`. Claude Code loads it into every new session, so its role lines are already in context. If they are not, read the file. If the file or the role's line is missing, use the skill's default slug. |
| A role value `<model> <effort>`, such as `opus high` | `model: "opus"` and `effort: "high"`. |

## setup-sbrain

Claude Code loads every `.md` file in `~/.claude/rules/` into each new session, so `setup-sbrain` writes its rule there. Follow its steps with these changes:

- Detect. The detected models are the `model` values that the `Agent` tool schema lists, each with an effort from its `effort` values. Write a real model as `<model> <effort>`, such as `opus xhigh`. The effort is the last token, so the budget step works as written.
- Defaults. Map each default slug with the rows above: `claude-opus-5-5-xhigh-fast` is `opus xhigh`, `claude-opus-5-5-high-fast` is `opus high`, `claude-fable-5-2-high` is `fable high`, and `gemini-4-neon-xhigh` is `inherit-parent`.
- Write. Write `~/.claude/rules/sbrain-models.md` with no frontmatter, then the comment lines, the `# budget` line, and one line per role from step 5. Overwrite the whole file. Never put the role lines in `CLAUDE.md` or `AGENTS.md`.

## Paths

| Cursor | Claude Code |
| --- | --- |
| `.cursor/skills/`, `~/.cursor/skills/` | `.claude/skills/`, `~/.claude/skills/` |
| `~/.cursor/plugins/`, `.cursor-plugin/plugin.json` | `~/.claude/plugins/`, `.claude-plugin/plugin.json` |
| `.cursor/rules/*.mdc`, always-applied rules | `CLAUDE.md`, or `AGENTS.md` when no `CLAUDE.md` exists. Claude Code never reads `.mdc` files. The model rule is the exception. See Models. |
| Transcripts in `~/.cursor/projects/<slug>/agent-transcripts/` | `~/.claude/projects/<slug>/<session>.jsonl`. The slug is the workspace path with each `/` and `.` changed to `-`, so `/Users/you/proj` is `-Users-you-proj`. The newest `.jsonl` directly in that folder is the current session. Its `<session>/subagents/` folder holds subagent transcripts. Read only this workspace's folder. |

## Claude Code specifics

| Cursor or SBrain need | Claude Code |
| --- | --- |
| Invoking an SBrain skill by name | The user types `/sbrain:<name>`. |
| `/deslop` | `/simplify` when the session lists it. |
| `control-ui` | The session's browser tools (the built-in browser or Claude in Chrome). |
| Cursor's `/loop` | Claude Code's `/loop` skill. |
| Cursor's `/create-skill` | The `skill-creator` skill when the session lists one, then `claude plugin validate <sbrain>`. |
| Format hook | Ships in the plugin (`hooks/hooks.json`). `SBRAIN_FORMAT_ON_EDIT=0` turns it off. |
