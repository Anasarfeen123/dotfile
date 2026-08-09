import qs.modules.common
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls

// Glass spin box: a rounded glass pill with a numeric field flanked by +/- glass buttons.
SpinBox {
    id: root
    property real baseHeight: 34
    editable: true
    opacity: root.enabled ? 1 : 0.4

    background: GlassSurface {
        radius: Appearance.rounding.full
        fillOpacity: 0.4
        showSheen: false
    }

    contentItem: Item {
        implicitHeight: root.baseHeight
        implicitWidth: Math.max(labelText.implicitWidth + 8, 32)

        TextInput {
            id: labelText
            anchors.centerIn: parent
            text: root.value
            color: Appearance.colors.colOnLayer1
            font.family: Appearance.font.family.numbers
            font.variableAxes: Appearance.font.variableAxes.numbers
            font.pixelSize: Appearance.font.pixelSize.small
            horizontalAlignment: Text.AlignHCenter
            selectByMouse: true
            validator: root.validator
            onTextChanged: root.value = parseFloat(text) || 0
        }
    }

    down.indicator: Rectangle {
        anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 3 }
        implicitHeight: root.baseHeight - 6
        implicitWidth: root.baseHeight - 6
        radius: Appearance.rounding.full
        color: root.down.pressed ? ColorUtils.applyAlpha(Appearance.m3colors.m3onBackground, 0.18)
            : root.down.hovered ? ColorUtils.applyAlpha(Appearance.m3colors.m3onBackground, 0.10) : "transparent"
        Behavior on color { animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this) }
        GIcon { anchors.centerIn: parent; text: "remove"; size: 16; color: Appearance.colors.colOnLayer1 }
    }

    up.indicator: Rectangle {
        anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 3 }
        implicitHeight: root.baseHeight - 6
        implicitWidth: root.baseHeight - 6
        radius: Appearance.rounding.full
        color: root.up.pressed ? ColorUtils.applyAlpha(Appearance.m3colors.m3onBackground, 0.18)
            : root.up.hovered ? ColorUtils.applyAlpha(Appearance.m3colors.m3onBackground, 0.10) : "transparent"
        Behavior on color { animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this) }
        GIcon { anchors.centerIn: parent; text: "add"; size: 16; color: Appearance.colors.colOnLayer1 }
    }
}
