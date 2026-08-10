#!/usr/bin/env bash
# Runs its arguments as a command, unless the bar's "Awake" toggle
# (Idle.inhibit in the quickshell shell) is currently on.
#
# The Wayland idle-inhibit protocol *should* make this unnecessary on its
# own -- Hyprland is supposed to withhold ext-idle-notify-v1 idle events
# from hypridle entirely while any inhibitor is active. In practice the
# screen still locked/slept with Awake on, so hypridle.conf routes every
# timeout action through this as an explicit, always-correct fallback
# instead of trusting that protocol-level path alone.
states_file="$HOME/.local/state/quickshell/states.json"
awake=$(jq -r '.idle.inhibit // false' "$states_file" 2>/dev/null)

if [ "$awake" = "true" ]; then
    exit 0
fi

exec "$@"
