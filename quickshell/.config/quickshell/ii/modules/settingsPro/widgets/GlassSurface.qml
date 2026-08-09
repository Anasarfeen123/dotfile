import QtQuick
import qs.modules.common
import qs.modules.common.functions

// Base translucent card. Simple by design: a tinted fill + a hairline border. The real
// blur comes from the Hyprland compositor (this window floats and is translucent) —
// this widget just needs to read as a slightly-lighter glass pane, not do all the work.
Rectangle {
    id: root

    property real fillOpacity: 0.6
    property color tint: Appearance.colors.colLayer1Base
    property bool showSheen: false
    property bool showBorder: true
    default property alias contentData: content.data

    radius: Appearance.rounding.normal
    color: ColorUtils.applyAlpha(root.tint, root.fillOpacity)
    antialiasing: true

    border.width: root.showBorder ? 1 : 0
    border.color: ColorUtils.applyAlpha(Appearance.m3colors.m3onBackground, 0.1)

    Behavior on color {
        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
    }

    Item {
        id: content
        anchors.fill: parent
    }
}
