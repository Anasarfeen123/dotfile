import qs.modules.common
import qs.modules.common.functions
import QtQuick

// Keyboard key glyph, glass-styled (frosted keycap instead of a flat bordered box).
GlassSurface {
    id: root
    property string key
    property real horizontalPadding: 7
    property real verticalPadding: 3
    property real pixelSize: Appearance.font.pixelSize.smaller

    implicitWidth: keyText.implicitWidth + horizontalPadding * 2
    implicitHeight: keyText.implicitHeight + verticalPadding * 2
    radius: Appearance.rounding.verysmall
    fillOpacity: 0.5
    tint: Appearance.colors.colLayer2Base

    GText {
        id: keyText
        anchors.centerIn: parent
        font.family: Appearance.font.family.monospace
        font.pixelSize: root.pixelSize
        text: root.key
    }
}
