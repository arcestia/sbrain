#!/usr/bin/env bash
# SBrain PostToolUse hook: format the file Claude just wrote with the repository's own formatter.
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

input=$(cat)
if command -v jq >/dev/null 2>&1; then
  file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
else
  file=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' 2>/dev/null)
fi
[ -n "${file:-}" ] && [ -f "$file" ] || exit 0

dir=$(cd "$(dirname "$file")" && pwd)
root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || printf '/')

has() { command -v "$1" >/dev/null 2>&1; }

# Nearest directory, from the file's folder up to the repository root, that holds any of the given names.
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
    app=$(nearest Gemfile) || exit 0
    if [ -f "$app/.rubocop.yml" ] && grep -qE '^[[:space:]]+rubocop[[:space:]]' "$app/Gemfile.lock" 2>/dev/null && has bundle; then
      (cd "$app" && bundle exec rubocop --autocorrect --only Layout --force-exclusion --format quiet "$file") >/dev/null 2>&1
    fi
    ;;
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.mts|*.cts|*.css|*.scss|*.json|*.jsonc)
    pkg=$(nearest package.json) || exit 0
    if [ -n "$(nearest biome.json biome.jsonc)" ] && [ -x "$pkg/node_modules/.bin/biome" ]; then
      (cd "$pkg" && node_modules/.bin/biome format --write "$file") >/dev/null 2>&1
    elif [ -x "$pkg/node_modules/.bin/prettier" ] && {
      [ -n "$(nearest .prettierrc .prettierrc.json .prettierrc.yml .prettierrc.yaml .prettierrc.json5 .prettierrc.js .prettierrc.cjs .prettierrc.mjs .prettierrc.ts .prettierrc.toml prettier.config.js prettier.config.cjs prettier.config.mjs prettier.config.ts)" ] ||
      grep -q '"prettier"[[:space:]]*:' "$pkg/package.json"; }; then
      (cd "$pkg" && node_modules/.bin/prettier --write --log-level warn "$file") >/dev/null 2>&1
    fi
    ;;
esac

exit 0
