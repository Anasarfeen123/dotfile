import qs.modules.common
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts

// A single nav-rail destination: icon that stays put + a label that fades/slides in
// once the rail expands.
GButton {
    id: root
    property bool expanded: true
    property real iconGlyphSize: 22
    property real buttonIconRotation: 0
    toggled: false
    primary: false
    buttonRadius: Appearance.rounding.full
    Layout.fillWidth: true
    implicitHeight: 44
    horizontalPadding: 0
    baseFillOpacity: root.toggled ? 0.55 : 0.0

    background: GlassSurface {
        radius: root.buttonRadius
        tint: Appearance.colors.colPrimary
        fillOpacity: root.toggled ? (root.hovered ? 0.6 : 0.5) : (root.hovered ? 0.16 : 0.0)
        showBorder: root.toggled
        showSheen: false
        border.color: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.35)
        Behavior on fillOpacity { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }
    }

    contentItem: RowLayout {
        spacing: 12
        Item {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
            GIcon {
                anchors.centerIn: parent
                text: root.buttonIcon
                size: root.iconGlyphSize
                fill: root.toggled ? 1 : 0
                color: root.toggled ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer1
                rotation: root.buttonIconRotation || 0
            }
        }
        GText {
            visible: root.expanded
            Layout.fillWidth: true
            // horizontalPadding is 0 on the button itself (needed so the
            // 44px icon exactly fills the rail's collapsed width with no
            // clipping) — but that left the label running flush to the
            // pill's own rounded right edge with nothing to stop it. Only
            // the label needs the margin back; the icon side must stay at
            // 0 for the collapsed state to still fit.
            Layout.rightMargin: 10
            text: root.buttonText
            elide: Text.ElideRight
            color: root.toggled ? Appearance.colors.colOnLayer1 : Appearance.colors.colOnLayer1
            font.weight: root.toggled ? Font.DemiBold : Font.Normal
            opacity: root.expanded ? 1 : 0
            Behavior on opacity { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }
        }
    }
}
