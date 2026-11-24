#!/usr/bin/env bash
# Install or update SBrain with one command:
#
#   curl -fsSL https://raw.githubusercontent.com/arcestia/sbrain/main/scripts/bootstrap.sh | bash
#
# Pass installer options after `bash -s --`, for example to set up only Codex and Cursor:
#
#   curl -fsSL https://raw.githubusercontent.com/arcestia/sbrain/main/scripts/bootstrap.sh | bash -s -- --only codex,cursor
#
# It clones SBrain into $SBRAIN_HOME (default ~/.sbrain), or pulls the latest into an existing
# clone, then runs that clone's scripts/install.sh with your options. $SBRAIN_REPO overrides the
# repository URL, for a fork.
set -euo pipefail

repo=${SBRAIN_REPO:-https://github.com/arcestia/sbrain.git}
home=${SBRAIN_HOME:-$HOME/.sbrain}

for tool in git python3; do
  command -v "$tool" >/dev/null 2>&1 || { echo "SBrain needs $tool. Install it, then rerun." >&2; exit 1; }
done

if [ -d "$home/.git" ]; then
  echo "Updating SBrain in $home"
  git -C "$home" pull --ff-only --quiet
elif [ -e "$home" ]; then
  echo "$home exists and is not a git clone. Set SBRAIN_HOME to another folder and rerun." >&2
  exit 1
else
  echo "Cloning SBrain into $home"
  git clone --quiet --depth 1 "$repo" "$home"
fi

exec "$home/scripts/install.sh" "$@"
