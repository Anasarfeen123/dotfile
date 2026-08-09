import QtQuick
import qs.modules.common
import qs.modules.common.functions

// Frosted glass card surface: translucent fill + hairline border.
// Use this anywhere a Material-glass card is wanted (sidebars, groups, popups).
Rectangle {
    id: root

    // Fill opacity (0-1) for the glass body. Lower = more see-through.
    property real fillOpacity: 0.45
    property color fillColor: Appearance.colors.colLayer1Base
    property bool showBorder: true

    radius: Appearance.rounding.normal
    color: ColorUtils.applyAlpha(root.fillColor, root.fillOpacity)
    border.width: root.showBorder ? 1 : 0
    border.color: Appearance.colors.colLayer0Border
    clip: true
}
