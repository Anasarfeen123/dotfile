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
    readonly property bool symbolicKey: key && /[^\x20-\x7E]/.test(key)

    implicitWidth: Math.max(keyText.implicitWidth + horizontalPadding * 2, symbolicKey ? implicitHeight : 0)
    implicitHeight: keyText.implicitHeight + verticalPadding * 2
    radius: Appearance.rounding.verysmall
    fillOpacity: 0.5
    tint: Appearance.colors.colLayer2Base

    GText {
        id: keyText
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: root.symbolicKey ? Appearance.font.family.iconNerd : Appearance.font.family.monospace
        font.pixelSize: root.symbolicKey ? root.pixelSize + 2 : root.pixelSize
        text: root.key
    }
}
