#!/usr/bin/env bash
#
# install.sh — symlink these dotfiles into $HOME
#
# For each package directory in this repo (hypr, quickshell, fish, ...),
# every file under <package>/.config/... or <package>/.local/... is
# symlinked to the matching path in $HOME. Anything already there is
# backed up to ~/.dotfiles-backup/<timestamp>/ before being replaced.
#
# Usage:
#   ./install.sh              install everything
#   ./install.sh hypr fish    install only the given packages
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
PACKAGES=("$@")

if [ ${#PACKAGES[@]} -eq 0 ]; then
    for dir in "$REPO_DIR"/*/; do
        name="$(basename "$dir")"
        [[ "$name" == .* ]] && continue
        PACKAGES+=("$name")
    done
fi

# Symlink every individual file (rather than whole subtrees) so installing
# one package never clobbers unrelated siblings that already live under a
# shared parent such as ~/.local/share.
link_one() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        return # already linked correctly
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$BACKUP_DIR/$(dirname "${dest#"$HOME"/}")"
        mv "$dest" "$BACKUP_DIR/${dest#"$HOME"/}"
        echo "  backed up existing $dest"
    fi

    ln -s "$src" "$dest"
}

for pkg in "${PACKAGES[@]}"; do
    pkg_dir="$REPO_DIR/$pkg"
    if [ ! -d "$pkg_dir" ]; then
        echo "skipping unknown package: $pkg" >&2
        continue
    fi

    echo "==> $pkg"
    while IFS= read -r -d '' file; do
        rel="${file#"$pkg_dir"/}"   # e.g. .config/hypr/hyprland.lua
        link_one "$file" "$HOME/$rel"
    done < <(find "$pkg_dir" -type f -print0)
done

echo
echo "Done. Backups (if any) are in $BACKUP_DIR"
echo "Restart Hyprland / re-source your shell for changes to take effect."
