import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.settingsPro.widgets

GPage {
    forceWidth: true
    resetPaths: ["background"]

    GSection {
        icon: "sync_alt"
        title: Translation.tr("Parallax")

        GSwitchRow {
            buttonIcon: "unfold_more_double"
            buttonText: Translation.tr("Vertical")
            checked: Config.options.background.parallax.vertical
            onCheckedChanged: Config.options.background.parallax.vertical = checked
        }
        GRow {
            uniform: true
            GSwitchRow {
                buttonIcon: "counter_1"
                buttonText: Translation.tr("Depends on workspace")
                checked: Config.options.background.parallax.enableWorkspace
                onCheckedChanged: Config.options.background.parallax.enableWorkspace = checked
            }
            GSwitchRow {
                buttonIcon: "side_navigation"
                buttonText: Translation.tr("Depends on sidebars")
                checked: Config.options.background.parallax.enableSidebar
                onCheckedChanged: Config.options.background.parallax.enableSidebar = checked
            }
        }
        GSpinRow {
            icon: "loupe"
            text: Translation.tr("Preferred wallpaper zoom (%)")
            value: Config.options.background.parallax.workspaceZoom * 100
            from: 10; to: 200; stepSize: 1
            onValueChanged: Config.options.background.parallax.workspaceZoom = value / 100
        }
    }

    GSection {
        id: settingsClock
        icon: "clock_loader_40"
        title: Translation.tr("Widget: Clock")

        function stylePresent(styleName) {
            if (!Config.options.background.widgets.clock.showOnlyWhenLocked && Config.options.background.widgets.clock.style === styleName) return true
            if (Config.options.background.widgets.clock.styleLocked === styleName) return true
            return false
        }

        readonly property bool digitalPresent: stylePresent("digital")
        readonly property bool cookiePresent: stylePresent("cookie")

        GRow {
            Layout.fillWidth: true
            GSwitchRow {
                Layout.fillWidth: false
                buttonIcon: "check"
                buttonText: Translation.tr("Enable")
                checked: Config.options.background.widgets.clock.enable
                onCheckedChanged: Config.options.background.widgets.clock.enable = checked
            }
            Item { Layout.fillWidth: true }
            GSelectGroup {
                Layout.fillWidth: false
                currentValue: Config.options.background.widgets.clock.placementStrategy
                onSelected: newValue => Config.options.background.widgets.clock.placementStrategy = newValue
                options: [
                    { displayName: Translation.tr("Draggable"), icon: "drag_pan", value: "free" },
                    { displayName: Translation.tr("Least busy"), icon: "category", value: "leastBusy" },
                    { displayName: Translation.tr("Most busy"), icon: "shapes", value: "mostBusy" }
                ]
            }
        }

        GSwitchRow {
            buttonIcon: "lock_clock"
            buttonText: Translation.tr("Show only when locked")
            checked: Config.options.background.widgets.clock.showOnlyWhenLocked
            onCheckedChanged: Config.options.background.widgets.clock.showOnlyWhenLocked = checked
        }

        GRow {
            ColumnLayout {
                visible: !Config.options.background.widgets.clock.showOnlyWhenLocked
                Layout.fillWidth: true
                GText { text: Translation.tr("Clock style"); font.pixelSize: Appearance.font.pixelSize.small; font.weight: Font.Medium; color: Appearance.colors.colOnLayer2 }
                GSelectGroup {
                    currentValue: Config.options.background.widgets.clock.style
                    onSelected: newValue => Config.options.background.widgets.clock.style = newValue
                    options: [
                        { displayName: Translation.tr("Digital"), icon: "timer_10", value: "digital" },
                        { displayName: Translation.tr("Cookie"), icon: "cookie", value: "cookie" }
                    ]
                }
            }
            ColumnLayout {
                Layout.fillWidth: false
                GText { text: Translation.tr("Clock style (locked)"); font.pixelSize: Appearance.font.pixelSize.small; font.weight: Font.Medium; color: Appearance.colors.colOnLayer2 }
                GSelectGroup {
                    currentValue: Config.options.background.widgets.clock.styleLocked
                    onSelected: newValue => Config.options.background.widgets.clock.styleLocked = newValue
                    options: [
                        { displayName: Translation.tr("Digital"), icon: "timer_10", value: "digital" },
                        { displayName: Translation.tr("Cookie"), icon: "cookie", value: "cookie" }
                    ]
                }
            }
        }

        GSubsection {
            visible: settingsClock.digitalPresent
            title: Translation.tr("Digital clock settings")
            tooltip: Translation.tr("Font width and roundness settings are only available for some fonts like Google Sans Flex")

            GRow {
                uniform: true
                GSwitchRow {
                    buttonIcon: "vertical_distribute"
                    buttonText: Translation.tr("Vertical")
                    checked: Config.options.background.widgets.clock.digital.vertical
                    onCheckedChanged: Config.options.background.widgets.clock.digital.vertical = checked
                }
                GSwitchRow {
                    buttonIcon: "animation"
                    buttonText: Translation.tr("Animate time change")
                    checked: Config.options.background.widgets.clock.digital.animateChange
                    onCheckedChanged: Config.options.background.widgets.clock.digital.animateChange = checked
                }
            }
            GRow {
                uniform: true
                GSwitchRow {
                    buttonIcon: "date_range"
                    buttonText: Translation.tr("Show date")
                    checked: Config.options.background.widgets.clock.digital.showDate
                    onCheckedChanged: Config.options.background.widgets.clock.digital.showDate = checked
                }
                GSwitchRow {
                    buttonIcon: "activity_zone"
                    buttonText: Translation.tr("Use adaptive alignment")
                    checked: Config.options.background.widgets.clock.digital.adaptiveAlignment
                    onCheckedChanged: Config.options.background.widgets.clock.digital.adaptiveAlignment = checked
                    GTooltip { text: Translation.tr("Aligns the date and quote to left, center or right depending on its position on the screen.") }
                }
            }

            GTextArea {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Font family")
                text: Config.options.background.widgets.clock.digital.font.family
                wrapMode: TextEdit.Wrap
                onTextChanged: Config.options.background.widgets.clock.digital.font.family = text
            }

            GSliderRow {
                text: Translation.tr("Font weight")
                value: Config.options.background.widgets.clock.digital.font.weight
                usePercentTooltip: false
                buttonIcon: "format_bold"
                from: 1; to: 1000
                stopIndicatorValues: [350]
                onValueChanged: Config.options.background.widgets.clock.digital.font.weight = value
            }
            GSliderRow {
                text: Translation.tr("Font size")
                value: Config.options.background.widgets.clock.digital.font.size
                usePercentTooltip: false
                buttonIcon: "format_size"
                from: 50; to: 700
                stopIndicatorValues: [90]
                onValueChanged: Config.options.background.widgets.clock.digital.font.size = value
            }
            GSliderRow {
                text: Translation.tr("Font width")
                value: Config.options.background.widgets.clock.digital.font.width
                usePercentTooltip: false
                buttonIcon: "fit_width"
                from: 25; to: 125
                stopIndicatorValues: [100]
                onValueChanged: Config.options.background.widgets.clock.digital.font.width = value
            }
            GSliderRow {
                text: Translation.tr("Font roundness")
                value: Config.options.background.widgets.clock.digital.font.roundness
                usePercentTooltip: false
                buttonIcon: "line_curve"
                from: 0; to: 100
                onValueChanged: Config.options.background.widgets.clock.digital.font.roundness = value
            }
        }

        GSubsection {
            visible: settingsClock.cookiePresent
            title: Translation.tr("Cookie clock settings")

            GSwitchRow {
                buttonIcon: "wand_stars"
                buttonText: Translation.tr("Auto styling with Gemini")
                checked: Config.options.background.widgets.clock.cookie.aiStyling
                onCheckedChanged: Config.options.background.widgets.clock.cookie.aiStyling = checked
                GTooltip { text: Translation.tr("Uses Gemini to categorize the wallpaper then picks a preset based on it.\nYou'll need to set Gemini API key on the left sidebar first.\nImages are downscaled for performance, but just to be safe,\ndo not select wallpapers with sensitive information.") }
            }
            GSwitchRow {
                buttonIcon: "airwave"
                buttonText: Translation.tr("Use old sine wave cookie implementation")
                checked: Config.options.background.widgets.clock.cookie.useSineCookie
                onCheckedChanged: Config.options.background.widgets.clock.cookie.useSineCookie = checked
                GTooltip { text: Translation.tr("Looks a bit softer and more consistent with different number of sides,\nbut has less impressive morphing") }
            }
            GSpinRow {
                icon: "add_triangle"
                text: Translation.tr("Sides")
                value: Config.options.background.widgets.clock.cookie.sides
                from: 0; to: 40; stepSize: 1
                onValueChanged: Config.options.background.widgets.clock.cookie.sides = value
            }
            GSwitchRow {
                buttonIcon: "autoplay"
                buttonText: Translation.tr("Constantly rotate")
                checked: Config.options.background.widgets.clock.cookie.constantlyRotate
                onCheckedChanged: Config.options.background.widgets.clock.cookie.constantlyRotate = checked
                GTooltip { text: Translation.tr("Makes the clock always rotate. This is extremely expensive\n(expect 50% usage on Intel UHD Graphics) and thus impractical.") }
            }
            GRow {
                GSwitchRow {
                    enabled: Config.options.background.widgets.clock.cookie.dialNumberStyle === "dots" || Config.options.background.widgets.clock.cookie.dialNumberStyle === "full"
                    buttonIcon: "brightness_7"
                    buttonText: Translation.tr("Hour marks")
                    checked: Config.options.background.widgets.clock.cookie.hourMarks
                    onEnabledChanged: checked = Config.options.background.widgets.clock.cookie.hourMarks
                    onCheckedChanged: Config.options.background.widgets.clock.cookie.hourMarks = checked
                    GTooltip { text: Translation.tr("Can only be turned on using the 'Dots' or 'Full' dial style for aesthetic reasons") }
                }
                GSwitchRow {
                    enabled: Config.options.background.widgets.clock.cookie.dialNumberStyle !== "numbers"
                    buttonIcon: "timer_10"
                    buttonText: Translation.tr("Digits in the middle")
                    checked: Config.options.background.widgets.clock.cookie.timeIndicators
                    onEnabledChanged: checked = Config.options.background.widgets.clock.cookie.timeIndicators
                    onCheckedChanged: Config.options.background.widgets.clock.cookie.timeIndicators = checked
                    GTooltip { text: Translation.tr("Can't be turned on when using 'Numbers' dial style for aesthetic reasons") }
                }
            }
        }

        GSubsection {
            visible: settingsClock.cookiePresent
            title: Translation.tr("Dial style")
            GSelectGroup {
                currentValue: Config.options.background.widgets.clock.cookie.dialNumberStyle
                onSelected: newValue => {
                    Config.options.background.widgets.clock.cookie.dialNumberStyle = newValue
                    if (newValue !== "dots" && newValue !== "full") Config.options.background.widgets.clock.cookie.hourMarks = false
                    if (newValue === "numbers") Config.options.background.widgets.clock.cookie.timeIndicators = false
                }
                options: [
                    { displayName: "", icon: "block", value: "none" },
                    { displayName: Translation.tr("Dots"), icon: "graph_6", value: "dots" },
                    { displayName: Translation.tr("Full"), icon: "history_toggle_off", value: "full" },
                    { displayName: Translation.tr("Numbers"), icon: "counter_1", value: "numbers" }
                ]
            }
        }

        GSubsection {
            visible: settingsClock.cookiePresent
            title: Translation.tr("Hour hand")
            GSelectGroup {
                currentValue: Config.options.background.widgets.clock.cookie.hourHandStyle
                onSelected: newValue => Config.options.background.widgets.clock.cookie.hourHandStyle = newValue
                options: [
                    { displayName: "", icon: "block", value: "hide" },
                    { displayName: Translation.tr("Classic"), icon: "radio", value: "classic" },
                    { displayName: Translation.tr("Hollow"), icon: "circle", value: "hollow" },
                    { displayName: Translation.tr("Fill"), icon: "eraser_size_5", value: "fill" }
                ]
            }
        }

        GSubsection {
            visible: settingsClock.cookiePresent
            title: Translation.tr("Minute hand")
            GSelectGroup {
                currentValue: Config.options.background.widgets.clock.cookie.minuteHandStyle
                onSelected: newValue => Config.options.background.widgets.clock.cookie.minuteHandStyle = newValue
                options: [
                    { displayName: "", icon: "block", value: "hide" },
                    { displayName: Translation.tr("Classic"), icon: "radio", value: "classic" },
                    { displayName: Translation.tr("Thin"), icon: "line_end", value: "thin" },
                    { displayName: Translation.tr("Medium"), icon: "eraser_size_2", value: "medium" },
                    { displayName: Translation.tr("Bold"), icon: "eraser_size_4", value: "bold" }
                ]
            }
        }

        GSubsection {
            visible: settingsClock.cookiePresent
            title: Translation.tr("Second hand")
            GSelectGroup {
                currentValue: Config.options.background.widgets.clock.cookie.secondHandStyle
                onSelected: newValue => Config.options.background.widgets.clock.cookie.secondHandStyle = newValue
                options: [
                    { displayName: "", icon: "block", value: "hide" },
                    { displayName: Translation.tr("Classic"), icon: "radio", value: "classic" },
                    { displayName: Translation.tr("Line"), icon: "line_end", value: "line" },
                    { displayName: Translation.tr("Dot"), icon: "adjust", value: "dot" }
                ]
            }
        }

        GSubsection {
            visible: settingsClock.cookiePresent
            title: Translation.tr("Date style")
            GSelectGroup {
                currentValue: Config.options.background.widgets.clock.cookie.dateStyle
                onSelected: newValue => Config.options.background.widgets.clock.cookie.dateStyle = newValue
                options: [
                    { displayName: "", icon: "block", value: "hide" },
                    { displayName: Translation.tr("Bubble"), icon: "bubble_chart", value: "bubble" },
                    { displayName: Translation.tr("Border"), icon: "rotate_right", value: "border" },
                    { displayName: Translation.tr("Rect"), icon: "rectangle", value: "rect" }
                ]
            }
        }

        GSubsection {
            title: Translation.tr("Quote")
            GSwitchRow {
                buttonIcon: "check"
                buttonText: Translation.tr("Enable")
                checked: Config.options.background.widgets.clock.quote.enable
                onCheckedChanged: Config.options.background.widgets.clock.quote.enable = checked
            }
            GTextArea {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Quote")
                text: Config.options.background.widgets.clock.quote.text
                wrapMode: TextEdit.Wrap
                onTextChanged: Config.options.background.widgets.clock.quote.text = text
            }
        }
    }

    GSection {
        icon: "weather_mix"
        title: Translation.tr("Widget: Weather")

        GRow {
            Layout.fillWidth: true
            GSwitchRow {
                Layout.fillWidth: false
                buttonIcon: "check"
                buttonText: Translation.tr("Enable")
                checked: Config.options.background.widgets.weather.enable
                onCheckedChanged: Config.options.background.widgets.weather.enable = checked
            }
            Item { Layout.fillWidth: true }
            GSelectGroup {
                Layout.fillWidth: false
                currentValue: Config.options.background.widgets.weather.placementStrategy
                onSelected: newValue => Config.options.background.widgets.weather.placementStrategy = newValue
                options: [
                    { displayName: Translation.tr("Draggable"), icon: "drag_pan", value: "free" },
                    { displayName: Translation.tr("Least busy"), icon: "category", value: "leastBusy" },
                    { displayName: Translation.tr("Most busy"), icon: "shapes", value: "mostBusy" }
                ]
            }
        }
    }
}
