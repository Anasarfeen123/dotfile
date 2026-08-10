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
    buttonRadius: root.expanded ? Appearance.rounding.large : Appearance.rounding.full
    Layout.fillWidth: true
    implicitHeight: 48
    horizontalPadding: 0
    baseFillOpacity: root.toggled ? 0.55 : 0.0
    clip: true

    Behavior on buttonRadius {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    background: GlassSurface {
        radius: root.buttonRadius
        tint: root.toggled ? ColorUtils.mix(Appearance.colors.colPrimaryContainer, Appearance.colors.colPrimary, 0.64) : Appearance.colors.colLayer1Base
        fillOpacity: root.toggled ? (root.hovered ? 0.82 : 0.7) : (root.hovered ? 0.18 : 0.0)
        showBorder: false
        showSheen: root.toggled
        Behavior on fillOpacity { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }
        Behavior on tint { animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this) }
    }

    contentItem: RowLayout {
        spacing: root.expanded ? 10 : 0
        Item {
            Layout.preferredWidth: root.expanded ? 4 : 0
            Layout.preferredHeight: 1
            visible: root.expanded
        }

        Rectangle {
            visible: root.expanded
            property real indicatorWidth: root.toggled ? 4 : 0
            property real indicatorHeight: root.toggled ? 24 : 12
            Layout.preferredWidth: indicatorWidth
            Layout.preferredHeight: indicatorHeight
            Layout.alignment: Qt.AlignVCenter
            radius: Appearance.rounding.full
            color: Appearance.colors.colPrimary
            opacity: root.toggled ? 1 : 0

            Behavior on indicatorWidth { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }
            Behavior on indicatorHeight { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }
            Behavior on opacity { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }
        }

        Item {
            Layout.preferredWidth: 46
            Layout.preferredHeight: 46
            Layout.alignment: Qt.AlignVCenter | (root.expanded ? Qt.AlignLeft : Qt.AlignHCenter)
            Rectangle {
                anchors.centerIn: parent
                width: root.toggled ? 34 : (root.hovered ? 30 : 0)
                height: root.toggled ? 34 : (root.hovered ? 30 : 0)
                radius: Appearance.rounding.full
                color: ColorUtils.applyAlpha(Appearance.colors.colPrimary, root.toggled ? 0.22 : 0.1)

                Behavior on width { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }
                Behavior on height { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }
                Behavior on color { animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this) }
            }
            GIcon {
                anchors.centerIn: parent
                text: root.buttonIcon
                size: root.iconGlyphSize
                fill: root.toggled ? 1 : 0
                color: root.toggled ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnLayer1
                rotation: root.buttonIconRotation || 0
                Behavior on color { animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this) }
            }
        }
        GMarqueeText {
            visible: root.expanded
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            Layout.alignment: Qt.AlignVCenter
            // horizontalPadding is 0 on the button itself (needed so the
            // 44px icon exactly fills the rail's collapsed width with no
            // clipping) — but that left the label running flush to the
            // pill's own rounded right edge with nothing to stop it. Only
            // the label needs the margin back; the icon side must stay at
            // 0 for the collapsed state to still fit.
            Layout.rightMargin: 10
            text: root.buttonText
            color: root.toggled ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnLayer1
            font.weight: root.toggled ? Font.DemiBold : Font.Normal
            opacity: root.expanded ? 1 : 0
            Behavior on opacity { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }
            Behavior on color { animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this) }
        }

        Item {
            Layout.preferredWidth: root.expanded ? 4 : 0
            Layout.preferredHeight: 1
            visible: root.expanded
        }
    }
}
