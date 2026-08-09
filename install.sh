#!/usr/bin/env bash
#
# install.sh — symlink these dotfiles into $HOME
#
# For each package directory in this repo (hypr, quickshell, fish, ...),
# every file under <package>/.config/... or <package>/.local/... is
# symlinked to the matching path in $HOME. Anything already there (that
# isn't already the correct symlink) is backed up to
# ~/.dotfiles-backup/<timestamp>/ before being replaced.
#
# Usage:
#   ./install.sh                install everything
#   ./install.sh hypr fish      install only the given packages
#   ./install.sh -n              dry run: show what would happen, change nothing
#   ./install.sh -l              list available packages
#   ./install.sh -h              show this help
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0

usage() {
    sed -n '2,17p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

list_packages() {
    for dir in "$REPO_DIR"/*/; do
        name="$(basename "$dir")"
        [[ "$name" == .* ]] && continue
        echo "$name"
    done
}

while [ $# -gt 0 ]; do
    case "$1" in
        -n|--dry-run) DRY_RUN=1; shift ;;
        -l|--list) list_packages; exit 0 ;;
        -h|--help) usage; exit 0 ;;
        --) shift; break ;;
        -*) echo "unknown option: $1" >&2; usage >&2; exit 1 ;;
        *) break ;;
    esac
done

PACKAGES=("$@")
if [ ${#PACKAGES[@]} -eq 0 ]; then
    mapfile -t PACKAGES < <(list_packages)
fi

# Validate all requested packages up front so a typo doesn't leave things
# half-installed.
bad=0
for pkg in "${PACKAGES[@]}"; do
    if [ ! -d "$REPO_DIR/$pkg" ]; then
        echo "error: no such package: $pkg" >&2
        bad=1
    fi
done
if [ "$bad" -eq 1 ]; then
    echo "available packages:" >&2
    list_packages | sed 's/^/  /' >&2
    exit 1
fi

count_linked=0
count_ok=0
count_backed_up=0

# Symlink every individual file (rather than whole subtrees) so installing
# one package never clobbers unrelated siblings that already live under a
# shared parent such as ~/.local/share.
link_one() {
    local src="$1" dest="$2"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        count_ok=$((count_ok + 1))
        return # already linked correctly
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ "$DRY_RUN" -eq 1 ]; then
            echo "  [dry-run] would back up $dest"
        else
            mkdir -p "$BACKUP_DIR/$(dirname "${dest#"$HOME"/}")"
            mv "$dest" "$BACKUP_DIR/${dest#"$HOME"/}"
            echo "  backed up existing $dest"
        fi
        count_backed_up=$((count_backed_up + 1))
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        echo "  [dry-run] would link $dest -> $src"
    else
        mkdir -p "$(dirname "$dest")"
        ln -s "$src" "$dest"
    fi
    count_linked=$((count_linked + 1))
}

for pkg in "${PACKAGES[@]}"; do
    pkg_dir="$REPO_DIR/$pkg"
    echo "==> $pkg"
    while IFS= read -r -d '' file; do
        rel="${file#"$pkg_dir"/}"   # e.g. .config/hypr/hyprland.lua
        link_one "$file" "$HOME/$rel"
    done < <(find "$pkg_dir" -type f -print0)
done

echo
if [ "$DRY_RUN" -eq 1 ]; then
    echo "Dry run: $count_linked would be linked, $count_ok already correct, $count_backed_up would be backed up."
else
    echo "Done: $count_linked linked, $count_ok already correct, $count_backed_up backed up."
    [ "$count_backed_up" -gt 0 ] && echo "Backups are in $BACKUP_DIR"
    echo "Restart Hyprland / re-source your shell for changes to take effect."
fi
