import qs.modules.common
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Glass button: no ripple, instead a press-scale + hover-glow feel — flat glass at rest,
// brightens and lifts slightly on hover, compresses on press.
Button {
    id: root
    property bool toggled: false
    property bool primary: false // filled/accent variant
    property string buttonText
    property string buttonIcon
    property string textFontFamily: Appearance.font.family.main
    property real textPixelSize: Appearance.font.pixelSize.small
    property bool materialIconFill: true
    property real iconSize: Appearance.font.pixelSize.larger
    property real buttonRadius: Appearance.rounding.small
    property bool pointingHandCursor: true
    property var downAction
    property var releaseAction
    property var altAction
    property var middleClickAction
    property Component mainContentComponent: Component {
        GText {
            visible: text !== ""
            text: root.buttonText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: root.textFontFamily
            font.pixelSize: root.textPixelSize
            color: root.contentColor
        }
    }

    property color baseTint: root.primary ? Appearance.colors.colPrimary : Appearance.colors.colLayer2Base
    property real baseFillOpacity: root.primary ? (root.toggled || root.primary ? 0.9 : 0.35) : (root.toggled ? 0.75 : 0.35)
    property color contentColor: root.primary ? Appearance.colors.colOnPrimary
        : root.toggled ? Appearance.colors.colOnSecondaryContainer
        : Appearance.colors.colOnLayer1

    implicitHeight: 36
    horizontalPadding: 12
    opacity: root.enabled ? 1 : 0.4

    scale: root.down ? 0.96 : (root.hovered ? 1.015 : 1.0)
    Behavior on scale {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: root.pointingHandCursor ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onPressed: event => {
            if (event.button === Qt.RightButton) { if (root.altAction) root.altAction(event); return }
            if (event.button === Qt.MiddleButton) { if (root.middleClickAction) root.middleClickAction(); return }
            root.down = true
            if (root.downAction) root.downAction()
        }
        onReleased: event => {
            root.down = false
            if (event.button !== Qt.LeftButton) return
            if (root.releaseAction) root.releaseAction()
            root.click()
        }
        onCanceled: root.down = false
    }

    background: GlassSurface {
        id: bg
        radius: root.buttonRadius
        tint: root.baseTint
        fillOpacity: root.down ? root.baseFillOpacity * 1.4 : root.hovered ? root.baseFillOpacity * 1.2 : root.baseFillOpacity
        showBorder: true
        border.color: root.hovered || root.toggled
            ? ColorUtils.applyAlpha(root.primary || root.toggled ? Appearance.colors.colPrimary : Appearance.m3colors.m3onBackground, root.hovered ? 0.35 : 0.2)
            : ColorUtils.applyAlpha(Appearance.m3colors.m3onBackground, 0.09)

        Behavior on fillOpacity {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }
        Behavior on border.color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }

    contentItem: RowLayout {
        spacing: 8
        Loader {
            active: root.buttonIcon.length > 0
            visible: active
            Layout.alignment: Qt.AlignVCenter
            sourceComponent: GIcon {
                text: root.buttonIcon
                size: root.iconSize
                fill: root.materialIconFill ? 1 : 0
                color: root.contentColor
            }
        }
        Loader {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            sourceComponent: root.mainContentComponent
        }
    }
}
