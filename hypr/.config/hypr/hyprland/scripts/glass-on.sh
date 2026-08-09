#!/bin/bash
hyprctl eval 'hl.dsp.window.set_prop({ prop = "opacity", value = "0.85", window = "class:.*" })' 2>/dev/null
hyprctl eval 'hl.window_rule({match = {class = ".*"}, opacity = 0.85})' 2>/dev/null
notify-send "Glass" "Transparency restored" -a Hyprland
