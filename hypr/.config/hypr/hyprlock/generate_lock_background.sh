#!/usr/bin/env bash
# Regenerates a screen-sized copy of the current wallpaper for hyprlock to
# use, so it doesn't have to decode+blur the full-resolution source image
# (which can be tens of megapixels) on every single lock — the likely cause
# of the screen briefly showing real content before the blur catches up.
#
# Called from switchwall.sh's post_process() on every wallpaper change; also
# safe to run standalone (falls back to the current wallpaperPath in
# config.json). Non-fatal on any failure — worst case, hyprlock just keeps
# using whatever it already has cached.
set -uo pipefail

CONFIG_JSON="$HOME/.config/illogical-impulse/config.json"
DEST="$HOME/.cache/hyprlock_background.jpg"

SRC="${1:-}"
if [ -z "$SRC" ]; then
    SRC=$(jq -r '.background.wallpaperPath // empty' "$CONFIG_JSON" 2>/dev/null)
fi
[ -n "$SRC" ] && [ -f "$SRC" ] || exit 0

# Videos already get a still frame extracted elsewhere for color generation;
# hyprlock only ever wants a static image, so skip those here.
case "$SRC" in
    *.mp4|*.webm|*.mkv|*.avi|*.mov) exit 0 ;;
esac

command -v magick &>/dev/null || command -v convert &>/dev/null || exit 0
command -v identify &>/dev/null || exit 0

TARGET_W=$(hyprctl monitors -j 2>/dev/null | jq '([.[].width] | max)' 2>/dev/null)
TARGET_H=$(hyprctl monitors -j 2>/dev/null | jq '([.[].height] | max)' 2>/dev/null)
[ -n "$TARGET_W" ] && [ "$TARGET_W" -gt 0 ] 2>/dev/null || TARGET_W=1920
[ -n "$TARGET_H" ] && [ "$TARGET_H" -gt 0 ] 2>/dev/null || TARGET_H=1080

SRC_W=$(identify -format "%w" "$SRC" 2>/dev/null || echo 0)

mkdir -p "$(dirname "$DEST")"

# Only bother re-encoding if the source is meaningfully bigger than the
# screen — no point processing an already-reasonably-sized wallpaper.
if [ "${SRC_W:-0}" -gt $((TARGET_W * 2)) ]; then
    magick "$SRC" -resize "${TARGET_W}x${TARGET_H}^" -gravity center \
        -extent "${TARGET_W}x${TARGET_H}" -quality 90 "$DEST.tmp" 2>/dev/null \
        && mv "$DEST.tmp" "$DEST"
else
    cp -f "$SRC" "$DEST"
fi
