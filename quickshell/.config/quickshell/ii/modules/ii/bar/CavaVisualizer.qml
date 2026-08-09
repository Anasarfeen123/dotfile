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
    implicitWidth: totalWidth + 8
    implicitHeight: 22
    width: implicitWidth
    height: implicitHeight
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    Layout.alignment: Qt.AlignVCenter

    function barX(i) {
        if (i < root.half) return root.center - (root.half - i) * root.step;
        return root.center + (i - root.half) * root.step + root.barSpacing;
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

                Behavior on height {
                    NumberAnimation { duration: 60; easing.type: Easing.OutQuad }
                }
                Behavior on color {
                    ColorAnimation { duration: 60 }
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
