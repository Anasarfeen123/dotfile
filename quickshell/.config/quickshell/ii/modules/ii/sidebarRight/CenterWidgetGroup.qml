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
