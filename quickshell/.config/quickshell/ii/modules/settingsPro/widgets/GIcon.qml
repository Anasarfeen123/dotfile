import QtQuick
import qs.modules.common

// Material Symbols glyph. Thin technical wrapper around the icon font — same technique
// the rest of the shell uses (there's no other way to draw these glyphs), new component.
Text {
    id: root
    property real size: Appearance.font.pixelSize.normal
    property real fill: 0
    property real truncatedFill: fill.toFixed(1)

    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
    font {
        hintingPreference: Font.PreferNoHinting
        family: Appearance.font.family.iconMaterial
        pixelSize: root.size
        weight: Font.Normal + (Font.DemiBold - Font.Normal) * truncatedFill
        variableAxes: {
            "FILL": truncatedFill,
            "opsz": root.size,
        }
    }

    Behavior on fill {
        NumberAnimation {
            duration: Appearance.animation.elementMoveFast.duration
            easing.type: Appearance.animation.elementMoveFast.type
            easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
        }
    }
}
