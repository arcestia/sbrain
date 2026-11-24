# SBrain in Claude Code

SBrain skills keep the Cursor names they inherited from pstack. SBrain runs only in Claude Code, so read this file once per session, then map each Cursor name in a skill with the tables below. `<sbrain>` means the folder that holds `skills/` and `docs/`. If a Cursor field has no row, drop it and say so. Never pass a field or value the tool schema rejects.

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
| `https://github.com/cursor/plugins/blob/main/pstack/<path>` | `<sbrain>/<path>` when that file exists. The plugin ships the skills, `docs/guide/`, and `README.md`. Read the local copy and never fetch it. Give the user the URL when they need a link. |
| Transcripts in `~/.cursor/projects/<slug>/agent-transcripts/` | `~/.claude/projects/<slug>/<session>.jsonl`. The slug is the workspace path with each `/` and `.` changed to `-`, so `/Users/you/proj` is `-Users-you-proj`. The newest `.jsonl` directly in that folder is the current session. Its `<session>/subagents/` folder holds subagent transcripts. Read only this workspace's folder. |

## Cursor-only features

Claude Code has no Cursor Automations, Bugbot, Cursor cloud agents, or built-in PR tool. When a step needs one, put one line in your reply, `Skipped in Claude Code: <step>. <reason>.`, then go on to the next step. Do not stop, ask, or retry. When a later step needs what the skipped step made, such as a URL or a key, leave a placeholder and name it in the line.

| Cursor | Claude Code |
| --- | --- |
| Cursor Automations: routines, `update_state` routine calls, `api2.cursor.sh/automations` webhooks, routine wakes, and `SendToUser` secret requests | Skip with the line. |
| Bugbot | Bugbot comments on a GitHub PR are ordinary review threads, so triage them with the forge command that the step gives. Skip a step that starts, waits for, or configures Bugbot when the PR has no Bugbot check or comment. |
| Cursor cloud agents | `environment: "cloud"` maps to a worktree, as in Subagent fields. Skip a step that needs the cloud agent itself, such as its dashboard status or its own machine. |
| A built-in PR tool | Use the forge command that the step gives, such as `gh pr create`. That is not a skip, so write no line. |
| Origin's CLI (`origin pr ...`) | A Cursor-internal forge. SBrain repositories live on GitHub, so take the step's `gh` branch and write no line. |

## Skills from other Cursor plugins

pstack leaned on skills that ship outside it. SBrain maps each one to Claude Code. None of these is a skip, so write no line.

| Cursor | Claude Code |
| --- | --- |
| `/deslop` from `cursor-team-kit` | `/simplify` when the session lists it. Otherwise review the diff yourself for dead code, one-caller wrappers, needless layers, and guards for states that cannot happen, then fix them. |
| `control-ui` from `cursor-team-kit` | Drive the running app in the session's browser tools (the built-in browser or Claude in Chrome), or in Playwright when neither exists. Use a real build, read the console, and capture the evidence. |
| `control-cli` from `cursor-team-kit` | Run the built binary or server through `Bash` with real inputs, and read its output, exit code, and logs. For an HTTP service, start it and call it with `curl`. |
| Cursor's `/loop` | Claude Code's `/loop` skill. |
| Cursor's `/create-skill` | The `skill-creator` skill when the session lists one. Otherwise write the skill by hand: a folder holding a `SKILL.md` with `name` and `description` frontmatter, a body under about 100 lines, and `references/` for detail. Then run `claude plugin validate` on the plugin folder. |
| Cursor Custom Modes | None. Start each task with `/sbrain:skiddle-mode`. |
