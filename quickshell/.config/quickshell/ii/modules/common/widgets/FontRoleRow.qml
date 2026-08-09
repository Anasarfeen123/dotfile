import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.services

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 10

    property string roleName: ""
    property string roleIcon: "text_fields"
    property string roleValue: ""
    property string rolePreview: ""
    signal edited(string newValue)

    MaterialSymbol {
        text: root.roleIcon
        iconSize: Appearance.font.pixelSize.large
        color: Appearance.colors.colOnLayer2
    }
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2
        StyledText {
            text: root.roleName
            font.pixelSize: Appearance.font.pixelSize.normal
            font.weight: Font.DemiBold
            color: Appearance.colors.colOnLayer1
        }
        StyledText {
            visible: root.rolePreview.length > 0
            text: root.rolePreview
            font.family: root.roleValue
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.colOnLayer3
            elide: Text.ElideRight
        }
    }
    MaterialTextArea {
        Layout.preferredWidth: 230
        placeholderText: Translation.tr("Font family name")
        text: root.roleValue
        wrapMode: TextEdit.NoWrap
        font.pixelSize: Appearance.font.pixelSize.small
        onTextChanged: {
            if (text !== root.roleValue) root.edited(text)
        }
    }
}
