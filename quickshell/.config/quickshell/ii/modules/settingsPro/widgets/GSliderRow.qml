import qs.modules.common
import QtQuick
import QtQuick.Layouts

// Icon + label + slider row. Replaces ConfigSlider.
RowLayout {
    id: root
    spacing: 10
    Layout.leftMargin: 8
    Layout.rightMargin: 8

    property string text: ""
    property string buttonIcon: ""
    property alias value: slider.value
    property alias stopIndicatorValues: slider.stopIndicatorValues
    property bool usePercentTooltip: true
    property real from: slider.from
    property real to: slider.to
    property real stepSize: 0
    property real textWidth: 120

    property var flashBaseValue: null
    Component.onCompleted: flashBaseValue = root.value
    onValueChanged: {
        if (root.flashBaseValue === null) { root.flashBaseValue = root.value; return }
        if (root.value !== root.flashBaseValue) flashAnim.restart()
        root.flashBaseValue = root.value
    }
    SequentialAnimation {
        id: flashAnim
        NumberAnimation { target: labelRow; property: "opacity"; from: 0.6; to: 1; duration: 200; easing.type: Easing.OutQuad }
    }

    opacity: root.enabled ? 1 : 0.45
    Behavior on opacity {
        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
    }

    RowLayout {
        id: labelRow
        spacing: 10
        implicitWidth: rowIcon.implicitWidth + rowLabel.implicitWidth + 10

        GIcon {
            id: rowIcon
            visible: root.buttonIcon.length > 0
            text: root.buttonIcon
            size: Appearance.font.pixelSize.larger
            color: Appearance.colors.colOnLayer1
        }
        GText {
            id: rowLabel
            visible: root.text.length > 0
            Layout.maximumWidth: root.textWidth
            text: root.text
            font.pixelSize: Appearance.font.pixelSize.normal
            elide: Text.ElideRight
            clip: true
        }
    }

    GSlider {
        id: slider
        Layout.fillWidth: true
        usePercentTooltip: root.usePercentTooltip
        value: root.value
        from: root.from
        to: root.to
        stepSize: root.stepSize
        enabled: root.enabled
    }
}
