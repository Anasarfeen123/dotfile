#!/usr/bin/env bash
WALLPAPER=$(cat ~/.local/state/quickshell/user/generated/wallpaper/path.txt 2>/dev/null)
if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
  echo "No wallpaper found at ~/.local/state/quickshell/user/generated/wallpaper/path.txt"
  exit 1
fi
matugen image "$WALLPAPER" -m dark --type scheme-fidelity --prefer saturation -c ~/.config/matugen/config.toml
# Reload kitty if running
kill -SIGUSR1 $(pidof kitty) 2>/dev/null
# Copy SDDM theme config
sudo cp /tmp/sddm-matugen.conf /usr/share/sddm/themes/silent/configs/matugen.conf
echo "Colors regenerated from $WALLPAPER"
