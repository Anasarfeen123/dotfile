import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common

// A font-role row: icon + name + live preview + editable font-family field.
RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 10

    property string roleName: ""
    property string roleIcon: "text_fields"
    property string roleValue: ""
    property string rolePreview: ""
    signal edited(string newValue)

    GIcon { text: root.roleIcon; size: Appearance.font.pixelSize.large; color: Appearance.colors.colOnLayer2 }
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2
        GText { text: root.roleName; font.pixelSize: Appearance.font.pixelSize.normal; font.weight: Font.DemiBold }
        GText {
            visible: root.rolePreview.length > 0
            text: root.rolePreview
            font.family: root.roleValue
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.colOnLayer2
            elide: Text.ElideRight
        }
    }
    GTextField {
        Layout.preferredWidth: 230
        placeholderText: Translation.tr("Font family name")
        text: root.roleValue
        font.pixelSize: Appearance.font.pixelSize.small
        onTextChanged: if (text !== root.roleValue) root.edited(text)
    }
}
