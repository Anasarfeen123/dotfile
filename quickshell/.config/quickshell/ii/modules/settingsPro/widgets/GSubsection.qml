import QtQuick
import QtQuick.Layouts
import qs.modules.common

// A labeled sub-group inside a GSection. Replaces ContentSubsection.
ColumnLayout {
    id: root
    property string title: ""
    property string tooltip: ""
    default property alias contentData: sectionContent.data

    Layout.fillWidth: true
    Layout.topMargin: 4
    spacing: 6

    RowLayout {
        visible: root.title.length > 0 || root.tooltip.length > 0
        spacing: 6
        GText {
            visible: root.title.length > 0
            text: root.title
            font.pixelSize: Appearance.font.pixelSize.small
            font.weight: Font.Medium
            color: Appearance.colors.colOnLayer2
        }
        GIcon {
            visible: root.tooltip.length > 0
            text: "info"
            size: Appearance.font.pixelSize.large
            color: Appearance.colors.colOnLayer2

            MouseArea {
                id: infoMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.WhatsThisCursor
                GTooltip {
                    extraVisibleCondition: false
                    alternativeVisibleCondition: infoMouseArea.containsMouse
                    text: root.tooltip
                }
            }
        }
        Item { Layout.fillWidth: true }
    }

    ColumnLayout {
        id: sectionContent
        Layout.fillWidth: true
        spacing: 4
    }
}
