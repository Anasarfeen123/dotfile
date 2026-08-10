import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import qs.services
import qs.modules.common
import qs.modules.settingsPro.widgets
import qs.modules.common.widgets as CW
import qs.modules.common.functions

GPage {
    forceWidth: true
    resetPaths: ["appearance.palette", "appearance.transparency", "appearance.fakeScreenRounding", "background.wallpaperPath", "cheatsheet.superKey", "policies.weeb"]

    Process {
        id: randomWallProc
        property string status: ""
        property string scriptPath: `${Directories.scriptPath}/colors/random/random_konachan_wall.sh`
        command: ["bash", "-c", FileUtils.trimFileProtocol(randomWallProc.scriptPath)]
        stdout: SplitParser { onRead: data => { randomWallProc.status = data.trim() } }
    }

    component SmallLightDarkPreferenceButton: GButton {
        id: smallLightDarkPreferenceButton
        required property bool dark
        Layout.fillWidth: true
        toggled: Appearance.m3colors.darkmode === dark
        primary: toggled
        buttonRadius: Appearance.rounding.small
        onClicked: Quickshell.execDetached(["bash", "-c", `${Directories.wallpaperSwitchScriptPath} --mode ${dark ? "dark" : "light"} --noswitch`])
        contentItem: Item {
            anchors.centerIn: parent
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 0
                GIcon { Layout.alignment: Qt.AlignHCenter; size: 30; text: dark ? "dark_mode" : "light_mode"; color: smallLightDarkPreferenceButton.contentColor }
                GText {
                    Layout.alignment: Qt.AlignHCenter
                    text: dark ? Translation.tr("Dark") : Translation.tr("Light")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: smallLightDarkPreferenceButton.contentColor
                }
            }
        }
    }

    GSection {
        icon: "format_paint"
        title: Translation.tr("Wallpaper & Colors")
        Layout.fillWidth: true

        RowLayout {
            Layout.fillWidth: true

            Item {
                implicitWidth: 340
                implicitHeight: 200

                CW.StyledImage {
                    id: wallpaperPreview
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    source: Config.options.background.wallpaperPath
                    cache: false
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle { width: 360; height: 200; radius: Appearance.rounding.normal }
                    }
                }
            }

            ColumnLayout {
                GButton {
                    enabled: !randomWallProc.running
                    visible: Config.options.policies.weeb === 1
                    Layout.fillWidth: true
                    buttonRadius: Appearance.rounding.small
                    buttonIcon: "auto_awesome"
                    buttonText: randomWallProc.running ? Translation.tr("Be patient...") : Translation.tr("Random: Konachan")
                    onClicked: {
                        randomWallProc.scriptPath = `${Directories.scriptPath}/colors/random/random_konachan_wall.sh`
                        randomWallProc.running = true
                    }
                    GTooltip { text: Translation.tr("Random SFW Anime wallpaper from Konachan\nImage is saved to ~/Pictures/Wallpapers") }
                }
                GButton {
                    enabled: !randomWallProc.running
                    visible: Config.options.policies.weeb === 1
                    Layout.fillWidth: true
                    buttonRadius: Appearance.rounding.small
                    buttonIcon: "auto_awesome"
                    buttonText: randomWallProc.running ? Translation.tr("Be patient...") : Translation.tr("Random: osu! seasonal")
                    onClicked: {
                        randomWallProc.scriptPath = `${Directories.scriptPath}/colors/random/random_osu_wall.sh`
                        randomWallProc.running = true
                    }
                    GTooltip { text: Translation.tr("Random osu! seasonal background\nImage is saved to ~/Pictures/Wallpapers") }
                }
                GButton {
                    id: chooseFileBtn
                    Layout.fillWidth: true
                    buttonRadius: Appearance.rounding.small
                    buttonIcon: "wallpaper"
                    onClicked: Quickshell.execDetached(`${Directories.wallpaperSwitchScriptPath}`)
                    GTooltip { text: Translation.tr("Pick wallpaper image on your system") }
                    mainContentComponent: Component {
                        RowLayout {
                            spacing: 10
                            GText { text: Translation.tr("Choose file"); color: chooseFileBtn.contentColor }
                            RowLayout {
                                spacing: 3
                                GKeyCap { key: "Ctrl" }
                                GKeyCap { key: Config.options.cheatsheet.superKey || "" }
                                GText { Layout.alignment: Qt.AlignVCenter; text: "+" }
                                GKeyCap { key: "T" }
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    uniformCellSizes: true
                    SmallLightDarkPreferenceButton { Layout.fillHeight: true; dark: false }
                    SmallLightDarkPreferenceButton { Layout.fillHeight: true; dark: true }
                }
            }
        }

        GSelectGroup {
            currentValue: Config.options.appearance.palette.type
            onSelected: newValue => {
                Config.options.appearance.palette.type = newValue
                Quickshell.execDetached(["bash", "-c", `${Directories.wallpaperSwitchScriptPath} --noswitch`])
            }
            options: [
                { value: "auto", displayName: Translation.tr("Auto") },
                { value: "scheme-content", displayName: Translation.tr("Content") },
                { value: "scheme-expressive", displayName: Translation.tr("Expressive") },
                { value: "scheme-fidelity", displayName: Translation.tr("Fidelity") },
                { value: "scheme-fruit-salad", displayName: Translation.tr("Fruit Salad") },
                { value: "scheme-monochrome", displayName: Translation.tr("Monochrome") },
                { value: "scheme-neutral", displayName: Translation.tr("Neutral") },
                { value: "scheme-rainbow", displayName: Translation.tr("Rainbow") },
                { value: "scheme-tonal-spot", displayName: Translation.tr("Tonal Spot") }
            ]
        }

        GSubsection {
            title: Translation.tr("Transparency")

            GSwitchRow {
                buttonIcon: "ev_shadow"
                buttonText: Translation.tr("Enable transparency")
                checked: Config.options.appearance.transparency.enable
                onCheckedChanged: Config.options.appearance.transparency.enable = checked
            }
            GSwitchRow {
                buttonIcon: "auto_awesome"
                buttonText: Translation.tr("Automatic (from wallpaper)")
                checked: Config.options.appearance.transparency.automatic
                onCheckedChanged: Config.options.appearance.transparency.automatic = checked
                GTooltip { text: Translation.tr("Automatically derives background transparency from the wallpaper's vibrancy") }
            }
            GSliderRow {
                text: Translation.tr("Background transparency")
                buttonIcon: "blur_on"
                enabled: Config.options.appearance.transparency.enable && !Config.options.appearance.transparency.automatic
                value: Config.options.appearance.transparency.backgroundTransparency * 100
                from: 0; to: 100
                stopIndicatorValues: [11]
                onValueChanged: Config.options.appearance.transparency.backgroundTransparency = value / 100
            }
            GSliderRow {
                text: Translation.tr("Content transparency")
                buttonIcon: "invert_colors"
                // Was missing the `enable` half of this condition (present
                // on the Background transparency slider right above) — so
                // with transparency itself turned off but Automatic left
                // off too, this slider stayed editable even though
                // transparency wasn't in effect at all.
                enabled: Config.options.appearance.transparency.enable && !Config.options.appearance.transparency.automatic
                value: Config.options.appearance.transparency.contentTransparency * 100
                from: 0; to: 100
                stopIndicatorValues: [57]
                onValueChanged: Config.options.appearance.transparency.contentTransparency = value / 100
            }
        }
    }

    GSection {
        icon: "screenshot_monitor"
        title: Translation.tr("Bar & screen")

        GSubsection {
            title: Translation.tr("Screen round corner")
            GSelectGroup {
                currentValue: Config.options.appearance.fakeScreenRounding
                onSelected: newValue => Config.options.appearance.fakeScreenRounding = newValue
                options: [
                    { displayName: Translation.tr("No"), icon: "close", value: 0 },
                    { displayName: Translation.tr("Yes"), icon: "check", value: 1 },
                    { displayName: Translation.tr("When not fullscreen"), icon: "fullscreen_exit", value: 2 }
                ]
            }
        }
    }

    GNotice {
        Layout.fillWidth: true
        text: Translation.tr('Not all options are available in this app. You should also check the config file by hitting the "Config file" button on the topleft corner or opening %1 manually.').arg(Directories.shellConfigPath)

        Item { Layout.fillWidth: true }
        GButton {
            id: copyPathButton
            property bool justCopied: false
            buttonRadius: Appearance.rounding.small
            buttonIcon: justCopied ? "check" : "content_copy"
            buttonText: justCopied ? Translation.tr("Path copied") : Translation.tr("Copy path")
            primary: true
            onClicked: {
                copyPathButton.justCopied = true
                Quickshell.clipboardText = FileUtils.trimFileProtocol(`${Directories.config}/illogical-impulse/config.json`)
                revertTextTimer.restart()
            }
            Timer { id: revertTextTimer; interval: 1500; onTriggered: copyPathButton.justCopied = false }
        }
    }
}
