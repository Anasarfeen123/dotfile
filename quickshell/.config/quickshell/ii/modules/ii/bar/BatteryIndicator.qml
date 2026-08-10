import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    property bool borderless: Config.options.bar.borderless
    readonly property var chargeState: Battery.chargeState
    readonly property bool isCharging: Battery.isCharging
    readonly property bool isPluggedIn: Battery.isPluggedIn
    readonly property real percentage: Battery.percentage
    readonly property bool isLow: percentage <= Config.options.battery.low / 100
    readonly property bool batterySaverEnabled: GlobalStates.batterySaverEnabled
    readonly property color batterySaverColor: "#f59e0b"

    implicitWidth: batteryProgress.implicitWidth
    implicitHeight: Appearance.sizes.barHeight

    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onPressed: event => {
        if (event.button === Qt.RightButton) {
            GlobalStates.toggleBatterySaver();
            event.accepted = true;
        }
    }

    hoverEnabled: !Config.options.bar.tooltips.clickToShow

    ClippedProgressBar {
        id: batteryProgress
        anchors.centerIn: parent
        value: percentage
        highlightColor: batterySaverEnabled
            ? root.batterySaverColor
            : (isLow && !isCharging) ? Appearance.m3colors.m3error : Appearance.colors.colOnSecondaryContainer

        Behavior on highlightColor {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }

        Item {
            anchors.centerIn: parent
            width: batteryProgress.valueBarWidth
            height: batteryProgress.valueBarHeight

            RowLayout {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: (parent.height - height) / 2
                }
                spacing: 0

                MaterialSymbol {
                    id: boltIcon
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: -2
                    Layout.rightMargin: -2
                    fill: 1
                    text: batterySaverEnabled ? "energy_savings_leaf" : "bolt"
                    iconSize: Appearance.font.pixelSize.smaller
                    color: batterySaverEnabled ? root.batterySaverColor : Appearance.colors.colOnSecondaryContainer
                    visible: batterySaverEnabled || (isCharging && percentage < 1) // TODO: animation
                }
                StyledText {
                    Layout.alignment: Qt.AlignVCenter
                    font: batteryProgress.font
                    text: batteryProgress.text
                    color: batterySaverEnabled ? root.batterySaverColor : Appearance.colors.colOnLayer1
                }
            }
        }
    }

    BatteryPopup {
        id: batteryPopup
        hoverTarget: root
    }

    // Keep the action above the bar's broad right-side mouse region so a
    // right-click on the actual battery indicator cannot be swallowed.
    MouseArea {
        anchors.fill: parent
        z: 100
        acceptedButtons: Qt.RightButton
        onPressed: event => {
            GlobalStates.toggleBatterySaver();
            event.accepted = true;
        }
    }
}
