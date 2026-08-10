import QtQuick
import QtQuick.Layouts
import qs.modules.common

// Segmented chip group. Replaces ConfigSelectionArray — each option is a small glass
// chip that fills solid-accent when selected.
Flow {
    id: root
    Layout.fillWidth: true
    spacing: 6
    property list<var> options: [] // [{ displayName, icon, value }]
    property var currentValue: null

    signal selected(var newValue)

    Repeater {
        model: root.options
        delegate: GButton {
            id: optionButton
            required property var modelData
            buttonIcon: modelData.icon || ""
            buttonText: modelData.displayName || ""
            textFontFamily: modelData.fontFamily || Appearance.font.family.main
            textPixelSize: modelData.pixelSize || Appearance.font.pixelSize.small
            toggled: root.currentValue == modelData.value
            primary: toggled
            buttonRadius: Appearance.rounding.full
            implicitHeight: 32
            onClicked: root.selected(modelData.value)
        }
    }
}
