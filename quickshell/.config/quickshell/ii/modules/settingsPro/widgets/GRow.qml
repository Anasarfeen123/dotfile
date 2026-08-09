import QtQuick.Layouts

// Plain grouping row. Replaces ConfigRow.
RowLayout {
    property bool uniform: false
    spacing: 6
    uniformCellSizes: uniform
    Layout.fillWidth: true
}
