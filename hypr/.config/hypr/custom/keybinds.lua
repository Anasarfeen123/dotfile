-- This file will not be overwritten across dots-hyprland updates.
-- The file name is for the sake of organization and does not matter
-- See the corresponding files in ~/.config/hypr/hyprland for examples

-- Toggle notifications (swaync DND mode)
hl.bind("SUPER + ALT + N", hl.dsp.global("quickshell:toggleDnd"),
    { description = "Notifications: Toggle DND" })
hl.bind("SUPER + ALT + SHIFT + N", hl.dsp.global("quickshell:clearAllNotifications"),
    { description = "Notifications: Clear all" })
