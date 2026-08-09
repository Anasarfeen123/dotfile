import qs.modules.common
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts

// A soft fade instead of a hard 1px line — matches the glass aesthetic
// better than a solid rule cutting across a translucent surface.
Item {
    Layout.topMargin: Appearance.sizes.elevationMargin + dockRow.padding + Appearance.rounding.normal
    Layout.bottomMargin: Appearance.sizes.hyprlandGapsOut + dockRow.padding + Appearance.rounding.normal
    Layout.fillHeight: true
    implicitWidth: 1

    Rectangle {
        anchors.centerIn: parent
        width: 1
        height: parent.height
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: ColorUtils.transparentize(Appearance.colors.colOutlineVariant, 1) }
            GradientStop { position: 0.5; color: Appearance.colors.colOutlineVariant }
            GradientStop { position: 1.0; color: ColorUtils.transparentize(Appearance.colors.colOutlineVariant, 1) }
        }
    }
}
