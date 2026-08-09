import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs.modules.ii.sidebarRight.notifications
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    spacing: 10

    RowLayout { // Compact header, matching BottomWidgetGroup's tab pages
        Layout.fillWidth: true
        spacing: 6

        MaterialSymbol {
            text: "notifications"
            iconSize: 16
            color: Appearance.colors.colPrimary
        }
        StyledText {
            Layout.fillWidth: true
            text: Translation.tr("Notifications")
            font.pixelSize: Appearance.font.pixelSize.small
            font.weight: Font.DemiBold
            color: Appearance.colors.colOnLayer1
        }
    }

    StyledGlassSurface {
        Layout.fillWidth: true
        Layout.fillHeight: true
        fillOpacity: 0.38

        NotificationList {
            anchors.fill: parent
            anchors.margins: 5
        }
    }
}
