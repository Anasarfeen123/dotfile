import qs.modules.common
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls

// Glass slider: translucent glass track, filled portion tinted with the accent color,
// a small glowing handle. Simpler than the original's M3 slider (no wavy fill) but with
// its own identity via the glass track + handle glow.
Slider {
    id: root
    property list<real> stopIndicatorValues: []
    property bool usePercentTooltip: true
    property string tooltipContent: usePercentTooltip ? `${Math.round(((value - from) / (to - from)) * 100)}%` : `${Math.round(value)}`

    implicitHeight: 24
    from: 0
    to: 1
    property real wheelStep: 0.05

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            const dir = (event.angleDelta.y > 0) ? 1 : -1
            root.value = Math.max(root.from, Math.min(root.to, root.value + dir * root.wheelStep))
        }
    }

    Behavior on value {
        SmoothedAnimation { velocity: Appearance.animation.elementMoveFast.velocity }
    }

    MouseArea {
        anchors.fill: parent
        onPressed: mouse => mouse.accepted = false
        cursorShape: root.pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
    }

    background: GlassSurface {
        anchors.verticalCenter: parent.verticalCenter
        width: root.width
        implicitHeight: 8
        radius: Appearance.rounding.full
        tint: Appearance.colors.colLayer3Base
        fillOpacity: 0.4
        showSheen: false

        Rectangle { // filled portion
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: root.visualPosition * parent.width
            radius: Appearance.rounding.full
            color: Appearance.colors.colPrimary
        }

        Repeater {
            model: root.stopIndicatorValues
            Rectangle {
                required property real modelData
                property real normalized: (modelData - root.from) / (root.to - root.from)
                anchors.verticalCenter: parent.verticalCenter
                x: normalized * parent.width - width / 2
                width: 3
                height: 3
                radius: Appearance.rounding.full
                color: normalized > root.visualPosition
                    ? ColorUtils.applyAlpha(Appearance.m3colors.m3onBackground, 0.4)
                    : Appearance.colors.colOnPrimary
            }
        }
    }

    handle: Rectangle {
        id: handle
        implicitWidth: root.pressed ? 22 : 18
        implicitHeight: implicitWidth
        radius: Appearance.rounding.full
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        anchors.verticalCenter: parent.verticalCenter
        color: Appearance.colors.colPrimary
        border.width: 3
        border.color: Appearance.m3colors.m3background

        Behavior on implicitWidth {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }

        GTooltip {
            extraVisibleCondition: root.pressed
            text: root.tooltipContent
            font {
                family: Appearance.font.family.numbers
                variableAxes: Appearance.font.variableAxes.numbers
            }
        }
    }
}
