#!/usr/bin/env bash
#
# update.sh — pull the latest version of this repo and re-link it
#
# Fetches from the configured git remote, fast-forwards the current
# branch, then re-runs install.sh so any newly added files get linked
# too. Refuses to touch anything if the working tree has local changes
# (commit or stash them first) or if history has diverged (needs a
# manual merge/rebase).
#
# Usage:
#   ./update.sh              pull + re-install everything
#   ./update.sh --no-install pull only, don't touch symlinks
#   ./update.sh -n            dry run: show what install.sh would do after pulling
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

RUN_INSTALL=1
INSTALL_ARGS=()

for arg in "$@"; do
    case "$arg" in
        --no-install) RUN_INSTALL=0 ;;
        -n|--dry-run) INSTALL_ARGS+=("-n") ;;
        *) INSTALL_ARGS+=("$arg") ;;
    esac
done

if ! git -C "$REPO_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
    echo "error: $REPO_DIR is not a git repo" >&2
    exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
    echo "error: you have local changes in $REPO_DIR" >&2
    echo "commit, stash, or discard them before updating:" >&2
    git status --short | sed 's/^/  /' >&2
    exit 1
fi

branch="$(git rev-parse --abbrev-ref HEAD)"
remote="$(git config "branch.$branch.remote" || echo origin)"

echo "==> fetching $remote"
git fetch --quiet "$remote"

before="$(git rev-parse HEAD)"
upstream="$remote/$branch"
after="$(git rev-parse "$upstream" 2>/dev/null || true)"

if [ -z "$after" ]; then
    echo "error: no $upstream branch to track" >&2
    exit 1
fi

if [ "$before" = "$after" ]; then
    echo "already up to date."
    RUN_INSTALL=0
else
    if ! git merge-base --is-ancestor "$before" "$after"; then
        echo "error: local branch has diverged from $upstream" >&2
        echo "resolve manually (git pull --rebase, or reset), then re-run." >&2
        exit 1
    fi

    echo "==> updating $branch: $(git rev-parse --short "$before") -> $(git rev-parse --short "$after")"
    git merge --ff-only --quiet "$upstream"

    echo
    echo "changes:"
    git diff --stat "$before" "$after" | sed 's/^/  /'
fi

if [ "$RUN_INSTALL" -eq 1 ]; then
    echo
    echo "==> re-linking (install.sh ${INSTALL_ARGS[*]:-})"
    "$REPO_DIR/install.sh" "${INSTALL_ARGS[@]}"
fi
