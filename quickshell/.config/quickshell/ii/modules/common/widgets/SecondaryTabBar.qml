import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.models
import qs.modules.common.functions

TabBar {
    id: root
    property real indicatorPadding: 8
    Layout.fillWidth: true

    // Geometry of the current tab button (handles variable-width tabs).
    // `itemAt()` is Container's own documented lookup — reaching into
    // contentItem.children[index] instead (the old approach) assumes
    // delegate order in the content view's children list matches model
    // index, which isn't guaranteed and was why the indicator only ever
    // lined up for index 0 and covered the wrong span everywhere else.
    readonly property real currentTabX: {
        const btn = root.itemAt(root.currentIndex)
        return btn ? btn.x : 0
    }
    readonly property real currentTabWidth: {
        const btn = root.itemAt(root.currentIndex)
        return btn ? btn.width : 0
    }

    background: Item {
        WheelHandler {
            onWheel: (event) => {
                if (event.angleDelta.y < 0) root.incrementCurrentIndex();
                else if (event.angleDelta.y > 0) root.decrementCurrentIndex();
            }
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        }

        // Soft filled pill riding behind the active tab. Shares the same
        // currentTabX/currentTabWidth target as the underline below, but
        // moves on the slower/softer spatial curve while the underline uses
        // the fast, punchier one — the underline snaps into place first and
        // the glow catches up a beat behind it, instead of both just
        // teleporting together.
        // Inset well clear of the bottom so it never crowds the underline —
        // they're two distinct bands (pill = tab body, underline = accent
        // stripe), not one smear.
        Rectangle {
            id: activePill
            z: 9997
            anchors {
                top: parent.top
                bottom: parent.bottom
                topMargin: 4
                bottomMargin: 9
            }
            radius: Appearance.rounding.normal
            color: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.12)
            x: root.currentTabX + root.indicatorPadding
            width: Math.max(0, root.currentTabWidth - root.indicatorPadding * 2)

            Behavior on x {
                NumberAnimation {
                    duration: Appearance.animationCurves.expressiveDefaultSpatialDuration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.animationCurves.expressiveDefaultSpatial
                }
            }
            Behavior on width {
                NumberAnimation {
                    duration: Appearance.animationCurves.expressiveDefaultSpatialDuration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.animationCurves.expressiveDefaultSpatial
                }
            }
        }

        Rectangle {
            id: activeIndicator
            z: 9999
            anchors.bottom: parent.bottom
            topLeftRadius: height
            topRightRadius: height
            bottomLeftRadius: 0
            bottomRightRadius: 0
            color: Appearance.colors.colPrimary
            height: 3
            x: root.currentTabX + root.indicatorPadding
            width: Math.max(0, root.currentTabWidth - root.indicatorPadding * 2)

            Behavior on x {
                NumberAnimation {
                    duration: Appearance.animationCurves.expressiveFastSpatialDuration
                    easing.type: Appearance.animation.elementMove.type
                    easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
                }
            }
            Behavior on width {
                NumberAnimation {
                    duration: Appearance.animationCurves.expressiveFastSpatialDuration
                    easing.type: Appearance.animation.elementMove.type
                    easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
                }
            }
        }

        Rectangle { // Tabbar bottom border
            id: tabBarBottomBorder
            z: 9998
            anchors.bottom: parent.bottom
            height: 1
            anchors {
                left: parent.left
                right: parent.right
            }
            color: Appearance.colors.colOutlineVariant
        }
    }
}
