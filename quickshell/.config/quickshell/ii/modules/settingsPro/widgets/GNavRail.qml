import QtQuick
import QtQuick.Layouts
import qs.modules.common

// Glass sidebar navigation panel. Replaces NavigationRail. Animates between a narrow
// icon-only rail and a wider labeled one via the `expanded` property.
GlassPane {
    id: root
    property bool expanded: true
    property real collapsedWidth: 64
    property real expandedWidth: 196

    implicitWidth: root.expanded ? root.expandedWidth : root.collapsedWidth
    radius: Appearance.rounding.large
    fillOpacity: 0.72
    shadowBlur: 20

    Behavior on implicitWidth {
        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
    }

    default property alias contentData: railColumn.data

    ColumnLayout {
        id: railColumn
        // Exposed so children (e.g. GNavExpandButton) can reach `parent.expanded`,
        // same as they'd reach a property on their direct QML parent.
        property alias expanded: root.expanded
        anchors {
            fill: parent
            margins: 10
        }
        spacing: 4
    }
}
