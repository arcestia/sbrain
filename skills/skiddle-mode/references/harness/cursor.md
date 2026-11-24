# SBrain in Cursor

SBrain's skills are written in Cursor's own names, so almost nothing needs mapping. Read [the rules for every agent](README.md) for the shared parts. Only the differences from pstack's Cursor plugin are listed here.

## Install and invoke

`<sbrain>/scripts/install.sh --only cursor` links every skill into `~/.agents/skills/`, which Cursor reads, and writes the `skiddle-agent` and `comment-sicko` agents to `~/.cursor/agents/`. The user types `/skiddle-mode`. Cursor's CLI and Cloud Agents ignore agents in the home folder, so there they fall back to the general-subagent rule in the README.

## Names that differ from pstack

| Cursor | SBrain in Cursor |
| --- | --- |
| `Task`, `AskQuestion`, the todolist tool, `Grep`, `Glob` | As written. |
| `subagent_type: generalPurpose` | As written. |
| `subagent_type: "skiddle-agent"`, `"comment-sicko"` | As written. The installer writes both to `~/.cursor/agents/` with `model: inherit`. |
| `readonly`, `environment`, `cloud_base_branch`, `run_in_background`, `resume`, `file_attachments` | As written. |
| Model slugs such as `claude-opus-5-5-xhigh-fast` | As written. `/setup-sbrain` writes `~/.cursor/rules/sbrain-models.mdc`. |
| `/deslop`, `control-ui`, `control-cli` | The `cursor-team-kit` skills when that plugin is installed, else the README's table. |
| Transcripts in `~/.cursor/projects/<slug>/agent-transcripts/` | As written. |
| Cursor's `/loop`, `/create-skill` | As written. |

## Format hook

The installer adds an `afterFileEdit` entry to `~/.cursor/hooks.json` that runs `<sbrain>/hooks/format-on-edit.sh`. It keeps any hooks already in that file. `SBRAIN_FORMAT_ON_EDIT=0` turns it off.
