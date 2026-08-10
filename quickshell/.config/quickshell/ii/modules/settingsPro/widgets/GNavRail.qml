import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.functions

// Glass sidebar navigation panel. Replaces NavigationRail. Animates between a narrow
// icon-only rail and a wider labeled one via the `expanded` property.
GlassPane {
    id: root
    property bool expanded: true
    property real collapsedWidth: 66
    property real expandedWidth: 224

    implicitWidth: root.expanded ? root.expandedWidth : root.collapsedWidth
    radius: Appearance.rounding.verylarge
    fillOpacity: 0.7
    tint: ColorUtils.mix(Appearance.colors.colLayer0Base, Appearance.colors.colPrimary, 0.96)
    showBorder: false
    shadowBlur: 30
    glowTint: Appearance.colors.colPrimary
    glowStrength: 0.08

    Behavior on implicitWidth {
        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
    }
    Behavior on fillOpacity {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
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
        spacing: 6
    }
}
