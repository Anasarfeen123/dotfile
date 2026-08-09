import qs.modules.common
import QtQuick

// Small circular/rounded icon-only glass button — window controls, footer actions, etc.
GButton {
    id: root
    implicitWidth: 32
    implicitHeight: 32
    buttonRadius: Appearance.rounding.full
    horizontalPadding: 0
    iconSize: Appearance.font.pixelSize.large
    mainContentComponent: null

    contentItem: GIcon {
        anchors.centerIn: parent
        text: root.buttonIcon
        size: root.iconSize
        fill: root.materialIconFill ? 1 : 0
        color: root.contentColor
    }
}
