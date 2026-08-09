import qs.modules.common
import QtQuick

// A single line of text that ping-pong scrolls (reveal end -> pause ->
// scroll back -> pause -> repeat) when it's wider than the space given to
// it, instead of just eliding with "...". Sits still and behaves like a
// normal StyledText when the text fits.
Item {
    id: root

    property alias text: label.text
    property alias font: label.font
    property alias color: label.color
    property alias horizontalAlignment: label.horizontalAlignment

    // How long the text sits fully visible at each end before scrolling.
    property int pauseDuration: 1200
    // Scroll speed, used to derive a duration proportional to how far it
    // has to travel rather than a fixed one (a barely-overflowing title
    // and a wildly long one shouldn't scroll at the same speed).
    property real pixelsPerSecond: 32

    readonly property real overflowBy: Math.max(0, label.implicitWidth - root.width)
    readonly property bool overflowing: overflowBy > 0

    clip: true
    implicitHeight: label.implicitHeight

    onTextChanged: scroller.x = 0
    onOverflowingChanged: if (!overflowing) scroller.x = 0

    Item {
        id: scroller
        height: parent.height
        width: label.implicitWidth

        StyledText {
            id: label
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    SequentialAnimation {
        running: root.overflowing && root.visible
        loops: Animation.Infinite

        PauseAnimation { duration: root.pauseDuration }
        NumberAnimation {
            target: scroller
            property: "x"
            to: -root.overflowBy
            duration: Math.max(400, root.overflowBy / root.pixelsPerSecond * 1000)
            easing.type: Easing.InOutQuad
        }
        PauseAnimation { duration: root.pauseDuration }
        NumberAnimation {
            target: scroller
            property: "x"
            to: 0
            duration: Math.max(400, root.overflowBy / root.pixelsPerSecond * 1000)
            easing.type: Easing.InOutQuad
        }
    }
}
