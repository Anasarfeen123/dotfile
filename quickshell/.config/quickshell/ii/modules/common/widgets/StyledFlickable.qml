import QtQuick
import QtQuick.Controls
import qs.modules.common

Flickable {
    id: root
    maximumFlickVelocity: 3500
    boundsBehavior: Flickable.DragOverBounds

    property real touchpadScrollFactor: Config?.options.interactions.scrolling.touchpadScrollFactor ?? 100
    property real mouseScrollFactor: Config?.options.interactions.scrolling.mouseScrollFactor ?? 50
    property real mouseScrollDeltaThreshold: Config?.options.interactions.scrolling.mouseScrollDeltaThreshold ?? 120
    // Accumulated scroll destination so wheel deltas stack while animating
    property real scrollTargetY: 0
    property real scrollTargetX: 0

    ScrollBar.vertical: StyledScrollBar {}

    MouseArea {
        visible: Config?.options.interactions.scrolling.fasterTouchpadScroll
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: function(wheelEvent) {
            const maxY = Math.max(0, root.contentHeight - root.height);
            const maxX = Math.max(0, root.contentWidth - root.width);
            // Was unconditional on contentY — on a Flickable with no
            // vertical scroll room but real horizontal content (e.g. the
            // cheatsheet periodic table), this computed an always-0, no-op
            // contentY and still marked the event accepted, silently
            // swallowing every wheel tick with nothing happening. A plain
            // mouse wheel has no horizontal axis of its own to send here,
            // so when there's no vertical room, the vertical delta now
            // drives contentX instead — the same "wheel scrolls whichever
            // axis actually has content" convention most horizontally
            // scrolling views (file lists, galleries) use.
            if (maxY <= 0) {
                if (maxX <= 0) {
                    wheelEvent.accepted = false;
                    return;
                }
                const deltaX = wheelEvent.angleDelta.y / root.mouseScrollDeltaThreshold;
                var scrollFactorX = Math.abs(wheelEvent.angleDelta.y) >= root.mouseScrollDeltaThreshold ? root.mouseScrollFactor : root.touchpadScrollFactor;
                const baseX = scrollAnimX.running ? root.scrollTargetX : root.contentX;
                var targetX = Math.max(0, Math.min(baseX - deltaX * scrollFactorX, maxX));
                root.scrollTargetX = targetX;
                root.contentX = targetX;
                wheelEvent.accepted = true;
                return;
            }

            const delta = wheelEvent.angleDelta.y / root.mouseScrollDeltaThreshold;
            // The angleDelta.y of a touchpad is usually small and continuous,
            // while that of a mouse wheel is typically in multiples of ±120.
            var scrollFactor = Math.abs(wheelEvent.angleDelta.y) >= root.mouseScrollDeltaThreshold ? root.mouseScrollFactor : root.touchpadScrollFactor;

            const base = scrollAnim.running ? root.scrollTargetY : root.contentY;
            var targetY = Math.max(0, Math.min(base - delta * scrollFactor, maxY));

            root.scrollTargetY = targetY;
            root.contentY = targetY;
            wheelEvent.accepted = true;
        }
    }

    Behavior on contentY {
        NumberAnimation {
            id: scrollAnim
            duration: Appearance.animation.scroll.duration
            easing.type: Appearance.animation.scroll.type
            easing.bezierCurve: Appearance.animation.scroll.bezierCurve
        }
    }

    Behavior on contentX {
        NumberAnimation {
            id: scrollAnimX
            duration: Appearance.animation.scroll.duration
            easing.type: Appearance.animation.scroll.type
            easing.bezierCurve: Appearance.animation.scroll.bezierCurve
        }
    }

    // Keep target synced when not animating (e.g., drag/flick or programmatic changes)
    onContentYChanged: {
        if (!scrollAnim.running) {
            root.scrollTargetY = root.contentY;
        }
    }
    onContentXChanged: {
        if (!scrollAnimX.running) {
            root.scrollTargetX = root.contentX;
        }
    }

}
