import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root
    property string title
    property string icon: ""
    property string key: "" // Stable identifier used by settings search/section navigation
    property bool isSettingsSection: true
    default property alias contentData: sectionContent.data

    Layout.fillWidth: true
    spacing: 12

    RowLayout {
        spacing: 10
        OptionalMaterialSymbol {
            icon: root.icon
            iconSize: Appearance.font.pixelSize.hugeass
        }
        StyledText {
            Layout.fillWidth: true
            text: root.title
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.Medium
            color: Appearance.colors.colOnSecondaryContainer
            elide: Text.ElideRight
            clip: false
        }
    }

    ColumnLayout {
        id: sectionContent
        Layout.fillWidth: true
        Layout.topMargin: 2
        spacing: 8

    }
}
