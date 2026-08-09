pragma ComponentBehavior: Bound
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.modules.ii.sidebarRight.notifications
import qs.modules.ii.sidebarRight.calendar
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Scope {
    id: root
    readonly property real panelWidth: 760
    readonly property real panelHeight: 540

    Loader {
        id: panelLoader
        active: GlobalStates.notifCenterOpen
        onActiveChanged: {
            if (active) {
                Notifications.timeoutAll();
                Notifications.markAllRead();
            }
        }
        sourceComponent: PanelWindow {
            id: panelWindow
            visible: true
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            implicitWidth: root.panelWidth
            implicitHeight: root.panelHeight
            color: "transparent"
            WlrLayershell.namespace: "quickshell:notifCenter"

            anchors {
                top: !Config.options.bar.bottom
                bottom: Config.options.bar.bottom
                left: true
                right: true
            }
            margins {
                top: Config.options.bar.bottom ? 0 : Appearance.sizes.barHeight + 8
                bottom: Config.options.bar.bottom ? Appearance.sizes.barHeight + 8 : 0
                left: (panelWindow.screen.width - root.panelWidth) / 2
                right: (panelWindow.screen.width - root.panelWidth) / 2
            }

            Component.onCompleted: {
                GlobalFocusGrab.addDismissable(panelWindow);
            }
            Component.onDestruction: {
                GlobalFocusGrab.removeDismissable(panelWindow);
            }
            Connections {
                target: GlobalFocusGrab
                function onDismissed() {
                    GlobalStates.notifCenterOpen = false;
                }
            }

            StyledRectangularShadow {
                target: centerSurface
            }

            Rectangle {
                id: centerSurface
                anchors.fill: parent
                radius: Appearance.rounding.screenRounding - Appearance.sizes.hyprlandGapsOut + 1
                color: ColorUtils.applyAlpha(Appearance.colors.colLayer0Base, 0.94)
                border.width: 1
                border.color: Appearance.colors.colLayer0Border
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    RowLayout { // Header
                        Layout.fillWidth: true
                        spacing: 8

                        MaterialSymbol {
                            text: "notifications_active"
                            iconSize: 18
                            color: Notifications.silent ? Appearance.colors.colSubtext : Appearance.colors.colPrimary
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: Translation.tr("Notification Center")
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.DemiBold
                            color: Appearance.colors.colOnLayer1
                        }
                        RippleButton { // DND toggle
                            id: dndButton
                            buttonRadius: Appearance.rounding.full
                            implicitHeight: 30
                            colBackground: ColorUtils.applyAlpha(Appearance.colors.colLayer1Base, 0.4)
                            colBackgroundHover: Appearance.colors.colLayer1Hover
                            colBackgroundToggled: Appearance.colors.colPrimary
                            colBackgroundToggledHover: Appearance.colors.colPrimaryHover
                            toggled: Notifications.silent
                            onClicked: Notifications.silent = !Notifications.silent
                            contentItem: RowLayout {
                                spacing: 6
                                MaterialSymbol {
                                    text: Notifications.silent ? "notifications_paused" : "notifications"
                                    iconSize: 15
                                    color: dndButton.toggled ? Appearance.m3colors.m3onPrimary : Appearance.colors.colOnLayer1
                                }
                                StyledText {
                                    text: Notifications.silent ? Translation.tr("Paused") : Translation.tr("Do not disturb")
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: dndButton.toggled ? Appearance.m3colors.m3onPrimary : Appearance.colors.colOnLayer1
                                }
                            }
                            StyledToolTip {
                                text: Translation.tr("Toggle do-not-disturb (middle-click bell in bar)")
                            }
                        }
                        RippleButton { // Clear all
                            buttonRadius: Appearance.rounding.full
                            implicitHeight: 30
                            implicitWidth: 30
                            colBackground: ColorUtils.applyAlpha(Appearance.colors.colLayer1Base, 0.4)
                            colBackgroundHover: Appearance.colors.colLayer1Hover
                            onClicked: Notifications.discardAllNotifications()
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                text: "delete_sweep"
                                iconSize: 15
                                color: Appearance.colors.colOnLayer1
                            }
                            StyledToolTip {
                                text: Translation.tr("Clear all notifications")
                            }
                        }
                        RippleButton { // Close
                            buttonRadius: Appearance.rounding.full
                            implicitHeight: 30
                            implicitWidth: 30
                            colBackground: ColorUtils.applyAlpha(Appearance.colors.colLayer1Base, 0.4)
                            colBackgroundHover: Appearance.colors.colLayer1Hover
                            onClicked: GlobalStates.notifCenterOpen = false
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                text: "close"
                                iconSize: 15
                                color: Appearance.colors.colOnLayer1
                            }
                        }
                    }

                    RowLayout { // Calendar + Notifications
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 14

                        Rectangle { // Calendar card
                            Layout.fillWidth: false
                            Layout.fillHeight: true
                            Layout.preferredWidth: 330
                            radius: Appearance.rounding.normal
                            color: ColorUtils.applyAlpha(Appearance.colors.colLayer1Base, 0.3)
                            border.width: 1
                            border.color: Appearance.colors.colLayer0Border
                            clip: true

                            CalendarWidget {
                                anchors.centerIn: parent
                            }
                        }

                        Rectangle { // Notifications card
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: Appearance.rounding.normal
                            color: ColorUtils.applyAlpha(Appearance.colors.colLayer1Base, 0.3)
                            border.width: 1
                            border.color: Appearance.colors.colLayer0Border
                            clip: true

                            NotificationList {
                                anchors.fill: parent
                                anchors.margins: 6
                            }
                        }
                    }
                }
            }
        }
    }
}
