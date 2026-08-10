import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.models.hyprland
import qs.modules.settingsPro.widgets

GPage {
    forceWidth: true
    resetPaths: ["appearance.fonts", "cheatsheet", "crosshair.code", "dock", "interactions", "lock", "notifications", "osd", "osk", "overlay", "overview", "regionSelector", "search.imageSearch", "sidebar", "wallpaperSelector"]

    GSection {
        icon: "keyboard"
        title: Translation.tr("Cheat sheet")

        GSubsection {
            title: Translation.tr("Super key symbol")
            tooltip: Translation.tr("You can also manually edit cheatsheet.superKey")
            GSelectGroup {
                currentValue: Config.options.cheatsheet.superKey
                onSelected: newValue => Config.options.cheatsheet.superKey = newValue
                options: ([
                  "󰖳", "", "󰨡", "", "󰌽", "󰣇", "", "", "",
                  "", "", "󱄛", "", "", "", "⌘", "󰀲", "󰟍", ""
                ]).map(icon => ({ displayName: icon, value: icon, fontFamily: Appearance.font.family.iconNerd, pixelSize: Appearance.font.pixelSize.larger }))
            }
        }

        GSwitchRow {
            buttonIcon: "󰘵"
            buttonText: Translation.tr("Use macOS-like symbols for mods keys")
            checked: Config.options.cheatsheet.useMacSymbol
            onCheckedChanged: Config.options.cheatsheet.useMacSymbol = checked
            GTooltip { text: Translation.tr("e.g. 󰘴  for Ctrl, 󰘵  for Alt, 󰘶  for Shift, etc") }
        }
        GSwitchRow {
            buttonIcon: "󱊶"
            buttonText: Translation.tr("Use symbols for function keys")
            checked: Config.options.cheatsheet.useFnSymbol
            onCheckedChanged: Config.options.cheatsheet.useFnSymbol = checked
            GTooltip { text: Translation.tr("e.g. 󱊫 for F1, 󱊶  for F12") }
        }
        GSwitchRow {
            buttonIcon: "󰍽"
            buttonText: Translation.tr("Use symbols for mouse")
            checked: Config.options.cheatsheet.useMouseSymbol
            onCheckedChanged: Config.options.cheatsheet.useMouseSymbol = checked
            GTooltip { text: Translation.tr("Replace 󱕐   for \"Scroll ↓\", 󱕑   \"Scroll ↑\", L󰍽   \"LMB\", R󰍽   \"RMB\", 󱕒   \"Scroll ↑/↓\" and ⇞/⇟ for \"Page_↑/↓\"") }
        }
        GSwitchRow {
            buttonIcon: "highlight_keyboard_focus"
            buttonText: Translation.tr("Split buttons")
            checked: Config.options.cheatsheet.splitButtons
            onCheckedChanged: Config.options.cheatsheet.splitButtons = checked
            GTooltip { text: Translation.tr("Display modifiers and keys in multiple keycap (e.g., \"Ctrl + A\" instead of \"Ctrl A\" or \"󰘴 + A\" instead of \"󰘴 A\")") }
        }
        GSpinRow {
            text: Translation.tr("Keybind font size")
            value: Config.options.cheatsheet.fontSize.key
            from: 8; to: 30; stepSize: 1
            onValueChanged: Config.options.cheatsheet.fontSize.key = value
        }
        GSpinRow {
            text: Translation.tr("Description font size")
            value: Config.options.cheatsheet.fontSize.comment
            from: 8; to: 30; stepSize: 1
            onValueChanged: Config.options.cheatsheet.fontSize.comment = value
        }
    }

    GSection {
        icon: "call_to_action"
        title: Translation.tr("Dock")

        GSwitchRow {
            buttonIcon: "check"
            buttonText: Translation.tr("Enable")
            checked: Config.options.dock.enable
            onCheckedChanged: Config.options.dock.enable = checked
        }
        GRow {
            uniform: true
            GSwitchRow {
                buttonIcon: "highlight_mouse_cursor"
                buttonText: Translation.tr("Hover to reveal")
                checked: Config.options.dock.hoverToReveal
                onCheckedChanged: Config.options.dock.hoverToReveal = checked
            }
            GSwitchRow {
                buttonIcon: "keep"
                buttonText: Translation.tr("Pinned on startup")
                checked: Config.options.dock.pinnedOnStartup
                onCheckedChanged: Config.options.dock.pinnedOnStartup = checked
            }
        }
        GSwitchRow {
            buttonIcon: "colors"
            buttonText: Translation.tr("Tint app icons")
            checked: Config.options.dock.monochromeIcons
            onCheckedChanged: Config.options.dock.monochromeIcons = checked
        }
        GSwitchRow {
            buttonIcon: "keep"
            buttonText: Translation.tr("Show pin & \"show all apps\" buttons")
            checked: Config.options.dock.showControlButtons
            onCheckedChanged: Config.options.dock.showControlButtons = checked
        }
        GRow {
            uniform: true
            GSpinRow {
                text: Translation.tr("Dock size")
                value: Config.options.dock.height
                from: 50; to: 130; stepSize: 2
                onValueChanged: Config.options.dock.height = value
            }
            GSpinRow {
                text: Translation.tr("Icon size")
                value: Config.options.dock.iconSize
                from: 24; to: 64; stepSize: 2
                onValueChanged: Config.options.dock.iconSize = value
            }
        }
    }

    GSection {
        icon: "lock"
        title: Translation.tr("Lock screen")

        GSwitchRow {
            buttonIcon: "water_drop"
            buttonText: Translation.tr("Use Hyprlock (instead of Quickshell)")
            checked: Config.options.lock.useHyprlock
            onCheckedChanged: Config.options.lock.useHyprlock = checked
            GTooltip { text: Translation.tr("If you want to somehow use fingerprint unlock...") }
        }
        GSwitchRow {
            buttonIcon: "account_circle"
            buttonText: Translation.tr("Launch on startup")
            checked: Config.options.lock.launchOnStartup
            onCheckedChanged: Config.options.lock.launchOnStartup = checked
        }

        GSubsection {
            title: Translation.tr("Security")
            GSwitchRow {
                buttonIcon: "settings_power"
                buttonText: Translation.tr("Require password to power off/restart")
                checked: Config.options.lock.security.requirePasswordToPower
                onCheckedChanged: Config.options.lock.security.requirePasswordToPower = checked
                GTooltip { text: Translation.tr("Remember that on most devices one can always hold the power button to force shutdown\nThis only makes it a tiny bit harder for accidents to happen") }
            }
            GSwitchRow {
                buttonIcon: "key_vertical"
                buttonText: Translation.tr("Also unlock keyring")
                checked: Config.options.lock.security.unlockKeyring
                onCheckedChanged: Config.options.lock.security.unlockKeyring = checked
                GTooltip { text: Translation.tr("This is usually safe and needed for your browser and AI sidebar anyway\nMostly useful for those who use lock on startup instead of a display manager that does it (GDM, SDDM, etc.)") }
            }
        }
        GSubsection {
            title: Translation.tr("Style: general")
            GSwitchRow {
                buttonIcon: "center_focus_weak"
                buttonText: Translation.tr("Center clock")
                checked: Config.options.lock.centerClock
                onCheckedChanged: Config.options.lock.centerClock = checked
            }
            GSwitchRow {
                buttonIcon: "info"
                buttonText: Translation.tr('Show "Locked" text')
                checked: Config.options.lock.showLockedText
                onCheckedChanged: Config.options.lock.showLockedText = checked
            }
            GSwitchRow {
                buttonIcon: "shapes"
                buttonText: Translation.tr("Use varying shapes for password characters")
                checked: Config.options.lock.materialShapeChars
                onCheckedChanged: Config.options.lock.materialShapeChars = checked
            }
        }
        GSubsection {
            title: Translation.tr("Style: Blurred")
            GSwitchRow {
                buttonIcon: "blur_on"
                buttonText: Translation.tr("Enable blur")
                checked: Config.options.lock.blur.enable
                onCheckedChanged: Config.options.lock.blur.enable = checked
            }
            GSpinRow {
                icon: "loupe"
                text: Translation.tr("Extra wallpaper zoom (%)")
                value: Config.options.lock.blur.extraZoom * 100
                from: 1; to: 150; stepSize: 2
                onValueChanged: Config.options.lock.blur.extraZoom = value / 100
            }
        }
    }

    GSection {
        icon: "notifications"
        title: Translation.tr("Notifications")

        GSpinRow {
            icon: "av_timer"
            text: Translation.tr("Timeout duration (if not defined by notification) (ms)")
            value: Config.options.notifications.timeout
            from: 1000; to: 60000; stepSize: 1000
            onValueChanged: Config.options.notifications.timeout = value
        }
        GSwitchRow {
            buttonIcon: "monitor"
            buttonText: Translation.tr("Force specific monitor")
            checked: Config.options.notifications.monitor.enable
            onCheckedChanged: Config.options.notifications.monitor.enable = checked
            GTooltip { text: Translation.tr("If you have multiple monitors and want notifications to only show on one of them, enable this and enter the monitor name below (e.g., eDP-1)") }
        }
        GRow {
            enabled: Config.options.notifications.monitor.enable
            GTextArea {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Monitor name to show notifications on (e.g., eDP-1)")
                text: Config.options.notifications.monitor.name
                wrapMode: TextEdit.Wrap
                onTextChanged: Config.options.notifications.monitor.name = text
            }
        }
    }

    GSection {
        icon: "select_window"
        title: Translation.tr("Overlay: General")

        GSwitchRow {
            buttonIcon: "high_density"
            buttonText: Translation.tr("Enable opening zoom animation")
            checked: Config.options.overlay.openingZoomAnimation
            onCheckedChanged: Config.options.overlay.openingZoomAnimation = checked
        }
        GSwitchRow {
            buttonIcon: "texture"
            buttonText: Translation.tr("Darken screen")
            checked: Config.options.overlay.darkenScreen
            onCheckedChanged: Config.options.overlay.darkenScreen = checked
        }
    }

    GSection {
        icon: "point_scan"
        title: Translation.tr("Overlay: Crosshair")

        GTextArea {
            Layout.fillWidth: true
            placeholderText: Translation.tr("Crosshair code (in Valorant's format)")
            text: Config.options.crosshair.code
            wrapMode: TextEdit.Wrap
            onTextChanged: Config.options.crosshair.code = text
        }

        RowLayout {
            GText {
                Layout.leftMargin: 10
                color: Appearance.colors.colOnLayer2
                font.pixelSize: Appearance.font.pixelSize.smallie
                text: Translation.tr("Press Super+G to open the overlay and pin the crosshair")
            }
            Item { Layout.fillWidth: true }
            GButton {
                buttonRadius: Appearance.rounding.full
                buttonIcon: "open_in_new"
                buttonText: Translation.tr("Open editor")
                onClicked: Qt.openUrlExternally(`https://www.vcrdb.net/builder?c=${Config.options.crosshair.code}`)
                GTooltip { text: "www.vcrdb.net" }
            }
        }
    }

    GSection {
        icon: "point_scan"
        title: Translation.tr("Overlay: Floating Image")

        GTextArea {
            Layout.fillWidth: true
            placeholderText: Translation.tr("Image source")
            text: Config.options.overlay.floatingImage.imageSource
            wrapMode: TextEdit.Wrap
            onTextChanged: Config.options.overlay.floatingImage.imageSource = text
        }
    }

    GSection {
        icon: "screenshot_frame_2"
        title: Translation.tr("Region selector (screen snipping/Google Lens)")

        GSubsection {
            title: Translation.tr("Hint target regions")
            GRow {
                GSwitchRow {
                    buttonIcon: "select_window"
                    buttonText: Translation.tr("Windows")
                    checked: Config.options.regionSelector.targetRegions.windows
                    onCheckedChanged: Config.options.regionSelector.targetRegions.windows = checked
                }
                GSwitchRow {
                    buttonIcon: "right_panel_open"
                    buttonText: Translation.tr("Layers")
                    checked: Config.options.regionSelector.targetRegions.layers
                    onCheckedChanged: Config.options.regionSelector.targetRegions.layers = checked
                }
                GSwitchRow {
                    buttonIcon: "nearby"
                    buttonText: Translation.tr("Content")
                    checked: Config.options.regionSelector.targetRegions.content
                    onCheckedChanged: Config.options.regionSelector.targetRegions.content = checked
                    GTooltip { text: Translation.tr("Could be images or parts of the screen that have some containment.\nMight not always be accurate.\nThis is done with an image processing algorithm run locally and no AI is used.") }
                }
            }
        }

        GSubsection {
            title: Translation.tr("Google Lens")
            GSelectGroup {
                currentValue: Config.options.search.imageSearch.useCircleSelection ? "circle" : "rectangles"
                onSelected: newValue => Config.options.search.imageSearch.useCircleSelection = (newValue === "circle")
                options: [
                    { icon: "activity_zone", value: "rectangles", displayName: Translation.tr("Rectangular selection") },
                    { icon: "gesture", value: "circle", displayName: Translation.tr("Circle to Search") }
                ]
            }
        }

        GSubsection {
            title: Translation.tr("Rectangular selection")
            GSwitchRow {
                buttonIcon: "point_scan"
                buttonText: Translation.tr("Show aim lines")
                checked: Config.options.regionSelector.rect.showAimLines
                onCheckedChanged: Config.options.regionSelector.rect.showAimLines = checked
            }
        }

        GSubsection {
            title: Translation.tr("Circle selection")
            GSpinRow {
                icon: "eraser_size_3"
                text: Translation.tr("Stroke width")
                value: Config.options.regionSelector.circle.strokeWidth
                from: 1; to: 20; stepSize: 1
                onValueChanged: Config.options.regionSelector.circle.strokeWidth = value
            }
            GSpinRow {
                icon: "screenshot_frame_2"
                text: Translation.tr("Padding")
                value: Config.options.regionSelector.circle.padding
                from: 0; to: 100; stepSize: 5
                onValueChanged: Config.options.regionSelector.circle.padding = value
            }
        }
    }

    GSection {
        icon: "side_navigation"
        title: Translation.tr("Sidebars")

        GSwitchRow {
            buttonIcon: "memory"
            buttonText: Translation.tr("Keep right sidebar loaded")
            checked: Config.options.sidebar.keepRightSidebarLoaded
            onCheckedChanged: Config.options.sidebar.keepRightSidebarLoaded = checked
            GTooltip { text: Translation.tr("When enabled keeps the content of the right sidebar loaded to reduce the delay when opening,\nat the cost of around 15MB of consistent RAM usage. Delay significance depends on your system's performance.\nUsing a custom kernel like linux-cachyos might help") }
        }
        GSwitchRow {
            buttonIcon: "translate"
            buttonText: Translation.tr("Enable translator")
            checked: Config.options.sidebar.translator.enable
            onCheckedChanged: Config.options.sidebar.translator.enable = checked
        }

        GSubsection {
            title: Translation.tr("Quick toggles")
            GSelectGroup {
                Layout.fillWidth: false
                currentValue: Config.options.sidebar.quickToggles.style
                onSelected: newValue => Config.options.sidebar.quickToggles.style = newValue
                options: [
                    { displayName: Translation.tr("Classic"), icon: "password_2", value: "classic" },
                    { displayName: Translation.tr("Android"), icon: "action_key", value: "android" }
                ]
            }
            GSpinRow {
                enabled: Config.options.sidebar.quickToggles.style === "android"
                icon: "splitscreen_left"
                text: Translation.tr("Columns")
                value: Config.options.sidebar.quickToggles.android.columns
                from: 1; to: 8; stepSize: 1
                onValueChanged: Config.options.sidebar.quickToggles.android.columns = value
            }
        }

        GSubsection {
            title: Translation.tr("Sliders")
            GSwitchRow {
                buttonIcon: "check"
                buttonText: Translation.tr("Enable")
                checked: Config.options.sidebar.quickSliders.enable
                onCheckedChanged: Config.options.sidebar.quickSliders.enable = checked
            }
            GSwitchRow {
                buttonIcon: "brightness_6"
                buttonText: Translation.tr("Brightness")
                enabled: Config.options.sidebar.quickSliders.enable
                checked: Config.options.sidebar.quickSliders.showBrightness
                onCheckedChanged: Config.options.sidebar.quickSliders.showBrightness = checked
            }
            GSwitchRow {
                buttonIcon: "volume_up"
                buttonText: Translation.tr("Volume")
                enabled: Config.options.sidebar.quickSliders.enable
                checked: Config.options.sidebar.quickSliders.showVolume
                onCheckedChanged: Config.options.sidebar.quickSliders.showVolume = checked
            }
            GSwitchRow {
                buttonIcon: "mic"
                buttonText: Translation.tr("Microphone")
                enabled: Config.options.sidebar.quickSliders.enable
                checked: Config.options.sidebar.quickSliders.showMic
                onCheckedChanged: Config.options.sidebar.quickSliders.showMic = checked
            }
        }

        GSubsection {
            title: Translation.tr("Corner open")
            tooltip: Translation.tr("Allows you to open sidebars by clicking or hovering screen corners regardless of bar position")
            GRow {
                uniform: true
                GSwitchRow {
                    buttonIcon: "check"
                    buttonText: Translation.tr("Enable")
                    checked: Config.options.sidebar.cornerOpen.enable
                    onCheckedChanged: Config.options.sidebar.cornerOpen.enable = checked
                }
            }
            GSwitchRow {
                buttonIcon: "highlight_mouse_cursor"
                buttonText: Translation.tr("Hover to trigger")
                checked: Config.options.sidebar.cornerOpen.clickless
                onCheckedChanged: Config.options.sidebar.cornerOpen.clickless = checked
                GTooltip { text: Translation.tr("When this is off you'll have to click") }
            }
            GRow {
                GSwitchRow {
                    enabled: !Config.options.sidebar.cornerOpen.clickless
                    buttonText: Translation.tr("Force hover open at absolute corner")
                    checked: Config.options.sidebar.cornerOpen.clicklessCornerEnd
                    onCheckedChanged: Config.options.sidebar.cornerOpen.clicklessCornerEnd = checked
                    GTooltip { text: Translation.tr("When the previous option is off and this is on,\nyou can still hover the corner's end to open sidebar,\nand the remaining area can be used for volume/brightness scroll") }
                }
                GSpinRow {
                    icon: "arrow_cool_down"
                    text: Translation.tr("with vertical offset")
                    value: Config.options.sidebar.cornerOpen.clicklessCornerVerticalOffset
                    from: 0; to: 20; stepSize: 1
                    onValueChanged: Config.options.sidebar.cornerOpen.clicklessCornerVerticalOffset = value
                    GTooltip {
                        alternativeVisibleCondition: false
                        text: Translation.tr("Why this is cool:\nFor non-0 values, it won't trigger when you reach the\nscreen corner along the horizontal edge, but it will when\nyou do along the vertical edge")
                    }
                }
            }
            GRow {
                uniform: true
                GSwitchRow {
                    buttonIcon: "vertical_align_bottom"
                    buttonText: Translation.tr("Place at bottom")
                    checked: Config.options.sidebar.cornerOpen.bottom
                    onCheckedChanged: Config.options.sidebar.cornerOpen.bottom = checked
                    GTooltip { text: Translation.tr("Place the corners to trigger at the bottom") }
                }
                GSwitchRow {
                    buttonIcon: "unfold_more_double"
                    buttonText: Translation.tr("Value scroll")
                    checked: Config.options.sidebar.cornerOpen.valueScroll
                    onCheckedChanged: Config.options.sidebar.cornerOpen.valueScroll = checked
                    GTooltip { text: Translation.tr("Brightness and volume") }
                }
            }
            GSwitchRow {
                buttonIcon: "visibility"
                buttonText: Translation.tr("Visualize region")
                checked: Config.options.sidebar.cornerOpen.visualize
                onCheckedChanged: Config.options.sidebar.cornerOpen.visualize = checked
            }
            GRow {
                GSpinRow {
                    icon: "arrow_range"
                    text: Translation.tr("Region width")
                    value: Config.options.sidebar.cornerOpen.cornerRegionWidth
                    from: 1; to: 300; stepSize: 1
                    onValueChanged: Config.options.sidebar.cornerOpen.cornerRegionWidth = value
                }
                GSpinRow {
                    icon: "height"
                    text: Translation.tr("Region height")
                    value: Config.options.sidebar.cornerOpen.cornerRegionHeight
                    from: 1; to: 300; stepSize: 1
                    onValueChanged: Config.options.sidebar.cornerOpen.cornerRegionHeight = value
                }
            }
        }
    }

    GSection {
        // Was "scroll" — a real Material Symbols name, but apparently not
        // present in whatever version of the font is actually installed,
        // so it fell back to rendering as literal text instead of a
        // glyph. "mouse" is a long-established icon, safe everywhere.
        icon: "mouse"
        title: Translation.tr("Scrolling")

        GSwitchRow {
            buttonIcon: "swap_vert"
            buttonText: Translation.tr("Reverse SUPER + scroll workspace switching")
            checked: Config.options.interactions.scrolling.reverseSuperScroll
            onCheckedChanged: {
                Config.options.interactions.scrolling.reverseSuperScroll = checked
                Quickshell.execDetached(["hyprctl", "reload"])
            }
            GTooltip { text: Translation.tr("When off, scrolling up goes to the next workspace and down to the previous.\nWhen on, this direction is reversed.") }
        }
        GSwitchRow {
            // "touchpad" isn't in the installed font; "trackpad_input" is.
            buttonIcon: "trackpad_input"
            buttonText: Translation.tr("Faster touchpad scroll")
            checked: Config.options.interactions.scrolling.fasterTouchpadScroll
            onCheckedChanged: Config.options.interactions.scrolling.fasterTouchpadScroll = checked
            GTooltip { text: Translation.tr("Multiplies the scroll amount for touchpads so they feel faster") }
        }
        GRow {
            uniform: true
            GSpinRow {
                icon: "mouse"
                text: Translation.tr("Mouse")
                value: Config.options.interactions.scrolling.mouseScrollFactor
                from: 1; to: 1000; stepSize: 10
                onValueChanged: Config.options.interactions.scrolling.mouseScrollFactor = value
                GTooltip { text: Translation.tr("Mouse scroll factor\nHigher = faster, 120 is the default.") }
            }
            GSpinRow {
                icon: "trackpad_input"
                text: Translation.tr("Touchpad")
                value: Config.options.interactions.scrolling.touchpadScrollFactor
                from: 1; to: 1000; stepSize: 10
                onValueChanged: Config.options.interactions.scrolling.touchpadScrollFactor = value
                GTooltip { text: Translation.tr("Touchpad scroll factor\nHigher = faster, 450 is the default.") }
            }
            GSpinRow {
                icon: "straighten"
                text: Translation.tr("Threshold")
                value: Config.options.interactions.scrolling.mouseScrollDeltaThreshold
                from: 1; to: 1000; stepSize: 5
                onValueChanged: Config.options.interactions.scrolling.mouseScrollDeltaThreshold = value
                GTooltip { text: Translation.tr("Scroll delta threshold\nScrolls below this count as touchpad input, 120 is the default.") }
            }
        }
        GSwitchRow {
            buttonIcon: "splitscreen_right"
            buttonText: Translation.tr("Dead pixel workaround")
            checked: Config.options.interactions.deadPixelWorkaround.enable
            onCheckedChanged: Config.options.interactions.deadPixelWorkaround.enable = checked
            GTooltip { text: Translation.tr("Hyprland leaves a 1px column on the right for interactions; this compensates for it") }
        }
    }

    GSection {
        icon: "blur_on"
        title: Translation.tr("Blur")

        GSwitchRow {
            buttonIcon: "blur_on"
            buttonText: Translation.tr("Enable blur")
            checked: blurEnabledOption.value ?? true
            onCheckedChanged: {
                if (checked !== blurEnabledOption.value) {
                    blurEnabledOption.setValue(checked)
                    Quickshell.execDetached(["hyprctl", "reload"])
                }
            }
        }
        GSliderRow {
            text: Translation.tr("Blur size")
            buttonIcon: "blur_medium"
            usePercentTooltip: false
            value: Math.round(blurSizeOption.value ?? 10)
            from: 1; to: 20; stepSize: 1
            stopIndicatorValues: [10]
            onValueChanged: {
                let v = Math.round(value)
                if (v !== (blurSizeOption.value ?? 10)) {
                    blurSizeOption.setValue(v)
                    Quickshell.execDetached(["hyprctl", "reload"])
                }
            }
        }
        GSliderRow {
            text: Translation.tr("Blur passes")
            buttonIcon: "layers"
            usePercentTooltip: false
            value: Math.round(blurPassesOption.value ?? 3)
            from: 1; to: 5; stepSize: 1
            stopIndicatorValues: [3]
            onValueChanged: {
                let v = Math.round(value)
                if (v !== (blurPassesOption.value ?? 3)) {
                    blurPassesOption.setValue(v)
                    Quickshell.execDetached(["hyprctl", "reload"])
                }
            }
        }
        GSliderRow {
            text: Translation.tr("Blur brightness (%)")
            buttonIcon: "brightness_6"
            value: blurBrightnessOption.value ?? 0.85
            from: 0; to: 1
            stopIndicatorValues: [0.85]
            onValueChanged: {
                if (value !== (blurBrightnessOption.value ?? 0.85)) {
                    blurBrightnessOption.setValue(value)
                    Quickshell.execDetached(["hyprctl", "reload"])
                }
            }
        }

        HyprlandConfigOption { id: blurEnabledOption; key: "decoration:blur:enabled" }
        HyprlandConfigOption { id: blurSizeOption; key: "decoration:blur:size" }
        HyprlandConfigOption { id: blurPassesOption; key: "decoration:blur:passes" }
        HyprlandConfigOption { id: blurBrightnessOption; key: "decoration:blur:brightness" }
    }

    GSection {
        icon: "voting_chip"
        title: Translation.tr("On-screen display")
        GSpinRow {
            icon: "av_timer"
            text: Translation.tr("Timeout (ms)")
            value: Config.options.osd.timeout
            from: 100; to: 3000; stepSize: 100
            onValueChanged: Config.options.osd.timeout = value
        }
    }

    GSection {
        icon: "keyboard"
        title: Translation.tr("On-screen keyboard")

        GSubsection {
            title: Translation.tr("Layout")
            tooltip: Translation.tr("Which virtual keyboard layout to use")
            GDropdown {
                buttonIcon: "keyboard"
                textRole: "displayName"
                model: [
                    { displayName: "qwerty_full", value: "qwerty_full" },
                    { displayName: "azerty_full", value: "azerty_full" },
                    { displayName: "qwerty_small", value: "qwerty_small" },
                    { displayName: "security", value: "security" },
                    { displayName: Translation.tr("Mixed"), value: "default" }
                ]
                currentIndex: {
                    const index = model.findIndex(item => item.value === Config.options.osk.layout)
                    return index !== -1 ? index : 0
                }
                onActivated: index => Config.options.osk.layout = model[index].value
            }
        }
        GSwitchRow {
            buttonIcon: "push_pin"
            buttonText: Translation.tr("Pinned on startup")
            checked: Config.options.osk.pinnedOnStartup
            onCheckedChanged: Config.options.osk.pinnedOnStartup = checked
        }
    }

    GSection {
        icon: "overview_key"
        title: Translation.tr("Overview")

        GSwitchRow {
            buttonIcon: "check"
            buttonText: Translation.tr("Enable")
            checked: Config.options.overview.enable
            onCheckedChanged: Config.options.overview.enable = checked
        }
        GSwitchRow {
            buttonIcon: "center_focus_strong"
            buttonText: Translation.tr("Center icons")
            checked: Config.options.overview.centerIcons
            onCheckedChanged: Config.options.overview.centerIcons = checked
        }
        GSpinRow {
            icon: "loupe"
            text: Translation.tr("Scale (%)")
            value: Config.options.overview.scale * 100
            from: 1; to: 100; stepSize: 1
            onValueChanged: Config.options.overview.scale = value / 100
        }
        GRow {
            uniform: true
            GSpinRow {
                icon: "splitscreen_bottom"
                text: Translation.tr("Rows")
                value: Config.options.overview.rows
                from: 1; to: 20; stepSize: 1
                onValueChanged: Config.options.overview.rows = value
            }
            GSpinRow {
                icon: "splitscreen_right"
                text: Translation.tr("Columns")
                value: Config.options.overview.columns
                from: 1; to: 20; stepSize: 1
                onValueChanged: Config.options.overview.columns = value
            }
        }
        GRow {
            uniform: true
            GSelectGroup {
                currentValue: Config.options.overview.orderRightLeft
                onSelected: newValue => Config.options.overview.orderRightLeft = newValue
                options: [
                    { displayName: Translation.tr("Left to right"), icon: "arrow_forward", value: 0 },
                    { displayName: Translation.tr("Right to left"), icon: "arrow_back", value: 1 }
                ]
            }
            GSelectGroup {
                currentValue: Config.options.overview.orderBottomUp
                onSelected: newValue => Config.options.overview.orderBottomUp = newValue
                options: [
                    { displayName: Translation.tr("Top-down"), icon: "arrow_downward", value: 0 },
                    { displayName: Translation.tr("Bottom-up"), icon: "arrow_upward", value: 1 }
                ]
            }
        }
    }

    GSection {
        icon: "wallpaper_slideshow"
        title: Translation.tr("Wallpaper selector")
        GSwitchRow {
            buttonIcon: "ad"
            buttonText: Translation.tr("Use system file picker")
            checked: Config.options.wallpaperSelector.useSystemFileDialog
            onCheckedChanged: Config.options.wallpaperSelector.useSystemFileDialog = checked
        }
    }

    GSection {
        icon: "text_format"
        title: Translation.tr("Fonts")
        key: "fonts"

        GFontRoleRow {
            roleName: Translation.tr("Main")
            roleIcon: "text_fields"
            roleValue: Config.options.appearance.fonts.main
            rolePreview: Translation.tr("General UI text — Aa 123")
            onEdited: v => Config.options.appearance.fonts.main = v
        }
        GFontRoleRow {
            roleName: Translation.tr("Numbers")
            roleIcon: "pin"
            roleValue: Config.options.appearance.fonts.numbers
            rolePreview: Translation.tr("Numbers — 123 456")
            onEdited: v => Config.options.appearance.fonts.numbers = v
        }
        GFontRoleRow {
            roleName: Translation.tr("Title")
            roleIcon: "title"
            roleValue: Config.options.appearance.fonts.title
            rolePreview: Translation.tr("Headings — Aa 123")
            onEdited: v => Config.options.appearance.fonts.title = v
        }
        GFontRoleRow {
            roleName: Translation.tr("Monospace")
            roleIcon: "terminal"
            roleValue: Config.options.appearance.fonts.monospace
            rolePreview: Translation.tr("Code — 0O1l aA 123")
            onEdited: v => Config.options.appearance.fonts.monospace = v
        }
        GFontRoleRow {
            roleName: Translation.tr("Nerd icons")
            roleIcon: "memory"
            roleValue: Config.options.appearance.fonts.iconNerd
            rolePreview: Translation.tr("Icons — ")
            onEdited: v => Config.options.appearance.fonts.iconNerd = v
        }
        GFontRoleRow {
            roleName: Translation.tr("Reading")
            roleIcon: "menu_book"
            roleValue: Config.options.appearance.fonts.reading
            rolePreview: Translation.tr("Long text — Aa 123")
            onEdited: v => Config.options.appearance.fonts.reading = v
        }
        GFontRoleRow {
            roleName: Translation.tr("Expressive")
            roleIcon: "format_quote"
            roleValue: Config.options.appearance.fonts.expressive
            rolePreview: Translation.tr("Decorative — Aa 123")
            onEdited: v => Config.options.appearance.fonts.expressive = v
        }
    }
}
