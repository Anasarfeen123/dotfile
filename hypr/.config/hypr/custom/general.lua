-- This file will not be overwritten across dots-hyprland updates.
-- The file name is for the sake of organization and does not matter
-- See the corresponding files in ~/.config/hypr/hyprland for examples

-- Nudge compositor glass blur closer to the tuned hyprlock background{} block
-- (blur_size 14, vibrancy 0.35) for a consistent frosted-glass look across
-- bar/dock/sidebars and the lock screen.
hl.config({
    decoration = {
        blur = {
            size = 14,
            vibrancy = 0.44,
        },
    },
    render = {
        direct_scanout = 0,
    },
})
