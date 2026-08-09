import qs.modules.common
import QtQuick
import QtQuick.Layouts

// Info/notice callout. Replaces NoticeBox — a soft primary-tinted glass strip.
GlassSurface {
    id: root
    property alias materialIcon: icon.text
    property alias text: noticeText.text
    default property alias boxData: buttonRow.data

    tint: Appearance.colors.colPrimary
    fillOpacity: 0.16
    radius: Appearance.rounding.normal
    implicitWidth: mainRowLayout.implicitWidth + 16
    implicitHeight: mainRowLayout.implicitHeight + 16

    RowLayout {
        id: mainRowLayout
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        GIcon {
            id: icon
            Layout.alignment: Qt.AlignTop
            text: "info"
            size: Appearance.font.pixelSize.huge
            color: Appearance.colors.colPrimary
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            GText {
                id: noticeText
                Layout.fillWidth: true
                text: "Notice message"
                wrapMode: Text.WordWrap
            }

            RowLayout {
                id: buttonRow
                visible: children.length > 0
                Layout.fillWidth: true
            }
        }
    }
}
