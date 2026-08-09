import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

/**
 * Material 3 expressive style toolbar.
 * https://m3.material.io/components/toolbars
 */
Item {
    id: root

    property bool enableShadow: true
    property bool glass: false
    property real padding: 8
    property alias colBackground: background.color
    property alias spacing: toolbarLayout.spacing
    default property alias toolbarData: toolbarLayout.data
    implicitWidth: background.implicitWidth
    implicitHeight: background.implicitHeight
    property alias radius: background.radius

    Loader {
        active: root.enableShadow
        anchors.fill: background
        sourceComponent: StyledRectangularShadow {
            target: background
            anchors.fill: undefined
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: root.glass ? ColorUtils.applyAlpha(Appearance.colors.colLayer1Base, 0.38) : Appearance.m3colors.m3surfaceContainer
        implicitHeight: 56
        implicitWidth: toolbarLayout.implicitWidth + root.padding * 2
        radius: height / 2
        clip: true
        border.width: root.glass ? 1 : 0
        border.color: root.glass ? Appearance.colors.colLayer0Border : "transparent"

        RowLayout {
            id: toolbarLayout
            spacing: 4
            anchors {
                fill: parent
                margins: root.padding
            }
        }
    }
}
