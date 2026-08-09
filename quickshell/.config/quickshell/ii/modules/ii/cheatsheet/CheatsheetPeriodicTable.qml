import "periodic_table.js" as PTable
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import QtQuick
import Quickshell

Item {
    id: root
    readonly property var elements: PTable.elements
    readonly property var series: PTable.series
    property real spacing: 6
    // Same footprint as the keybinds tab, so the SwipeView doesn't jump
    // size when switching tabs.
    implicitWidth: QsWindow?.window?.screen.width * 0.7 ?? 0
    implicitHeight: QsWindow?.window?.screen.height * 0.7 ?? 0

    // The table previously had no scroll wrapper at all — anything that
    // didn't fit was just clipped by the SwipeView's mask with no way to
    // reach it. Now scrolls both ways since the table is wide and the
    // lanthanide/actinide series add real height.
    StyledFlickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: Appearance.rounding.small
        clip: true
        contentWidth: mainLayout.implicitWidth
        contentHeight: mainLayout.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        // StyledFlickable only animates contentY by default (it's built
        // for vertical lists) — this table scrolls horizontally, so the
        // scroll-step buttons below need their own contentX Behavior or
        // they'd just snap instead of sliding.
        Behavior on contentX {
            NumberAnimation {
                duration: Appearance.animation.scroll.duration
                easing.type: Appearance.animation.scroll.type
                easing.bezierCurve: Appearance.animation.scroll.bezierCurve
            }
        }

        Column {
            id: mainLayout
            spacing: root.spacing

            Repeater { // Main table rows
                model: root.elements

                delegate: Row { // Table cells
                    id: tableRow
                    spacing: root.spacing
                    required property var modelData

                    Repeater {
                        model: tableRow.modelData
                        delegate: ElementTile {
                            required property var modelData
                            element: modelData
                        }
                    }
                }
            }

            Item {
                id: gap
                implicitHeight: 20
            }

            Repeater { // Series rows (lanthanides/actinides)
                model: root.series

                delegate: Row { // Table cells
                    id: seriesTableRow
                    spacing: root.spacing
                    required property var modelData

                    Repeater {
                        model: seriesTableRow.modelData
                        delegate: ElementTile {
                            required property var modelData
                            element: modelData
                        }
                    }
                }
            }
        }
    }

    ScrollEdgeFade {
        target: flickable
        vertical: false
        color: Appearance.colors.colLayer0Base
    }

    // Explicit scroll buttons as a guaranteed way to reach the edges,
    // regardless of whether wheel/trackpad scroll reaches the Flickable
    // (it can end up in front of a lot of clickable element tiles).
    component ScrollStepButton: RippleButton {
        id: stepBtn
        required property real direction // -1 or 1
        implicitWidth: 32
        implicitHeight: 32
        buttonRadius: Appearance.rounding.full
        colBackground: ColorUtils.applyAlpha(Appearance.colors.colLayer0Base, 0.85)
        visible: stepBtn.direction < 0 ? flickable.contentX > 1 : flickable.contentX < flickable.contentWidth - flickable.width - 1
        onClicked: {
            const maxX = Math.max(0, flickable.contentWidth - flickable.width);
            flickable.contentX = Math.max(0, Math.min(maxX, flickable.contentX + stepBtn.direction * flickable.width * 0.6));
        }
        contentItem: MaterialSymbol {
            anchors.centerIn: parent
            iconSize: 20
            text: stepBtn.direction < 0 ? "chevron_left" : "chevron_right"
            color: Appearance.colors.colOnLayer0
        }
    }

    ScrollStepButton {
        anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 4 }
        direction: -1
    }
    ScrollStepButton {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 4 }
        direction: 1
    }
}
