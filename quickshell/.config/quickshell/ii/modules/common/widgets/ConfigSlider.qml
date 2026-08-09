import qs.modules.common.widgets
import qs.modules.common
import QtQuick
import QtQuick.Layouts
import qs.services

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
        NumberAnimation { target: row; property: "opacity"; from: 0.6; to: 1; duration: 200; easing.type: Easing.OutQuad }
    }

    opacity: root.enabled ? 1 : 0.45
    Behavior on opacity {
        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
    }

    RowLayout {
        id: row
        spacing: 10
        implicitWidth: rowIcon.implicitWidth + rowLabel.implicitWidth + 10

        OptionalMaterialSymbol {
            id: rowIcon
            icon: root.buttonIcon
            iconSize: Appearance.font.pixelSize.larger
        }
        StyledText {
            id: rowLabel
            visible: root.text.length > 0
            Layout.maximumWidth: root.textWidth
            text: root.text
            color: Appearance.colors.colOnSecondaryContainer
            font.pixelSize: Appearance.font.pixelSize.normal
            font.weight: Font.Normal
            elide: Text.ElideRight
            clip: true
        }
    }
    
    StyledSlider {
        id: slider
        Layout.fillWidth: true
        configuration: StyledSlider.Configuration.XS
        usePercentTooltip: root.usePercentTooltip
        value: root.value
        from: root.from
        to: root.to
        stepSize: root.stepSize
        enabled: root.enabled
    }
}