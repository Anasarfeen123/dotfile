import QtQuick
import qs.modules.common

// Base text primitive for the glass settings app.
Text {
    id: root
    property bool numeric: /^-?\d+(\.\d+)?%?$/.test(root.text)

    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    font {
        hintingPreference: Font.PreferDefaultHinting
        family: root.numeric ? Appearance.font.family.numbers : Appearance.font.family.main
        pixelSize: Appearance.font.pixelSize.small
        variableAxes: root.numeric ? ({}) : Appearance.font.variableAxes.main
    }
    color: Appearance.colors.colOnLayer1
    linkColor: Appearance.colors.colPrimary

    Behavior on color {
        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
    }
}
