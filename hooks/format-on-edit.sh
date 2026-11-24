#!/usr/bin/env bash
# SBrain after-edit hook: format each file the agent just wrote with the repository's own formatter.
#
# One script serves every agent that can run a command after an edit. It reads the hook payload on
# stdin and finds the edited paths in whichever shape the agent sends:
#   Claude Code, Gemini CLI, Devin   tool_input.file_path / tool_input.path
#   Cursor afterFileEdit             file_path
#   Copilot postToolUse              toolArgs (a JSON string) .path / .file_path
#   Codex apply_patch                the "*** Add File:" / "*** Update File:" lines of the patch
#   Antigravity                      toolCall.args.TargetFile
#   Goose AfterFileEdit              matcher_context
#
# Only formatters that change layout and never code run here, so a multi-step edit can't lose an
# import or a variable between steps. That rules out goimports, Pint, and php-cs-fixer (they delete
# unused imports) and limits RuboCop to its Layout cops. Each language skill runs the full fixers
# before commit.
#
# A formatter runs only when it is the language's canonical one (gofmt, rustfmt) or the repository
# configures it (Biome, Prettier, RuboCop). A missing tool is skipped. The hook never fails the edit.
set -u

[ "${SBRAIN_FORMAT_ON_EDIT:-1}" = "0" ] && exit 0
command -v python3 >/dev/null 2>&1 || exit 0

paths=$(python3 -I -c '
import json, os, re, sys

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
if not isinstance(data, dict):
    sys.exit(0)

found = []

def add(value):
    if isinstance(value, str) and value.strip():
        found.append(value.strip())

def add_from(obj, keys):
    if isinstance(obj, dict):
        for key in keys:
            add(obj.get(key))

def add_from_patch(text):
    if isinstance(text, list):
        text = "\n".join(str(part) for part in text)
    if isinstance(text, str) and "*** " in text:
        for match in re.finditer(r"^\*\*\* (?:Add File|Update File|Move to): (.+)$", text, re.M):
            add(match.group(1))

tool_input = data.get("tool_input")
add_from(tool_input, ("file_path", "path", "filePath", "target_file"))
if isinstance(tool_input, dict):
    for key in ("command", "input", "patch"):
        add_from_patch(tool_input.get(key))

add(data.get("file_path"))

tool_args = data.get("toolArgs")
if isinstance(tool_args, str):
    try:
        tool_args = json.loads(tool_args)
    except Exception:
        tool_args = None
add_from(tool_args, ("path", "file_path", "filePath"))

tool_call = data.get("toolCall")
if isinstance(tool_call, dict):
    add_from(tool_call.get("args"), ("TargetFile", "path", "file_path"))

add(data.get("matcher_context"))

cwd = data.get("cwd") if isinstance(data.get("cwd"), str) else os.getcwd()
seen = set()
for path in found:
    if not os.path.isabs(path):
        path = os.path.join(cwd, path)
    path = os.path.normpath(path)
    if path not in seen and os.path.isfile(path):
        seen.add(path)
        print(path)
' 2>/dev/null) || exit 0

[ -n "$paths" ] || exit 0

has() { command -v "$1" >/dev/null 2>&1; }

# Nearest directory, from $dir up to $root, that holds any of the given names.
nearest() {
  local d="$dir" name
  while :; do
    for name in "$@"; do
      [ -e "$d/$name" ] && { printf '%s' "$d"; return 0; }
    done
    { [ "$d" = "$root" ] || [ "$d" = "/" ]; } && return 1
    d=$(dirname "$d")
  done
}

format_one() {
  local file="$1" crate edition app pkg
  dir=$(cd "$(dirname "$file")" && pwd)
  root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || printf '/')

  case "$file" in
    *.go)
      has gofmt && gofmt -w "$file"
      ;;
    *.rs)
      if has rustfmt; then
        crate=$(nearest Cargo.toml) || crate=""
        edition=""
        [ -n "$crate" ] && edition=$(sed -nE 's/^[[:space:]]*edition[[:space:]]*=[[:space:]]*"([0-9]+)".*/\1/p' "$crate/Cargo.toml" | head -n1)
        rustfmt --edition "${edition:-2021}" "$file"
      fi
      ;;
    *.rb|*.rake|*/Gemfile)
      app=$(nearest Gemfile) || return 0
      if [ -f "$app/.rubocop.yml" ] && grep -qE '^[[:space:]]+rubocop[[:space:]]' "$app/Gemfile.lock" 2>/dev/null && has bundle; then
        (cd "$app" && bundle exec rubocop --autocorrect --only Layout --force-exclusion --format quiet "$file") >/dev/null 2>&1
      fi
      ;;
    *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.mts|*.cts|*.css|*.scss|*.json|*.jsonc)
      pkg=$(nearest package.json) || return 0
      if [ -n "$(nearest biome.json biome.jsonc)" ] && [ -x "$pkg/node_modules/.bin/biome" ]; then
        (cd "$pkg" && node_modules/.bin/biome format --write "$file") >/dev/null 2>&1
      elif [ -x "$pkg/node_modules/.bin/prettier" ] && {
        [ -n "$(nearest .prettierrc .prettierrc.json .prettierrc.yml .prettierrc.yaml .prettierrc.json5 .prettierrc.js .prettierrc.cjs .prettierrc.mjs .prettierrc.ts .prettierrc.toml prettier.config.js prettier.config.cjs prettier.config.mjs prettier.config.ts)" ] ||
        grep -q '"prettier"[[:space:]]*:' "$pkg/package.json"; }; then
        (cd "$pkg" && node_modules/.bin/prettier --write --log-level warn "$file") >/dev/null 2>&1
      fi
      ;;
  esac
  return 0
}

while IFS= read -r file; do
  [ -n "$file" ] && format_one "$file"
done <<EOF
$paths
EOF

exit 0
