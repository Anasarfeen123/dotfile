import "periodic_table.js" as PTable
import qs.modules.common
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
}
