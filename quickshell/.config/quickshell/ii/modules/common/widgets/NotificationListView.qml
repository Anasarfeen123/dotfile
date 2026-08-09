pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import Quickshell

StyledListView { // Scrollable window
    id: root
    property bool popup: false

    spacing: 3

    // A popup notification arriving should read as sliding in from the
    // screen edge it's anchored to (it already slides back out that way on
    // dismiss/timeout — see StyledListView's remove transition), not just
    // fading/popping in place. No-op (x: 0 -> 0) for the non-popup list in
    // the sidebar/notification center, which keeps the inherited pop-in.
    add: Transition {
        animations: root.animateAppearance ? [
            Appearance.animation.elementMoveEnter.numberAnimation.createObject(this, {
                properties: root.popin ? "opacity,scale" : "opacity",
                from: 0,
                to: 1,
            }),
            Appearance.animation.elementMoveEnter.numberAnimation.createObject(this, {
                property: "x",
                from: root.popup ? 48 : 0,
                to: 0,
            }),
        ] : []
    }

    model: ScriptModel {
        values: root.popup ? Notifications.popupAppNameList : Notifications.appNameList
    }
    delegate: NotificationGroup {
        required property int index
        required property var modelData
        popup: root.popup
        width: ListView.view.width // https://doc.qt.io/qt-6/qml-qtquick-listview.html
        notificationGroup: popup ?
            Notifications.popupGroupsByAppName[modelData] :
            Notifications.groupsByAppName[modelData]
    }
}
