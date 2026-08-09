#!/usr/bin/env python3
"""
When appearance.amoled is enabled in illogical-impulse/config.json, forces
true-black (#000000) on the base background/surface tokens across the
already-generated theme files (colors.json, hyprlock colors.conf, the
matugen-rendered SDDM theme). Container/elevated surface tiers are left as
generated so Material You's elevation hierarchy still reads on a black canvas.
Run after matugen but before the SDDM theme file is synced to the system dir.
No-op if the flag is off or the config file is missing.
"""
import json
import re
from pathlib import Path

CONFIG_FILE = Path.home() / ".config/illogical-impulse/config.json"
STATE = Path.home() / ".local/state/quickshell/user/generated"
HYPRLOCK_COLORS = Path.home() / ".config/hypr/hyprlock/colors.conf"
SDDM_TMP = Path("/tmp/sddm-matugen.conf")

BLACK = "#000000"
JSON_KEYS = ("background", "surface", "surface_dim")
SDDM_SECTIONS = ("LockScreen", "LoginScreen")


def amoled_enabled() -> bool:
    try:
        data = json.loads(CONFIG_FILE.read_text())
        return bool(data.get("appearance", {}).get("amoled", False))
    except (OSError, json.JSONDecodeError):
        return False


def patch_colors_json():
    path = STATE / "colors.json"
    if not path.exists():
        return
    data = json.loads(path.read_text())
    for key in JSON_KEYS:
        if key in data:
            data[key] = BLACK
    path.write_text(json.dumps(data, indent=2) + "\n")


def patch_hyprlock_colors():
    if not HYPRLOCK_COLORS.exists():
        return
    text = HYPRLOCK_COLORS.read_text()
    text = re.sub(
        r"^\$surface_color = rgba\([0-9a-fA-F]{6}([0-9a-fA-F]{2})\)",
        r"$surface_color = rgba(000000\1)",
        text,
        flags=re.MULTILINE,
    )
    HYPRLOCK_COLORS.write_text(text)


def patch_sddm(path: Path):
    if not path.exists():
        return
    lines = path.read_text().splitlines(keepends=True)
    section = None
    for i, line in enumerate(lines):
        m = re.match(r"^\[([\w.]+)\]", line.strip())
        if m:
            section = m.group(1)
            continue
        if section in SDDM_SECTIONS and line.strip().startswith("background-color"):
            lines[i] = 'background-color = "%s"\n' % BLACK
    path.write_text("".join(lines))


def main():
    if not amoled_enabled():
        return
    patch_colors_json()
    patch_hyprlock_colors()
    patch_sddm(SDDM_TMP)


if __name__ == "__main__":
    main()
