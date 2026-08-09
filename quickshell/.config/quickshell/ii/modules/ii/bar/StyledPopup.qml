import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

LazyLoader {
    id: root

    property Item hoverTarget
    default property Item contentItem
    property real popupBackgroundMargin: 0

    readonly property bool wantsOpen: hoverTarget && hoverTarget.containsMouse
    // Kept active a little past mouse-leave so the exit animation below
    // has time to finish before the window actually gets torn down.
    property bool closing: false
    active: wantsOpen || closing

    onWantsOpenChanged: {
        closeTimer.stop();
        if (wantsOpen) {
            closing = false;
            if (item) item.beginOpen();
        } else if (item) {
            closing = true;
            item.beginClose();
            closeTimer.start();
        }
    }

    Timer {
        id: closeTimer
        interval: Appearance.animation.elementMoveExit.duration + 20
        onTriggered: root.closing = false
    }

    component: PanelWindow {
        id: popupWindow
        color: "transparent"

        anchors.left: !Config.options.bar.vertical || (Config.options.bar.vertical && !Config.options.bar.bottom)
        anchors.right: Config.options.bar.vertical && Config.options.bar.bottom
        anchors.top: Config.options.bar.vertical || (!Config.options.bar.vertical && !Config.options.bar.bottom)
        anchors.bottom: !Config.options.bar.vertical && Config.options.bar.bottom

        implicitWidth: popupBackground.implicitWidth + Appearance.sizes.elevationMargin * 2 + root.popupBackgroundMargin
        implicitHeight: popupBackground.implicitHeight + Appearance.sizes.elevationMargin * 2 + root.popupBackgroundMargin

        mask: Region {
            item: popupBackground
        }

        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0
        margins {
            left: {
                if (!Config.options.bar.vertical) return root.QsWindow?.mapFromItem(
                    root.hoverTarget,
                    (root.hoverTarget.width - popupBackground.implicitWidth) / 2, 0
                ).x;
                return Appearance.sizes.verticalBarWidth
            }
            top: {
                if (!Config.options.bar.vertical) return Appearance.sizes.barHeight;
                return root.QsWindow?.mapFromItem(
                    root.hoverTarget,
                    (root.hoverTarget.height - popupBackground.implicitHeight) / 2, 0
                ).y;
            }
            right: Appearance.sizes.verticalBarWidth
            bottom: Appearance.sizes.barHeight
        }
        WlrLayershell.namespace: "quickshell:popup"
        WlrLayershell.layer: WlrLayer.Overlay

        // Grow out of / shrink back into whichever edge is closest to the
        // bar, rather than a generic center pop.
        readonly property int growEdge: Config.options.bar.vertical
            ? (Config.options.bar.bottom ? Item.Right : Item.Left)
            : (Config.options.bar.bottom ? Item.Bottom : Item.Top)

        function beginOpen() { popupBackground.shown = true; }
        function beginClose() { popupBackground.shown = false; }

        StyledRectangularShadow {
            target: popupBackground
            opacity: popupBackground.opacity
        }

        Rectangle {
            id: popupBackground
            readonly property real margin: 10
            // Starts closed; Component.onCompleted flips it, which is what
            // actually triggers the enter Behavior below (a value that's
            // already true at creation time never animates).
            property bool shown: false

            anchors {
                fill: parent
                leftMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.left)
                rightMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.right)
                topMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.top)
                bottomMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.bottom)
            }
            implicitWidth: root.contentItem.implicitWidth + margin * 2
            implicitHeight: root.contentItem.implicitHeight + margin * 2
            color: Appearance.m3colors.m3surfaceContainer
            radius: Appearance.rounding.small
            children: [root.contentItem]

            border.width: 1
            border.color: Appearance.colors.colLayer0Border

            opacity: shown ? 1 : 0
            scale: shown ? 1 : 0.85
            transformOrigin: popupWindow.growEdge

            Behavior on opacity {
                NumberAnimation {
                    duration: popupBackground.shown ? Appearance.animation.elementMoveEnter.duration : Appearance.animation.elementMoveExit.duration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: popupBackground.shown ? Appearance.animationCurves.emphasizedDecel : Appearance.animationCurves.emphasizedAccel
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: popupBackground.shown ? Appearance.animation.elementMoveEnter.duration : Appearance.animation.elementMoveExit.duration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: popupBackground.shown ? Appearance.animationCurves.emphasizedDecel : Appearance.animationCurves.emphasizedAccel
                }
            }

            Component.onCompleted: shown = true
        }
    }
}
