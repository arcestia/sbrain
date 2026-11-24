# Harness adapters

SBrain's skills keep the Cursor names they inherited from pstack: `Task`, `AskQuestion`, `subagent_type`, Cursor model slugs, and `~/.cursor/...` paths. Cursor reads them as written. Every other agent reads its adapter once per session and maps each Cursor name through it.

| You are running in | Adapter |
| --- | --- |
| Cursor | [cursor.md](cursor.md) |
| Claude Code | [claude-code.md](claude-code.md) |
| OpenAI Codex (CLI, app) | [codex.md](codex.md) |
| GitHub Copilot (CLI, VS Code agent mode) | [copilot.md](copilot.md) |
| OpenCode | [opencode.md](opencode.md) |
| Gemini CLI, Antigravity CLI | [gemini.md](gemini.md) |
| Pi | [pi.md](pi.md) |
| Anything else that reads Agent Skills (Amp, Goose, Devin, Kiro, and others) | [generic.md](generic.md) |

## Rules for every agent

- **Unknown names.** A Cursor name or field with no row in your adapter is dropped, and your reply says so in one line. Never pass a field or value your tool schema rejects.
- **Where SBrain lives.** `<sbrain>` is the folder that holds `skills/`. Every SBrain skill sits at `<sbrain>/skills/<name>/SKILL.md`, which is `../<name>/SKILL.md` from any skill. Resolve symlinks to find it.
- **Running another SBrain skill.** "Run the **name** skill" or `/name` means read `<sbrain>/skills/<name>/SKILL.md` in full and follow it. This works in every agent, even where a skill tool refuses SBrain skills. When you tell the user what to type, use your adapter's invocation syntax.
- **Agents without SBrain's agent types.** Where your adapter says the agent has no `skiddle-agent` or `comment-sicko` type, start a general subagent instead. The first line of its brief is `Read <sbrain>/skills/skiddle-mode/worker.md before anything else.` The second line is `Read <sbrain>/skills/skiddle-mode/SKILL.md in full.` for the `skiddle-agent` role, or `Read <sbrain>/skills/skiddle-mode/references/agents/comment-sicko.md in full and act as that reviewer.` for `comment-sicko`.
- **Agents with no subagents.** Do delegated work yourself, one step at a time, and say in the reply that fan-out ran in sequence. Never fake an independent review. When a step needs a reviewer that did not write the code, run another agent CLI the user has installed on the diff in its own worktree, or leave the review open and say so.
- **Models.** The Cursor slugs in skills are pstack's defaults. Outside Cursor and Claude Code, `/setup-sbrain` writes role lines to `~/.agents/sbrain-models.md`, and you read that file at the start of a `skiddle-mode` run. With no file or no line for a role, omit the model so the agent runs on the session's model. A review panel needs distinct models. When only one model family is available, vary the reasoning effort instead, and say that the panel's diversity was reduced.
- **Formatting.** SBrain's format hook formats each edited file where your agent runs it. Where your adapter says there is no hook, the language skill's verify step runs the formatter before commit.

## Skills from other Cursor plugins and Cursor built-ins

pstack leaned on skills that ship outside it. None of these is a skip, so write no line for them.

| Cursor | Every agent |
| --- | --- |
| `/deslop` from `cursor-team-kit` | Your agent's code-simplify skill when it has one (your adapter names it). Otherwise review the diff yourself for dead code, one-caller wrappers, needless layers, and guards for states that cannot happen, then fix them. |
| `control-ui` from `cursor-team-kit` | Drive the running app with your agent's browser tools, or with Playwright when it has none. Use a real build, read the console, and capture the evidence. |
| `control-cli` from `cursor-team-kit` | Run the built binary or server from the shell with real inputs, and read its output, exit code, and logs. For an HTTP service, start it and call it with `curl`. |
| Cursor's `/loop` | Your adapter's loop or scheduling feature. Without one, re-run the check yourself until it passes or the run's stop condition hits. |
| Cursor's `/create-skill` | Your agent's skill-authoring skill when it has one. Otherwise write a folder holding a `SKILL.md` with `name` (matching the folder) and `description` frontmatter, a body under about 100 lines, and `references/` for detail. Then run `<sbrain>/scripts/check.sh`. |
| Cursor Custom Modes | None. Start each task with `skiddle-mode`. |

## Cursor-only features

When a step needs one of these, put one line in your reply, `Skipped in <agent>: <step>. <reason>.`, and go on. Do not stop, ask, or retry. When a later step needs what the skipped step made, leave a placeholder and name it in the line.

| Cursor | Every agent |
| --- | --- |
| Cursor Automations (routines, `update_state`, `api2.cursor.sh/automations` webhooks, `SendToUser` secret requests) | Skip with the line. |
| Bugbot | Bugbot comments on a GitHub PR are ordinary review threads. Triage them with `gh`. Skip a step that starts, waits for, or configures Bugbot when the PR has none. |
| Cursor cloud agents | `environment: "cloud"` becomes a git worktree, per your adapter. Skip a step that needs the cloud agent itself. |
| A built-in PR tool | `gh pr create`. Not a skip. |
| Origin's CLI (`origin pr ...`) | Take the step's `gh` branch. Not a skip. |
| `https://github.com/cursor/plugins/blob/main/pstack/<path>` | `<sbrain>/<path>` when that file exists. Read the local copy and never fetch it. |
