import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.functions

// A settings section: a glass card with an icon+title header and a content column.
// Replaces ContentSection — the fresh part is that each section is now its own frosted
// card (visual grouping) instead of a flat heading + rows sitting directly on the page.
ColumnLayout {
    id: root
    property string title
    property string icon: ""
    property string key: "" // Stable identifier used by settings search/section navigation
    property bool isSettingsSection: true
    default property alias contentData: sectionContent.data

    Layout.fillWidth: true
    spacing: 0

    GlassPane {
        Layout.fillWidth: true
        Layout.preferredHeight: innerCol.implicitHeight + 32
        radius: Appearance.rounding.large
        fillOpacity: 0.55
        tint: Appearance.colors.colLayer2Base
        shadowBlur: 18

        ColumnLayout {
            id: innerCol
            anchors {
                fill: parent
                margins: 16
            }
            spacing: 14

            RowLayout {
                spacing: 12
                Rectangle {
                    visible: root.icon.length > 0
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: Appearance.rounding.small
                    color: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.22)
                    GIcon {
                        anchors.centerIn: parent
                        text: root.icon
                        size: Appearance.font.pixelSize.huge
                        color: Appearance.colors.colPrimary
                    }
                }
                GText {
                    Layout.fillWidth: true
                    text: root.title
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colOnLayer1
                    elide: Text.ElideRight
                }
            }

            ColumnLayout {
                id: sectionContent
                Layout.fillWidth: true
                spacing: 10
            }
        }
    }
}
