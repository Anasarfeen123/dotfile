pragma ComponentBehavior: Bound
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

Scope {
    id: root
    readonly property real panelWidth: 250

    Loader {
        id: menuLoader
        active: GlobalStates.utilityMenuOpen
        onActiveChanged: {
            if (active) Notifications.timeoutAll();
        }
        sourceComponent: PanelWindow {
            id: menuWindow
            visible: true
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            implicitWidth: root.panelWidth
            implicitHeight: menuSurface.implicitHeight
            color: "transparent"
            WlrLayershell.namespace: "quickshell:utilityMenu"

            anchors {
                top: !Config.options.bar.bottom
                bottom: Config.options.bar.bottom
                left: true
                right: true
            }
            margins {
                top: Config.options.bar.bottom ? 0 : Appearance.sizes.barHeight + 6
                bottom: Config.options.bar.bottom ? Appearance.sizes.barHeight + 6 : 0
                left: (menuWindow.screen.width - root.panelWidth) / 2
                right: (menuWindow.screen.width - root.panelWidth) / 2
            }

            Component.onCompleted: {
                GlobalFocusGrab.addDismissable(menuWindow);
            }
            Component.onDestruction: {
                GlobalFocusGrab.removeDismissable(menuWindow);
            }
            Connections {
                target: GlobalFocusGrab
                function onDismissed() {
                    GlobalStates.utilityMenuOpen = false;
                }
            }

            StyledRectangularShadow {
                target: menuSurface
            }

            Rectangle {
                id: menuSurface
                anchors.fill: parent
                radius: Appearance.rounding.screenRounding - Appearance.sizes.hyprlandGapsOut + 1
                color: ColorUtils.applyAlpha(Appearance.colors.colLayer0Base, 0.94)
                border.width: 1
                border.color: Appearance.colors.colLayer0Border
                clip: true
                implicitWidth: root.panelWidth
                implicitHeight: menuContent.implicitHeight + 24

                ColumnLayout {
                    id: menuContent
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    RowLayout { // Header
                        Layout.fillWidth: true
                        spacing: 8
                        MaterialSymbol {
                            text: "build"
                            iconSize: 16
                            color: Appearance.colors.colOnLayer1
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: Translation.tr("Utilities")
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.DemiBold
                            color: Appearance.colors.colOnLayer1
                        }
                        MaterialSymbol {
                            text: "close"
                            iconSize: 16
                            color: Appearance.colors.colSubtext
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: GlobalStates.utilityMenuOpen = false
                            }
                        }
                    }

                    GridLayout { // Tools
                        Layout.fillWidth: true
                        columns: 4
                        columnSpacing: 8
                        rowSpacing: 10

                        UtilityGridButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            iconName: "screenshot_region"
                            label: Translation.tr("Snip")
                            onClicked: {
                                GlobalStates.utilityMenuOpen = false;
                                toolLaunchDelay.command = ["qs", "-p", Quickshell.shellPath(""), "ipc", "call", "region", "screenshot"];
                                toolLaunchDelay.restart();
                            }
                        }
                        UtilityGridButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            iconName: "videocam"
                            label: Translation.tr("Record")
                            onClicked: {
                                GlobalStates.utilityMenuOpen = false;
                                toolLaunchDelay.command = [Directories.recordScriptPath];
                                toolLaunchDelay.restart();
                            }
                        }
                        UtilityGridButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            iconName: "colorize"
                            label: Translation.tr("Picker")
                            onClicked: {
                                GlobalStates.utilityMenuOpen = false;
                                Quickshell.execDetached(["hyprpicker", "-a"])
                            }
                        }
                        UtilityGridButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            iconName: GlobalStates.oskOpen ? "keyboard_alt" : "keyboard"
                            label: Translation.tr("Keyboard")
                            active: GlobalStates.oskOpen
                            onClicked: GlobalStates.oskOpen = !GlobalStates.oskOpen
                        }
                        UtilityGridButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            iconName: Pipewire.defaultAudioSource?.audio?.muted ? "mic_off" : "mic"
                            label: Translation.tr("Mic")
                            active: Pipewire.defaultAudioSource?.audio?.muted ?? false
                            onClicked: Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_SOURCE@", "toggle"])
                        }
                        UtilityGridButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            iconName: Appearance.m3colors.darkmode ? "light_mode" : "dark_mode"
                            label: Translation.tr("Theme")
                            onClicked: {
                                if (Appearance.m3colors.darkmode) {
                                    Quickshell.execDetached(["bash", "-c", `${Directories.wallpaperSwitchScriptPath} --mode light --noswitch`])
                                } else {
                                    Quickshell.execDetached(["bash", "-c", `${Directories.wallpaperSwitchScriptPath} --mode dark --noswitch`])
                                }
                            }
                        }
                        UtilityGridButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            iconName: switch(PowerProfiles.profile) {
                                case PowerProfile.PowerSaver: return "energy_savings_leaf"
                                case PowerProfile.Balanced: return "airwave"
                                case PowerProfile.Performance: return "local_fire_department"
                            }
                            label: Translation.tr("Power")
                            active: PowerProfiles.profile !== PowerProfile.Balanced
                            onClicked: {
                                if (PowerProfiles.hasPerformanceProfile) {
                                    switch(PowerProfiles.profile) {
                                        case PowerProfile.PowerSaver: PowerProfiles.profile = PowerProfile.Balanced
                                        break;
                                        case PowerProfile.Balanced: PowerProfiles.profile = PowerProfile.Performance
                                        break;
                                        case PowerProfile.Performance: PowerProfiles.profile = PowerProfile.PowerSaver
                                        break;
                                    }
                                } else {
                                    PowerProfiles.profile = PowerProfiles.profile == PowerProfile.Balanced ? PowerProfile.PowerSaver : PowerProfile.Balanced
                                }
                            }
                        }
                        UtilityGridButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            iconName: "coffee"
                            label: Translation.tr("Awake")
                            active: Idle.inhibit
                            onClicked: Idle.toggleInhibit()
                        }
                        UtilityGridButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            iconName: Config.options.light.night.automatic ? "night_sight_auto" : "bedtime"
                            label: Translation.tr("Night light")
                            active: Hyprsunset.temperatureActive
                            onClicked: Hyprsunset.toggleTemperature()
                            Component.onCompleted: Hyprsunset.fetchState()
                        }
                        UtilityGridButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            iconName: "settings"
                            label: Translation.tr("Settings")
                            onClicked: {
                                GlobalStates.utilityMenuOpen = false;
                                Quickshell.execDetached(["qs", "-p", Quickshell.shellPath("settings.qml")]);
                            }
                        }
                    }

                    RowLayout { // Clipboard header
                        Layout.fillWidth: true
                        spacing: 8
                        MaterialSymbol {
                            text: "content_paste_go"
                            iconSize: 16
                            color: Appearance.colors.colOnLayer1
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: Translation.tr("Clipboard")
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.DemiBold
                            color: Appearance.colors.colOnLayer1
                        }
                        MaterialSymbol {
                            text: "delete_sweep"
                            iconSize: 16
                            color: Appearance.colors.colSubtext
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Cliphist.wipe()
                            }
                        }
                    }

                    Repeater {
                        model: Cliphist.entries.slice(0, 5)
                        delegate: ClipboardEntry {
                            Layout.fillWidth: true
                            required property string modelData
                            entry: modelData
                        }
                    }
                }
            }
        }
    }

    component ClipboardEntry: RippleButton {
        id: ce
        required property string entry
        implicitHeight: 34
        buttonRadius: Appearance.rounding.small
        colBackground: ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)
        colBackgroundHover: Appearance.colors.colLayer1Hover
        onClicked: Cliphist.copy(ce.entry)
        middleClickAction: () => Cliphist.deleteEntry(ce.entry)

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8
            MaterialSymbol {
                text: Cliphist.entryIsImage(ce.entry) ? "image" : "content_paste"
                iconSize: 15
                color: Appearance.colors.colSubtext
            }
            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: Cliphist.entryIsImage(ce.entry) ? Translation.tr("Image") : ce.entry.replace(/^\d+\t/, "")
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colOnLayer1
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }

        PopupToolTip {
            text: Translation.tr("Left: copy | Middle: delete")
            anchorEdges: Edges.Top
        }
    }

    component UtilityGridButton: RippleButton {
        id: gb
        required property string iconName
        required property string label
        property bool active: false
        toggled: gb.active
        implicitWidth: 46
        implicitHeight: 52
        buttonRadius: Appearance.rounding.normal
        colBackground: ColorUtils.applyAlpha(Appearance.colors.colLayer1Base, 0.4)
        colBackgroundHover: Appearance.colors.colLayer1Hover
        colBackgroundToggled: Appearance.colors.colPrimary
        colBackgroundToggledHover: Appearance.colors.colPrimaryHover

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 2
            MaterialSymbol {
                Layout.alignment: Qt.AlignHCenter
                text: gb.iconName
                iconSize: 20
                color: gb.toggled ? Appearance.m3colors.m3onPrimary : Appearance.colors.colOnLayer1
            }
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: gb.label
                font.pixelSize: Appearance.font.pixelSize.smallest
                color: gb.toggled ? Appearance.m3colors.m3onPrimary : Appearance.colors.colSubtext
                elide: Text.ElideRight
            }
        }

        StyledToolTip {
            text: gb.label
        }
    }

    Timer {
        id: toolLaunchDelay
        interval: 250
        property var command: []
        onTriggered: {
            if (command.length > 0) Quickshell.execDetached(command);
        }
    }
}
