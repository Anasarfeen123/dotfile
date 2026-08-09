import QtQuick
import QtQuick.Layouts
import qs.modules.common

// Small hamburger/collapse toggle at the top of the nav rail.
GIconButton {
    id: root
    Layout.alignment: Qt.AlignLeft
    implicitWidth: 40
    implicitHeight: 40
    downAction: () => { root.parent.expanded = !root.parent.expanded }
    buttonIcon: root.parent?.expanded ? "menu_open" : "menu"

    rotation: root.parent?.expanded ? 0 : -180
    Behavior on rotation {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }
}
