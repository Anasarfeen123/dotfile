import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.settingsPro.widgets

GPage {
    forceWidth: true
    resetPaths: ["audio.protection", "battery", "conflictKiller", "language.ui", "media.filterDuplicatePlayers", "policies", "sounds", "time", "updates", "workSafety.enable"]

    Process {
        id: translationProc
        property string locale: ""
        command: [Directories.aiTranslationScriptPath, translationProc.locale]
    }

    GSection {
        icon: "volume_up"
        title: Translation.tr("Audio")

        GSwitchRow {
            buttonIcon: "hearing"
            buttonText: Translation.tr("Earbang protection")
            checked: Config.options.audio.protection.enable
            onCheckedChanged: Config.options.audio.protection.enable = checked
            GTooltip { text: Translation.tr("Prevents abrupt increments and restricts volume limit") }
        }
        GRow {
            enabled: Config.options.audio.protection.enable
            GSpinRow {
                icon: "arrow_warm_up"
                text: Translation.tr("Max allowed increase")
                value: Config.options.audio.protection.maxAllowedIncrease
                from: 0; to: 100; stepSize: 2
                onValueChanged: Config.options.audio.protection.maxAllowedIncrease = value
            }
            GSpinRow {
                icon: "vertical_align_top"
                text: Translation.tr("Volume limit")
                value: Config.options.audio.protection.maxAllowed
                from: 0; to: 154; stepSize: 2
                onValueChanged: Config.options.audio.protection.maxAllowed = value
            }
        }
    }

    GSection {
        icon: "battery_android_full"
        title: Translation.tr("Battery")

        GRow {
            uniform: true
            GSpinRow {
                icon: "warning"
                text: Translation.tr("Low warning")
                value: Config.options.battery.low
                from: 0; to: 100; stepSize: 5
                onValueChanged: Config.options.battery.low = value
            }
            GSpinRow {
                icon: "dangerous"
                text: Translation.tr("Critical warning")
                value: Config.options.battery.critical
                from: 0; to: 100; stepSize: 5
                onValueChanged: Config.options.battery.critical = value
            }
        }
        GRow {
            uniform: false
            Layout.fillWidth: false
            GSwitchRow {
                buttonIcon: "pause"
                buttonText: Translation.tr("Automatic suspend")
                checked: Config.options.battery.automaticSuspend
                onCheckedChanged: Config.options.battery.automaticSuspend = checked
                GTooltip { text: Translation.tr("Automatically suspends the system when battery is low") }
            }
            GSpinRow {
                enabled: Config.options.battery.automaticSuspend
                text: Translation.tr("at")
                value: Config.options.battery.suspend
                from: 0; to: 100; stepSize: 5
                onValueChanged: Config.options.battery.suspend = value
            }
        }
        GRow {
            uniform: true
            GSpinRow {
                icon: "charger"
                text: Translation.tr("Full warning")
                value: Config.options.battery.full
                from: 0; to: 101; stepSize: 5
                onValueChanged: Config.options.battery.full = value
            }
        }
    }

    GSection {
        icon: "language"
        title: Translation.tr("Language")

        GSubsection {
            title: Translation.tr("Interface Language")
            tooltip: Translation.tr("Select the language for the user interface.\n\"Auto\" will use your system's locale.")

            GDropdown {
                id: languageSelector
                buttonIcon: "language"
                textRole: "displayName"
                model: [
                    { displayName: Translation.tr("Auto (System)"), value: "auto" },
                    ...Translation.allAvailableLanguages.map(lang => ({ displayName: lang, value: lang }))
                ]
                currentIndex: {
                    const index = model.findIndex(item => item.value === Config.options.language.ui)
                    return index !== -1 ? index : 0
                }
                onActivated: index => Config.options.language.ui = model[index].value
            }
        }
        GSubsection {
            title: Translation.tr("Generate translation with Gemini")
            tooltip: Translation.tr("You'll need to enter your Gemini API key first.\nType /key on the sidebar for instructions.")

            GRow {
                GTextArea {
                    id: localeInput
                    Layout.fillWidth: true
                    placeholderText: Translation.tr("Locale code, e.g. fr_FR, de_DE, zh_CN...")
                    text: Config.options.language.ui === "auto" ? Qt.locale().name : Config.options.language.ui
                }
                GButton {
                    id: generateTranslationBtn
                    Layout.fillHeight: true
                    buttonIcon: "translate"
                    primary: true
                    enabled: !translationProc.running || (translationProc.locale !== localeInput.text.trim())
                    buttonText: enabled ? Translation.tr("Generate\nTypically takes 2 minutes") : Translation.tr("Generating...\nDon't close this window!")
                    onClicked: {
                        translationProc.locale = localeInput.text.trim()
                        translationProc.running = false
                        translationProc.running = true
                    }
                }
            }
        }
    }

    GSection {
        icon: "rule"
        title: Translation.tr("Policies")

        GRow {
            ColumnLayout {
                GText { text: Translation.tr("AI"); font.pixelSize: Appearance.font.pixelSize.small; font.weight: Font.Medium; color: Appearance.colors.colOnLayer2 }
                GSelectGroup {
                    currentValue: Config.options.policies.ai
                    onSelected: newValue => Config.options.policies.ai = newValue
                    options: [
                        { displayName: Translation.tr("No"), icon: "close", value: 0 },
                        { displayName: Translation.tr("Yes"), icon: "check", value: 1 },
                        { displayName: Translation.tr("Local only"), icon: "sync_saved_locally", value: 2 }
                    ]
                }
            }
            ColumnLayout {
                GText { text: Translation.tr("Weeb"); font.pixelSize: Appearance.font.pixelSize.small; font.weight: Font.Medium; color: Appearance.colors.colOnLayer2 }
                GSelectGroup {
                    currentValue: Config.options.policies.weeb
                    onSelected: newValue => Config.options.policies.weeb = newValue
                    options: [
                        { displayName: Translation.tr("No"), icon: "close", value: 0 },
                        { displayName: Translation.tr("Yes"), icon: "check", value: 1 },
                        { displayName: Translation.tr("Closet"), icon: "ev_shadow", value: 2 }
                    ]
                }
            }
        }
    }

    GSection {
        icon: "notification_sound"
        title: Translation.tr("Sounds")
        GRow {
            uniform: true
            GSwitchRow {
                buttonIcon: "battery_android_full"
                buttonText: Translation.tr("Battery")
                checked: Config.options.sounds.battery
                onCheckedChanged: Config.options.sounds.battery = checked
            }
            GSwitchRow {
                buttonIcon: "av_timer"
                buttonText: Translation.tr("Pomodoro")
                checked: Config.options.sounds.pomodoro
                onCheckedChanged: Config.options.sounds.pomodoro = checked
            }
        }
    }

    GSection {
        icon: "nest_clock_farsight_analog"
        title: Translation.tr("Time")

        GSwitchRow {
            buttonIcon: "pace"
            buttonText: Translation.tr("Second precision")
            checked: Config.options.time.secondPrecision
            onCheckedChanged: Config.options.time.secondPrecision = checked
            GTooltip { text: Translation.tr("Enable if you want clocks to show seconds accurately") }
        }

        GSubsection {
            title: Translation.tr("Format")
            GSelectGroup {
                currentValue: Config.options.time.format
                onSelected: newValue => {
                    if (newValue === "hh:mm") {
                        Quickshell.execDetached(["bash", "-c", `sed -i 's/\\TIME12\\b/TIME/' '${FileUtils.trimFileProtocol(Directories.config)}/hypr/hyprlock.conf'`])
                    } else {
                        Quickshell.execDetached(["bash", "-c", `sed -i 's/\\TIME\\b/TIME12/' '${FileUtils.trimFileProtocol(Directories.config)}/hypr/hyprlock.conf'`])
                    }
                    Config.options.time.format = newValue
                }
                options: [
                    { displayName: Translation.tr("24h"), value: "hh:mm" },
                    { displayName: Translation.tr("12h am/pm"), value: "h:mm ap" },
                    { displayName: Translation.tr("12h AM/PM"), value: "h:mm AP" }
                ]
            }
        }
    }

    GSection {
        icon: "work_alert"
        title: Translation.tr("Work safety")

        GSwitchRow {
            buttonIcon: "assignment"
            buttonText: Translation.tr("Hide clipboard images copied from sussy sources")
            checked: Config.options.workSafety.enable.clipboard
            onCheckedChanged: Config.options.workSafety.enable.clipboard = checked
        }
        GSwitchRow {
            buttonIcon: "wallpaper"
            buttonText: Translation.tr("Hide sussy/anime wallpapers")
            checked: Config.options.workSafety.enable.wallpaper
            onCheckedChanged: Config.options.workSafety.enable.wallpaper = checked
        }
    }

    GSection {
        // "system_update" isn't in the installed font; "_alt" is.
        icon: "system_update_alt"
        title: Translation.tr("Updates")

        GSwitchRow {
            buttonIcon: "sync"
            buttonText: Translation.tr("Check for updates on startup")
            checked: Config.options.updates.enableCheck
            onCheckedChanged: Config.options.updates.enableCheck = checked
            GTooltip { text: Translation.tr("Polls your package manager periodically to see how many updates are available") }
        }
        GRow {
            enabled: Config.options.updates.enableCheck
            GSpinRow {
                icon: "schedule"
                text: Translation.tr("Check interval (minutes)")
                value: Config.options.updates.checkInterval
                from: 1; to: 10080; stepSize: 15
                onValueChanged: Config.options.updates.checkInterval = value
            }
        }
        GRow {
            enabled: Config.options.updates.enableCheck
            GSpinRow {
                icon: "lightbulb"
                text: Translation.tr("Advise update (packages)")
                value: Config.options.updates.adviseUpdateThreshold
                from: 1; to: 500; stepSize: 5
                onValueChanged: Config.options.updates.adviseUpdateThreshold = value
            }
            GSpinRow {
                icon: "alarm"
                text: Translation.tr("Strongly advise (packages)")
                value: Config.options.updates.stronglyAdviseUpdateThreshold
                from: 1; to: 1000; stepSize: 5
                onValueChanged: Config.options.updates.stronglyAdviseUpdateThreshold = value
            }
        }
    }

    GSection {
        icon: "speaker"
        title: Translation.tr("Media")

        GSwitchRow {
            buttonIcon: "filter_alt"
            buttonText: Translation.tr("Filter duplicate media players")
            checked: Config.options.media.filterDuplicatePlayers
            onCheckedChanged: Config.options.media.filterDuplicatePlayers = checked
            GTooltip { text: Translation.tr("Hides duplicate media entries (e.g. the aggregated playerctl source and a browser's native player)") }
        }
    }

    GSection {
        // Was "conflict" — a real Material Symbols name, same as "scroll"
        // elsewhere, but not present in the installed font build, so it
        // fell back to literal text instead of a glyph.
        icon: "dangerous"
        title: Translation.tr("Conflict killer")

        GSwitchRow {
            buttonIcon: "notifications_active"
            buttonText: Translation.tr("Kill duplicate notification daemons")
            checked: Config.options.conflictKiller.autoKillNotificationDaemons
            onCheckedChanged: Config.options.conflictKiller.autoKillNotificationDaemons = checked
            GTooltip { text: Translation.tr("Automatically kills other notification daemons that start up, preventing duplicate notifications") }
        }
        GSwitchRow {
            buttonIcon: "system_update_alt"
            buttonText: Translation.tr("Kill duplicate trays")
            checked: Config.options.conflictKiller.autoKillTrays
            onCheckedChanged: Config.options.conflictKiller.autoKillTrays = checked
            GTooltip { text: Translation.tr("Automatically kills redundant system trays so you only ever get one") }
        }
    }
}
