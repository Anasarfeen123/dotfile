import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts
import Quickshell

RippleButton {
    id: root
    implicitWidth: 32
    implicitHeight: 32
    buttonRadius: Appearance.rounding.full
    colBackground: ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)
    colBackgroundHover: Appearance.colors.colLayer1Hover
    colBackgroundToggled: Appearance.colors.colSecondaryContainer
    colBackgroundToggledHover: Appearance.colors.colSecondaryContainerHover
    toggled: GlobalStates.utilityMenuOpen

    onClicked: GlobalStates.utilityMenuOpen = !GlobalStates.utilityMenuOpen

    MaterialSymbol {
        anchors.centerIn: parent
        text: "apps"
        iconSize: Appearance.font.pixelSize.large
        color: root.toggled ? Appearance.m3colors.m3onSecondaryContainer : Appearance.colors.colOnLayer0
    }
    PopupToolTip {
        text: Translation.tr("Utilities")
        anchorEdges: (!Config.options.bar.bottom && !Config.options.bar.vertical) ? Edges.Bottom : Edges.Top
    }
}
