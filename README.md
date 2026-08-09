# dotfiles

My personal Hyprland desktop, built on top of [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) ("illogical impulse") with my own tweaks layered on top.

Window manager: **Hyprland**. Shell/bar/widgets: **Quickshell** (the `ii` shell from illogical impulse). Terminal: **kitty** / **foot**. Shell: **fish**. Launcher: **fuzzel**. Lockscreen: **hyprlock** (with a custom analog clock renderer). Theming: **matugen** + **Kvantum**.

## What's here

Each top-level directory is a self-contained package — the path inside it mirrors where it belongs relative to `$HOME`.

| Package | Installs to | Notes |
|---|---|---|
| `hypr/` | `~/.config/hypr` | Hyprland config (Lua-based, from dots-hyprland). My overrides live in `hypr/.config/hypr/custom/` — everything else there is regenerated/updated by the upstream installer. |
| `quickshell/` | `~/.config/quickshell/ii` | The illogical-impulse Quickshell shell (bar, sidebars, launcher, notifications, AI sidebar, etc). |
| `illogical-impulse/` | `~/.config/illogical-impulse`, `~/.local/share/icons/illogical-impulse.svg` | ii's own settings (`config.json`) and translation strings. |
| `wlogout/` | `~/.config/wlogout` | Power menu. |
| `fish/` | `~/.config/fish` | Shell config + functions. |
| `foot/`, `fuzzel/`, `kitty/` | `~/.config/...` | Terminal(s) and app launcher. |
| `matugen/`, `kde-material-you-colors/` | `~/.config/...` | Material-You color generation from wallpaper. |
| `Kvantum/` | `~/.config/Kvantum` | Qt theming (Colloid / MaterialAdw). |
| `mpv/` | `~/.config/mpv` | Video player config. |
| `xdg-desktop-portal/` | `~/.config/xdg-desktop-portal` | Hyprland portal config for screen share/file pickers. |

## My customizations (on top of stock illogical impulse)

- Extra keybinds in `hypr/custom/keybinds.lua` (notification DND toggle/clear, etc.) and tweaks in `custom/env.lua` / `custom/general.lua`.
- Custom analog clock renderer for the lockscreen (`hypr/hyprlock/render_analog_clock.py`), driven by `hyprlock/colors.conf`.
- Video wallpaper support via `mpvpaper` with generated thumbnails (`hypr/custom/scripts/`).
- AI sidebar wired to OpenRouter with a custom system prompt (see `illogical-impulse/config.json`) — you provide your own API key, nothing is checked in.
- Kvantum + matugen theming for consistent Material-You colors across Qt/GTK apps.

## Requirements

This assumes a base illogical-impulse / dots-hyprland install (Hyprland, Quickshell, hyprlock, hypridle, matugen, kitty, foot, fuzzel, wlogout, fish, and the fonts/icons it pulls in). If you're starting fresh, install the upstream dots-hyprland first following [their instructions](https://end-4.github.io/dots-hyprland-wiki/en/), then use this repo to apply my overrides on top — or use it standalone and fill in gaps as things come up.

Not included here (pulled in by the upstream installer instead):
- `illogical-impulse-google-sans-flex` font (`~/.local/share/fonts/`)
- system-wide packages (Hyprland, Quickshell, hyprlock, hypridle, matugen, etc.)

## Install

```bash
git clone https://github.com/<you>/dotfiles.git ~/Projects/dotfiles-local
cd ~/Projects/dotfiles-local
./install.sh              # symlinks everything into place
./install.sh hypr fish    # or just specific packages
```

Anything already at the destination is moved to `~/.dotfiles-backup/<timestamp>/` before the symlink is created, so it's safe to run on a machine that already has files there.

## A few things to adjust after cloning

These are machine-specific and hardcoded as absolute paths — update them for your own setup:

- `hypr/.config/hypr/hyprpaper.conf` and `hypr/.config/hypr/hyprlock/colors.conf` — wallpaper path.
- `hypr/.config/hypr/hyprlock.conf` — `path = ~/.face` avatar.
- `illogical-impulse/.config/illogical-impulse/config.json` — `wallpaperPath`, `savePath`.
- `illogical-impulse/.config/illogical-impulse/config.json` — AI sidebar needs an OpenRouter API key (`key_id: "openrouter"`), entered through the ii settings UI and stored in your system keyring — never in this file.
- `hypr/.config/hypr/monitors.conf` — per-machine monitor layout (regenerate with `nwg-displays`).

## Credits

Built on [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) (GPL-3.0) and the illogical-impulse Quickshell shell, plus the Colloid/MaterialAdw Kvantum themes. This repo just tracks my personal config on top — go star the upstream project.
