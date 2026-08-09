import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts

StyledGlassSurface {
    id: root
    fillOpacity: 0.38

    implicitHeight: content.implicitHeight + 24
    implicitWidth: 200

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MaterialSymbol {
                text: "monitoring"
                iconSize: 18
                color: Appearance.colors.colOnLayer1
            }
            StyledText {
                Layout.fillWidth: true
                text: Translation.tr("Performance")
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
                color: Appearance.colors.colOnLayer1
            }
        }

        GraphTile {
            label: Translation.tr("CPU")
            iconName: "memory"
            history: ResourceUsage.cpuUsageHistory
            value: ResourceUsage.cpuUsage
            graphColor: Appearance.colors.colPrimary
        }
        GraphTile {
            label: Translation.tr("RAM")
            iconName: "data_usage"
            history: ResourceUsage.memoryUsageHistory
            value: ResourceUsage.memoryUsedPercentage
            graphColor: Appearance.colors.colTertiary
        }
        GraphTile {
            label: Translation.tr("GPU")
            iconName: "view_in_ar"
            history: ResourceUsage.gpuUsageHistory
            value: ResourceUsage.gpuUsage
            graphColor: Appearance.colors.colSecondary
        }
    }

    component GraphTile: RowLayout {
        id: tile
        required property string label
        required property string iconName
        required property var history
        required property real value
        required property color graphColor
        spacing: 8

        MaterialSymbol {
            text: tile.iconName
            iconSize: 16
            color: Appearance.colors.colSubtext
        }
        StyledText {
            Layout.preferredWidth: 34
            Layout.alignment: Qt.AlignVCenter
            text: tile.label
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colOnLayer1
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            Layout.alignment: Qt.AlignVCenter
            radius: Appearance.rounding.small
            color: ColorUtils.applyAlpha(Appearance.colors.colLayer1Base, 0.35)
            border.width: 1
            border.color: Appearance.colors.colLayer0Border
            clip: true

            Graph {
                anchors.fill: parent
                anchors.margins: 3
                values: tile.history
                color: tile.graphColor
                fillOpacity: 0.35
            }
        }
        StyledText {
            Layout.preferredWidth: 40
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignRight
            text: `${Math.round(tile.value * 100)}%`
            font.pixelSize: Appearance.font.pixelSize.small
            font.weight: Font.DemiBold
            color: Appearance.colors.colOnLayer1
        }
    }
}
