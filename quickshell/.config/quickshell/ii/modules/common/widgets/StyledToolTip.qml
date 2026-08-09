import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolTip {
    id: root
    property bool extraVisibleCondition: true
    property bool alternativeVisibleCondition: false

    // Some parents (plain RowLayouts) have no `hovered` property; without this the
    // tooltip would be permanently visible on those controls.
    HoverHandler {
        id: hoverHandler
        target: root.parent
        enabled: root.enabled
    }

    readonly property bool internalVisibleCondition: (extraVisibleCondition && (root.parent?.hovered ?? hoverHandler.hovered)) || alternativeVisibleCondition
    verticalPadding: 5
    horizontalPadding: 10
    background: null
    font {
        family: Appearance.font.family.main
        variableAxes: Appearance.font.variableAxes.main
        pixelSize: Appearance?.font.pixelSize.normal ?? 16
        hintingPreference: Font.PreferNoHinting // Prevent shaky text
    }

    delay: 0
    visible: internalVisibleCondition
    
    contentItem: StyledToolTipContent {
        id: contentItem
        font: root.font
        text: root.text
        shown: root.internalVisibleCondition
        horizontalPadding: root.horizontalPadding
        verticalPadding: root.verticalPadding
    }
}
