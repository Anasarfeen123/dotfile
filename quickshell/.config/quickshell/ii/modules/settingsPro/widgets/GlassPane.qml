import QtQuick
import QtQuick.Effects
import qs.modules.common
import qs.modules.common.functions

// A structural glass panel (nav rail, main content container, popovers): a GlassSurface
// with a soft ambient shadow behind it so it visibly "floats" above the desktop blur.
Item {
    id: root

    property real fillOpacity: 0.6
    property color tint: Appearance.colors.colLayer1Base
    property bool showSheen: true
    property bool showBorder: true
    property real radius: Appearance.rounding.normal
    property bool elevated: true
    property real shadowBlur: 24
    property color glowTint: Appearance.colors.colPrimary
    property real glowStrength: 0.0 // 0 = neutral shadow, >0 tints the shadow with glowTint

    default property alias contentData: card.contentData

    RectangularShadow {
        anchors.fill: card
        radius: card.radius
        blur: root.shadowBlur
        offset: Qt.vector2d(0, 4)
        spread: 0
        visible: root.elevated
        color: root.glowStrength > 0
            ? ColorUtils.applyAlpha(ColorUtils.mix(Appearance.colors.colShadow, root.glowTint, 1 - root.glowStrength), 0.55)
            : ColorUtils.applyAlpha(Appearance.colors.colShadow, 0.45)
    }

    GlassSurface {
        id: card
        anchors.fill: parent
        radius: root.radius
        fillOpacity: root.fillOpacity
        tint: root.tint
        showSheen: root.showSheen
        showBorder: root.showBorder
    }
}
