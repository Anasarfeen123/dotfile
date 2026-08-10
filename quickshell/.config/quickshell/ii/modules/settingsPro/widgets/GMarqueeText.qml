import QtQuick
import qs.modules.common

// A text label that scrolls to reveal its full content on hover, instead
// of just eliding with "..." and leaving the rest permanently hidden.
// Only animates when the text actually overflows its allotted width, and
// only while hovered — otherwise it just sits elided like GText normally
// would.
Item {
    id: root
    property alias text: label.text
    property alias font: label.font
    property alias color: label.color
    property alias horizontalAlignment: label.horizontalAlignment
    readonly property bool overflowing: label.implicitWidth > width
    implicitHeight: label.implicitHeight
    clip: true

    HoverHandler {
        id: hover
    }

    GText {
        id: label
        y: (root.height - height) / 2
        width: root.overflowing ? implicitWidth : root.width
        elide: root.overflowing ? Text.ElideNone : Text.ElideRight

        Behavior on x {
            enabled: !scrollAnim.running
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }
    }

    SequentialAnimation {
        id: scrollAnim
        running: root.overflowing && hover.hovered
        loops: Animation.Infinite
        onRunningChanged: if (!running) label.x = 0

        PauseAnimation { duration: 550 }
        NumberAnimation {
            target: label
            property: "x"
            to: -(label.implicitWidth - root.width)
            duration: Math.max(900, (label.implicitWidth - root.width) * 28)
            easing.type: Easing.InOutQuad
        }
        PauseAnimation { duration: 700 }
        NumberAnimation {
            target: label
            property: "x"
            to: 0
            duration: Math.max(900, (label.implicitWidth - root.width) * 28)
            easing.type: Easing.InOutQuad
        }
    }
}
