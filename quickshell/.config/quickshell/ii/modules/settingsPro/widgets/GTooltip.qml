import qs.modules.common
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls

// Glass tooltip: a small frosted pill instead of the flat solid original.
ToolTip {
    id: root
    property bool extraVisibleCondition: true
    property bool alternativeVisibleCondition: false

    HoverHandler {
        id: hoverHandler
        target: root.parent
        enabled: root.enabled
    }

    readonly property bool internalVisibleCondition: (extraVisibleCondition && (root.parent?.hovered ?? hoverHandler.hovered)) || alternativeVisibleCondition

    delay: 250
    visible: internalVisibleCondition
    verticalPadding: 0
    horizontalPadding: 0
    background: null

    contentItem: GlassSurface {
        implicitWidth: label.implicitWidth + 24
        implicitHeight: label.implicitHeight + 14
        fillOpacity: 0.85
        tint: Appearance.colors.colTooltip
        radius: Appearance.rounding.verysmall
        opacity: root.internalVisibleCondition ? 1 : 0
        scale: root.internalVisibleCondition ? 1 : 0.9
        Behavior on opacity { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }
        Behavior on scale { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }

        GText {
            id: label
            anchors.centerIn: parent
            text: root.text
            wrapMode: Text.Wrap
            color: Appearance.colors.colOnTooltip
            font.pixelSize: Appearance.font.pixelSize.smaller
            font.hintingPreference: Font.PreferNoHinting
        }
    }
}
