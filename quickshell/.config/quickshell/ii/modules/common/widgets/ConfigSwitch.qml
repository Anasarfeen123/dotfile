import qs.modules.common.widgets
import qs.modules.common
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RippleButton {
    id: root
    property string buttonIcon
    property alias iconSize: iconWidget.iconSize

    Layout.fillWidth: true
    implicitHeight: contentItem.implicitHeight + 8 * 2
    font.pixelSize: Appearance.font.pixelSize.normal

    // Row-change feedback: briefly flash the row when the value changes
    property var flashBaseValue: null
    Component.onCompleted: flashBaseValue = root.checked
    onCheckedChanged: {
        if (root.flashBaseValue === null) { root.flashBaseValue = root.checked; return }
        if (root.checked !== root.flashBaseValue) flashAnim.restart()
        root.flashBaseValue = root.checked
    }
    SequentialAnimation {
        id: flashAnim
        NumberAnimation { target: switchContent; property: "opacity"; from: 0.5; to: 1; duration: 200; easing.type: Easing.OutQuad }
    }

    onClicked: checked = !checked

    contentItem: RowLayout {
        id: switchContent
        spacing: 10
        OptionalMaterialSymbol {
            id: iconWidget
            icon: root.buttonIcon
            opacity: root.enabled ? 1 : 0.4
            iconSize: Appearance.font.pixelSize.larger
        }
        StyledText {
            id: labelWidget
            Layout.fillWidth: true
            text: root.text
            font: root.font
            color: Appearance.colors.colOnSecondaryContainer
            opacity: root.enabled ? 1 : 0.4
        }
        StyledSwitch {
            id: switchWidget
            down: root.down
            Layout.fillWidth: false
            checked: root.checked
            onClicked: root.clicked()
        }
    }
}

