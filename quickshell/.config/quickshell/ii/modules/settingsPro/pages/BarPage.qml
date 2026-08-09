import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.settingsPro.widgets

GPage {
    forceWidth: true
    resetPaths: ["bar", "tray.invertPinnedItems", "tray.monochromeIcons"]

    GSection {
        icon: "notifications"
        title: Translation.tr("Notifications")
        GSwitchRow {
            buttonIcon: "counter_2"
            buttonText: Translation.tr("Unread indicator: show count")
            checked: Config.options.bar.indicators.notifications.showUnreadCount
            onCheckedChanged: Config.options.bar.indicators.notifications.showUnreadCount = checked
        }
    }

    GSection {
        icon: "spoke"
        title: Translation.tr("Positioning")

        GRow {
            ColumnLayout {
                Layout.fillWidth: true
                GText { text: Translation.tr("Bar position"); font.pixelSize: Appearance.font.pixelSize.small; font.weight: Font.Medium; color: Appearance.colors.colOnLayer2 }
                GSelectGroup {
                    currentValue: (Config.options.bar.bottom ? 1 : 0) | (Config.options.bar.vertical ? 2 : 0)
                    onSelected: newValue => {
                        Config.options.bar.bottom = (newValue & 1) !== 0
                        Config.options.bar.vertical = (newValue & 2) !== 0
                    }
                    options: [
                        { displayName: Translation.tr("Top"), icon: "arrow_upward", value: 0 },
                        { displayName: Translation.tr("Left"), icon: "arrow_back", value: 2 },
                        { displayName: Translation.tr("Bottom"), icon: "arrow_downward", value: 1 },
                        { displayName: Translation.tr("Right"), icon: "arrow_forward", value: 3 }
                    ]
                }
            }
            ColumnLayout {
                GText { text: Translation.tr("Automatically hide"); font.pixelSize: Appearance.font.pixelSize.small; font.weight: Font.Medium; color: Appearance.colors.colOnLayer2 }
                GSelectGroup {
                    currentValue: Config.options.bar.autoHide.enable
                    onSelected: newValue => Config.options.bar.autoHide.enable = newValue
                    options: [
                        { displayName: Translation.tr("No"), icon: "close", value: false },
                        { displayName: Translation.tr("Yes"), icon: "check", value: true }
                    ]
                }
            }
        }

        GRow {
            ColumnLayout {
                Layout.fillWidth: true
                GText { text: Translation.tr("Corner style"); font.pixelSize: Appearance.font.pixelSize.small; font.weight: Font.Medium; color: Appearance.colors.colOnLayer2 }
                GSelectGroup {
                    currentValue: Config.options.bar.cornerStyle
                    onSelected: newValue => Config.options.bar.cornerStyle = newValue
                    options: [
                        { displayName: Translation.tr("Hug"), icon: "line_curve", value: 0 },
                        { displayName: Translation.tr("Float"), icon: "page_header", value: 1 },
                        { displayName: Translation.tr("Rect"), icon: "toolbar", value: 2 }
                    ]
                }
            }
            ColumnLayout {
                GText { text: Translation.tr("Group style"); font.pixelSize: Appearance.font.pixelSize.small; font.weight: Font.Medium; color: Appearance.colors.colOnLayer2 }
                GSelectGroup {
                    currentValue: Config.options.bar.borderless
                    onSelected: newValue => Config.options.bar.borderless = newValue
                    options: [
                        { displayName: Translation.tr("Pills"), icon: "location_chip", value: false },
                        { displayName: Translation.tr("Line-separated"), icon: "split_scene", value: true }
                    ]
                }
            }
        }
    }

    GSection {
        icon: "shelf_auto_hide"
        title: Translation.tr("Tray")

        GSwitchRow {
            buttonIcon: "keep"
            buttonText: Translation.tr("Make icons pinned by default")
            checked: Config.options.tray.invertPinnedItems
            onCheckedChanged: Config.options.tray.invertPinnedItems = checked
        }
        GSwitchRow {
            buttonIcon: "colors"
            buttonText: Translation.tr("Tint icons")
            checked: Config.options.tray.monochromeIcons
            onCheckedChanged: Config.options.tray.monochromeIcons = checked
        }
    }

    GSection {
        icon: "widgets"
        title: Translation.tr("Utility buttons")

        GRow {
            uniform: true
            GSwitchRow {
                buttonIcon: "content_cut"
                buttonText: Translation.tr("Screen snip")
                checked: Config.options.bar.utilButtons.showScreenSnip
                onCheckedChanged: Config.options.bar.utilButtons.showScreenSnip = checked
            }
            GSwitchRow {
                buttonIcon: "colorize"
                buttonText: Translation.tr("Color picker")
                checked: Config.options.bar.utilButtons.showColorPicker
                onCheckedChanged: Config.options.bar.utilButtons.showColorPicker = checked
            }
        }
        GRow {
            uniform: true
            GSwitchRow {
                buttonIcon: "keyboard"
                buttonText: Translation.tr("Keyboard toggle")
                checked: Config.options.bar.utilButtons.showKeyboardToggle
                onCheckedChanged: Config.options.bar.utilButtons.showKeyboardToggle = checked
            }
            GSwitchRow {
                buttonIcon: "mic"
                buttonText: Translation.tr("Mic toggle")
                checked: Config.options.bar.utilButtons.showMicToggle
                onCheckedChanged: Config.options.bar.utilButtons.showMicToggle = checked
            }
        }
        GRow {
            uniform: true
            GSwitchRow {
                buttonIcon: "dark_mode"
                buttonText: Translation.tr("Dark/Light toggle")
                checked: Config.options.bar.utilButtons.showDarkModeToggle
                onCheckedChanged: Config.options.bar.utilButtons.showDarkModeToggle = checked
            }
            GSwitchRow {
                buttonIcon: "speed"
                buttonText: Translation.tr("Performance Profile toggle")
                checked: Config.options.bar.utilButtons.showPerformanceProfileToggle
                onCheckedChanged: Config.options.bar.utilButtons.showPerformanceProfileToggle = checked
            }
        }
        GRow {
            uniform: true
            GSwitchRow {
                buttonIcon: "videocam"
                buttonText: Translation.tr("Record")
                checked: Config.options.bar.utilButtons.showScreenRecord
                onCheckedChanged: Config.options.bar.utilButtons.showScreenRecord = checked
            }
            GSwitchRow {
                buttonIcon: "coffee"
                buttonText: Translation.tr("Awake (inhibit idle)")
                checked: Config.options.bar.utilButtons.showAwakeToggle
                onCheckedChanged: Config.options.bar.utilButtons.showAwakeToggle = checked
            }
        }
    }

    GSection {
        icon: "equalizer"
        title: Translation.tr("Audio visualizer")
        GSwitchRow {
            buttonIcon: "graphic_eq"
            buttonText: Translation.tr("Show audio visualizer")
            checked: Config.options.bar.showVisualizer
            onCheckedChanged: Config.options.bar.showVisualizer = checked
        }
    }

    GSection {
        icon: "cloud"
        title: Translation.tr("Weather")
        GSwitchRow {
            buttonIcon: "check"
            buttonText: Translation.tr("Enable")
            checked: Config.options.bar.weather.enable
            onCheckedChanged: Config.options.bar.weather.enable = checked
        }
    }

    GSection {
        icon: "workspaces"
        title: Translation.tr("Workspaces")

        GSwitchRow {
            buttonIcon: "counter_1"
            buttonText: Translation.tr("Always show numbers")
            checked: Config.options.bar.workspaces.alwaysShowNumbers
            onCheckedChanged: Config.options.bar.workspaces.alwaysShowNumbers = checked
        }
        GSwitchRow {
            buttonIcon: "award_star"
            buttonText: Translation.tr("Show app icons")
            checked: Config.options.bar.workspaces.showAppIcons
            onCheckedChanged: Config.options.bar.workspaces.showAppIcons = checked
        }
        GSwitchRow {
            buttonIcon: "colors"
            buttonText: Translation.tr("Tint app icons")
            checked: Config.options.bar.workspaces.monochromeIcons
            onCheckedChanged: Config.options.bar.workspaces.monochromeIcons = checked
        }
        GSpinRow {
            icon: "view_column"
            text: Translation.tr("Workspaces shown")
            value: Config.options.bar.workspaces.shown
            from: 1; to: 30; stepSize: 1
            onValueChanged: Config.options.bar.workspaces.shown = value
        }
        GSpinRow {
            icon: "touch_long"
            text: Translation.tr("Number show delay when pressing Super (ms)")
            value: Config.options.bar.workspaces.showNumberDelay
            from: 0; to: 1000; stepSize: 50
            onValueChanged: Config.options.bar.workspaces.showNumberDelay = value
        }
        GSubsection {
            title: Translation.tr("Number style")
            GSelectGroup {
                currentValue: JSON.stringify(Config.options.bar.workspaces.numberMap)
                onSelected: newValue => Config.options.bar.workspaces.numberMap = JSON.parse(newValue)
                options: [
                    { displayName: Translation.tr("Normal"), icon: "timer_10", value: '[]' },
                    { displayName: Translation.tr("Han chars"), icon: "square_dot", value: '["一","二","三","四","五","六","七","八","九","十","十一","十二","十三","十四","十五","十六","十七","十八","十九","二十"]' },
                    { displayName: Translation.tr("Roman"), icon: "account_balance", value: '["I","II","III","IV","V","VI","VII","VIII","IX","X","XI","XII","XIII","XIV","XV","XVI","XVII","XVIII","XIX","XX"]' }
                ]
            }
        }
    }

    GSection {
        icon: "tooltip"
        title: Translation.tr("Tooltips")
        GSwitchRow {
            buttonIcon: "ads_click"
            buttonText: Translation.tr("Click to show")
            checked: Config.options.bar.tooltips.clickToShow
            onCheckedChanged: Config.options.bar.tooltips.clickToShow = checked
        }
    }
}
