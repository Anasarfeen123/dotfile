import qs.modules.common.widgets
import qs.modules.common
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    property string text: ""
    property string icon
    property alias value: spinBoxWidget.value
    property alias stepSize: spinBoxWidget.stepSize
    property alias from: spinBoxWidget.from
    property alias to: spinBoxWidget.to
    spacing: 10
    Layout.leftMargin: 8
    Layout.rightMargin: 8

    // Row-change feedback: briefly flash the row when the value changes
    property var flashBaseValue: null
    Component.onCompleted: flashBaseValue = root.value
    onValueChanged: {
        if (root.flashBaseValue === null) { root.flashBaseValue = root.value; return }
        if (root.value !== root.flashBaseValue) flashAnim.restart()
        root.flashBaseValue = root.value
    }
    SequentialAnimation {
        id: flashAnim
        NumberAnimation { target: spinContent; property: "opacity"; from: 0.6; to: 1; duration: 200; easing.type: Easing.OutQuad }
    }

    RowLayout {
        id: spinContent
        spacing: 10
        OptionalMaterialSymbol {
            icon: root.icon
            opacity: root.enabled ? 1 : 0.4
        }
        StyledText {
            id: labelWidget
            Layout.fillWidth: true
            text: root.text
            color: Appearance.colors.colOnSecondaryContainer
            font.pixelSize: Appearance.font.pixelSize.normal
            font.weight: Font.Normal
            opacity: root.enabled ? 1 : 0.4
            elide: Text.ElideRight
            clip: true
        }
    }

    StyledSpinBox {
        id: spinBoxWidget
        Layout.fillWidth: false
        value: root.value
    }
}
