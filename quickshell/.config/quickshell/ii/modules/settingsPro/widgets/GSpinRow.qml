import qs.modules.common
import QtQuick
import QtQuick.Layouts

// Icon + label + spinbox row. Replaces ConfigSpinBox.
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
        GIcon {
            visible: (root.icon ?? "").length > 0
            text: root.icon
            size: Appearance.font.pixelSize.larger
            color: Appearance.colors.colOnLayer1
            opacity: root.enabled ? 1 : 0.4
        }
        GText {
            id: labelWidget
            Layout.fillWidth: true
            text: root.text
            font.pixelSize: Appearance.font.pixelSize.normal
            opacity: root.enabled ? 1 : 0.4
            elide: Text.ElideRight
            clip: true
        }
    }

    GSpinBox {
        id: spinBoxWidget
        Layout.fillWidth: false
        value: root.value
    }
}
