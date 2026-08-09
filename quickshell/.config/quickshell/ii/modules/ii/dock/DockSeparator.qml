import qs.modules.common
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts

// A soft fade instead of a hard 1px line — matches the glass aesthetic
// better than a solid rule cutting across a translucent surface.
//
// The margins used to also add Appearance.rounding.normal (17px) on top
// of the elevation/gap spacing on *both* sides — on a 60px-tall dock that
// left the separator almost no visible height at all (~1px of a 60px
// bar). Dropped that extra term; the gap/padding alone is already enough
// to keep the line clear of the pill's rounded corners.
Item {
    Layout.topMargin: Appearance.sizes.elevationMargin + dockRow.padding
    Layout.bottomMargin: Appearance.sizes.hyprlandGapsOut + dockRow.padding
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
