import qs.modules.common
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls

// Glass text field: a translucent glass pill, no Material outline.
TextField {
    id: root
    implicitHeight: 38
    renderType: Text.QtRendering
    selectedTextColor: Appearance.colors.colOnSecondaryContainer
    selectionColor: Appearance.colors.colSecondaryContainer
    placeholderTextColor: ColorUtils.applyAlpha(Appearance.m3colors.m3onBackground, 0.5)
    color: Appearance.colors.colOnLayer1
    clip: true
    leftPadding: 14
    rightPadding: 14

    font {
        family: Appearance.font.family.main
        pixelSize: Appearance.font.pixelSize.small
        hintingPreference: Font.PreferFullHinting
        variableAxes: Appearance.font.variableAxes.main
    }

    background: GlassSurface {
        radius: Appearance.rounding.full
        fillOpacity: root.activeFocus ? 0.55 : 0.35
        showSheen: false
        border.color: root.activeFocus
            ? ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.5)
            : ColorUtils.applyAlpha(Appearance.m3colors.m3onBackground, 0.1)
        Behavior on fillOpacity { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }
        Behavior on border.color { animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this) }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: true
        cursorShape: Qt.IBeamCursor
    }
}
