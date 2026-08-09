import qs.modules.common
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls

// Glass pill switch. Track is a translucent glass strip; thumb is a solid glowing dot.
Switch {
    id: root
    property real scale2: 0.8
    implicitWidth: 46 * root.scale2
    implicitHeight: 26 * root.scale2

    HoverHandler { id: hover }

    background: GlassSurface {
        anchors.fill: parent
        radius: Appearance.rounding.full
        tint: root.checked ? Appearance.colors.colPrimary : Appearance.colors.colLayer3Base
        fillOpacity: root.checked ? 0.85 : 0.4
        showSheen: false
        border.color: root.checked
            ? ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.6)
            : ColorUtils.applyAlpha(Appearance.m3colors.m3onBackground, 0.14)

        Behavior on fillOpacity { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }
        Behavior on border.color { animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this) }
        Behavior on tint { animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this) }
    }

    indicator: Rectangle {
        width: (root.pressed || root.down) ? (22 * root.scale2) : (18 * root.scale2)
        height: width
        radius: Appearance.rounding.full
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: root.checked
            ? (parent.width - width - 3 * root.scale2)
            : (3 * root.scale2)
        color: root.checked ? Appearance.colors.colOnPrimary : Appearance.m3colors.m3onSurfaceVariant

        Behavior on anchors.leftMargin {
            NumberAnimation {
                duration: Appearance.animationCurves.expressiveFastSpatialDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
            }
        }
        Behavior on width { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }
        Behavior on color { animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this) }
    }
}
