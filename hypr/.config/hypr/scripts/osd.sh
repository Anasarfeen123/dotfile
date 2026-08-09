#!/usr/bin/env bash
set -euo pipefail

TYPE="${1:-}"

case "$TYPE" in
  capslock)
      STATE_FILE="/tmp/hypr_caps_state"

      if [ -f "$STATE_FILE" ]; then
          STATE=$(cat "$STATE_FILE")
      else
          STATE="false"
      fi

      if [ "$STATE" = "true" ]; then
          echo "false" > "$STATE_FILE"
          notify-send "Caps Lock OFF"
      else
          echo "true" > "$STATE_FILE"
          notify-send "Caps Lock ON"
      fi
      ;;

  numlock)
      STATE_FILE="/tmp/hypr_num_state"

      if [ -f "$STATE_FILE" ]; then
          STATE=$(cat "$STATE_FILE")
      else
          STATE="false"
      fi

      if [ "$STATE" = "true" ]; then
          echo "false" > "$STATE_FILE"
          notify-send "Nums Lock OFF"
      else
          echo "true" > "$STATE_FILE"
          notify-send "Nums Lock ON"
      fi
      ;;

  kbdlight)
      sleep 0.5
      LEVEL=$(brightnessctl -d '*kbd_backlight*' get)
      MAX=$(brightnessctl -d '*kbd_backlight*' max)
      PERCENT=$((LEVEL * 100 / MAX))
      echo "$PERCENT" | wob
      ;;
  *)
      notify-send "Unknown OSD action"
      exit 1
      ;;
esac
