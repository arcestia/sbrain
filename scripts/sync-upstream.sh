#!/usr/bin/env bash
# Rebuild the upstream/pstack tree: pstack's generated Claude Code harness, with its identifiers
# renamed to SBrain's and nothing else changed. SBrain's own edits live on main, so merging
# upstream/pstack into main brings in a newer pstack with conflicts only where both changed a line.
#
# Usage: scripts/sync-upstream.sh <out-dir> [cursor-plugins-checkout]
#   <out-dir>                  a worktree of the upstream/pstack branch. Its contents are replaced.
#   [cursor-plugins-checkout]  an existing clone of github.com/cursor/plugins. Without one, the
#                              script makes a shallow, sparse clone in a temporary folder.
set -euo pipefail

out=${1:?usage: scripts/sync-upstream.sh <out-dir> [cursor-plugins-checkout]}
src=${2:-}

if [ -z "$src" ]; then
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  git clone --quiet --depth 1 --filter=blob:none --sparse https://github.com/cursor/plugins "$tmp/plugins"
  git -C "$tmp/plugins" sparse-checkout set harness/pstack
  src="$tmp/plugins"
fi

tree="$src/harness/pstack/claude-code"
[ -d "$tree/skills/poteto-mode" ] || { echo "No pstack Claude Code tree at $tree" >&2; exit 1; }
rev=$(git -C "$src" rev-parse HEAD)
version=$(sed -nE 's/^[[:space:]]*"version":[[:space:]]*"([^"]+)".*/\1/p' "$tree/.claude-plugin/plugin.json" | head -n1)

mkdir -p "$out"
rsync -a --delete --exclude .git "$tree"/ "$out"/
cd "$out"

mv skills/poteto-mode skills/skiddle-mode
mv skills/poteto-help skills/skiddle-help
mv skills/setup-pstack skills/setup-sbrain
mv agents/poteto-agent.md agents/skiddle-agent.md
mv docs/guide/02-poteto-mode.md docs/guide/02-skiddle-mode.md

# Rename identifiers in every text file except the license, pstack's own README, images, and the
# statechart test corpus (golden outputs that never name pstack).
find . -type f \
  ! -path './.git/*' ! -path './LICENSE' ! -path './README.md' \
  ! -name '*.jpg' ! -name '*.jpeg' ! -name '*.png' ! -name '*.gif' ! -name '*.webp' \
  ! -path '*/test/corpus/*' -print0 |
  xargs -0 perl -pi -e '
    s/\@cursor-skill\/poteto-mode-tools/\@sbrain\/skiddle-mode-tools/g;
    s/poteto-mode-tools/skiddle-mode-tools/g;
    s/poteto-mode/skiddle-mode/g;
    s/poteto-agent/skiddle-agent/g;
    s/poteto-help/skiddle-help/g;
    s/setup-pstack/setup-sbrain/g;
    s/pstack-models/sbrain-models/g;
    s/\bpstack:/sbrain:/g;
    s/<pstack>/<sbrain>/g;
  '

printf 'cursor/plugins %s\npstack %s\n' "$rev" "$version" > .upstream-pstack
echo "Rebuilt pstack $version (cursor/plugins $rev) into $out"
