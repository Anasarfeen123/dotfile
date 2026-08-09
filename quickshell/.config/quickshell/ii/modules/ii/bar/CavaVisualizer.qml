import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.functions

Item {
    id: root
    property var barValues: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    property int maxRange: 20
    property int barCount: 14
    readonly property real barWidth: 3
    readonly property real barSpacing: 2
    readonly property real step: barWidth + barSpacing
    readonly property int half: barCount / 2
    readonly property real totalWidth: barCount * step - barSpacing
    readonly property real center: totalWidth / 2
    // Set by BarContent while the Resources (system usage) widget is
    // hovered and expanding inline, so the two never overlap: this
    // collapses out of the way instead of fighting it for space.
    property bool collapsed: false
    implicitWidth: totalWidth + 8
    implicitHeight: 22
    width: implicitWidth
    height: implicitHeight
    clip: true
    Layout.preferredWidth: collapsed ? 0 : implicitWidth
    Layout.preferredHeight: implicitHeight
    Layout.alignment: Qt.AlignVCenter
    opacity: collapsed ? 0 : 1

    // Snappy/decisive on the way out, a touch slower and springier coming
    // back — same motion tokens used everywhere else, just applied
    // asymmetrically so the collapse feels intentional rather than a
    // generic fade both ways.
    Behavior on Layout.preferredWidth {
        NumberAnimation {
            duration: root.collapsed ? Appearance.animation.elementMoveExit.duration : Appearance.animation.elementMove.duration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.collapsed ? Appearance.animation.elementMoveExit.bezierCurve : Appearance.animation.elementMove.bezierCurve
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: root.collapsed ? Appearance.animation.elementMoveExit.duration : Appearance.animation.elementMove.duration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.collapsed ? Appearance.animation.elementMoveExit.bezierCurve : Appearance.animation.elementMove.bezierCurve
        }
    }

    function barX(i) {
        if (i < root.half) return root.center - (root.half - i) * root.step;
        return root.center + (i - root.half) * root.step + root.barSpacing;
    }

    // Distance of bar `i` from the visual center line, used to stagger the
    // per-bar collapse below: closing sweeps outside-in (edges fold first,
    // like a curtain), opening blooms center-out.
    function staggerDelay(i) {
        const dist = Math.abs(i - (root.half - 0.5));       // 0.5 (center) .. half-0.5 (edge)
        const maxDist = root.half - 0.5;
        return (root.collapsed ? dist : (maxDist - dist)) * 9;
    }

    function colorFor(value, barIndex) {
        const t = Math.min(1, value / root.maxRange);
        const low = Appearance.colors.colPrimary;
        const high = Appearance.colors.colTertiary;
        return Qt.rgba(
            low.r + (high.r - low.r) * t,
            low.g + (high.g - low.g) * t,
            low.b + (high.b - low.b) * t,
            0.45 + 0.55 * t
        );
    }

    Item {
        id: barsHost
        width: root.totalWidth
        height: root.implicitHeight
        anchors.centerIn: parent

        Repeater {
            model: root.barCount
            Rectangle {
                required property int index
                readonly property real value: (root.barValues && root.barValues.length > index) ? root.barValues[index] : 0
                width: root.barWidth
                radius: root.barWidth / 2
                color: root.colorFor(value, index)
                x: root.barX(index)
                y: barsHost.height - height
                height: Math.max(2, (value / root.maxRange) * barsHost.height)

                // Collapse is done via `scale`, kept fully separate from the
                // live audio-driven `height` above, so folding away for the
                // resources widget never touches the snappy per-frame bounce.
                transformOrigin: Item.Bottom
                scale: root.collapsed ? 0.15 : 1

                Behavior on height {
                    NumberAnimation { duration: 60; easing.type: Easing.OutQuad }
                }
                Behavior on color {
                    ColorAnimation { duration: 60 }
                }
                Behavior on scale {
                    SequentialAnimation {
                        PauseAnimation { duration: root.staggerDelay(index) }
                        NumberAnimation {
                            duration: root.collapsed ? 110 : 200
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: root.collapsed ? Appearance.animation.elementMoveExit.bezierCurve : Appearance.animation.elementMove.bezierCurve
                        }
                    }
                }
            }
        }

        Rectangle { // Center ground line
            width: 2
            height: root.implicitHeight
            radius: 1
            anchors.horizontalCenter: parent.horizontalCenter
            color: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.35)
        }
    }

    Process {
        id: cavaProc
        command: ["cava", "-p", "/home/anasa/.config/cava/config_qs"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const nums = data.trim().split(/\s+/).map(Number)
                if (nums.length >= root.barCount) {
                    root.barValues = nums
                }
            }
        }
    }
}
