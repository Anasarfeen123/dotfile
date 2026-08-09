#!/bin/bash
hyprctl eval 'hl.dsp.window.set_prop({ prop = "opacity", value = "1.0", window = "class:.*" })' 2>/dev/null
hyprctl eval 'hl.window_rule({match = {class = ".*"}, opacity = 1.0})' 2>/dev/null
notify-send "Glass" "Transparency disabled" -a Hyprland
