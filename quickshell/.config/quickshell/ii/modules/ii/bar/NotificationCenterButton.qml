import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts
import Quickshell

RippleButton {
    id: root
    implicitWidth: 32
    implicitHeight: 32
    buttonRadius: Appearance.rounding.full
    colBackground: ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)
    colBackgroundHover: Appearance.colors.colLayer1Hover
    colBackgroundToggled: Appearance.colors.colSecondaryContainer
    colBackgroundToggledHover: Appearance.colors.colSecondaryContainerHover
    toggled: GlobalStates.notifCenterOpen

    onClicked: {
        GlobalStates.notifCenterOpen = !GlobalStates.notifCenterOpen;
        Notifications.timeoutAll();
        Notifications.markAllRead();
    }
    middleClickAction: () => {
        Notifications.silent = !Notifications.silent;
    }

    MaterialSymbol {
        id: bellIcon
        anchors.centerIn: parent
        text: Notifications.silent ? "notifications_paused" : "notifications"
        iconSize: Appearance.font.pixelSize.large
        color: root.toggled ? Appearance.m3colors.m3onSecondaryContainer : Appearance.colors.colOnLayer0
    }

    Rectangle { // Unread dot
        visible: !Notifications.silent && Notifications.unread > 0
        anchors {
            top: bellIcon.top
            right: bellIcon.right
            topMargin: -2
            rightMargin: -3
        }
        implicitWidth: unreadText.implicitWidth + 8
        implicitHeight: Math.max(14, unreadText.implicitHeight + 4)
        radius: height / 2
        color: Appearance.colors.colPrimary
        z: 1
        StyledText {
            id: unreadText
            anchors.centerIn: parent
            text: Notifications.unread
            font.pixelSize: Appearance.font.pixelSize.smallest
            font.weight: Font.DemiBold
            color: Appearance.m3colors.m3onPrimary
        }
    }

    PopupToolTip {
        text: Notifications.silent
            ? Translation.tr("Notifications paused\nLeft: open center | Middle: resume")
            : Translation.tr("Notifications\nLeft: open center | Middle: pause")
        anchorEdges: (!Config.options.bar.bottom && !Config.options.bar.vertical) ? Edges.Bottom : Edges.Top
    }
}
