import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.models

TabBar {
    id: root
    property real indicatorPadding: 8
    Layout.fillWidth: true

    // Geometry of the current tab button (handles variable-width tabs)
    readonly property real currentTabX: {
        const c = root.contentItem
        const btn = c && c.children && c.children.length > 0 ? c.children[root.currentIndex] : null
        return btn ? btn.x : 0
    }
    readonly property real currentTabWidth: {
        const c = root.contentItem
        const btn = c && c.children && c.children.length > 0 ? c.children[root.currentIndex] : null
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
