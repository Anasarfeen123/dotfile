import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

StyledGlassSurface {
    id: root
    fillOpacity: 0.38

    implicitHeight: content.implicitHeight + 24
    implicitWidth: 200

    function formatKB(kb) {
        return (kb / (1024 * 1024)).toFixed(1) + " GB";
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        RowLayout { // Header with graphs toggle
            spacing: 6

            MaterialSymbol {
                text: "monitoring"
                iconSize: 18
                color: Appearance.colors.colOnLayer1
            }
            StyledText {
                Layout.fillWidth: true
                text: Translation.tr("System")
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
                color: Appearance.colors.colOnLayer1
            }
            RippleButton {
                id: graphsToggle
                implicitWidth: 24
                implicitHeight: 24
                colBackground: graphsToggle.hovered ? ColorUtils.applyAlpha(Appearance.colors.colLayer1Base, 0.4) : "transparent"
                onClicked: graphsReveal.reveal = !graphsReveal.reveal
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "show_chart"
                    iconSize: 18
                    color: Appearance.colors.colSubtext
                }
                StyledToolTip {
                    text: graphsReveal.revealed ? Translation.tr("Hide graphs") : Translation.tr("Show graphs")
                }
            }
        }

        RowLayout { // Resource pills
            spacing: 6

            ResourcePill {
                Layout.fillWidth: true
                iconName: "memory"
                label: Translation.tr("RAM")
                percentage: ResourceUsage.memoryUsedPercentage
                text: root.formatKB(ResourceUsage.memoryUsed)
            }
            ResourcePill {
                Layout.fillWidth: true
                iconName: "planner_review"
                label: Translation.tr("CPU")
                percentage: ResourceUsage.cpuUsage
                text: `${Math.round(ResourceUsage.cpuUsage * 100)}%`
            }
            ResourcePill {
                Layout.fillWidth: true
                iconName: "hard_drive"
                label: Translation.tr("Disk")
                percentage: ResourceUsage.diskUsedPercentage
                text: `${Math.round(ResourceUsage.diskUsedPercentage * 100)}%`
            }
        }

        RowLayout { // GPU + temps
            spacing: 6

            ResourcePill {
                Layout.fillWidth: true
                iconName: "settings_input_hdmi"
                label: Translation.tr("GPU")
                percentage: ResourceUsage.gpuUsage
                text: `${Math.round(ResourceUsage.gpuUsage * 100)}%`
            }
            TempPill {
                Layout.fillWidth: true
                iconName: "thermostat"
                label: Translation.tr("CPU")
                temp: ResourceUsage.cpuTemp
            }
            TempPill {
                Layout.fillWidth: true
                iconName: "device_thermostat"
                label: Translation.tr("GPU")
                temp: ResourceUsage.gpuTemp
            }
        }

        RowLayout { // Network
            spacing: 6

            NetTile {
                Layout.fillWidth: true
                iconName: "arrow_downward"
                label: Translation.tr("Down")
                value: ResourceUsage.netDownSpeedString
            }
            NetTile {
                Layout.fillWidth: true
                iconName: "arrow_upward"
                label: Translation.tr("Up")
                value: ResourceUsage.netUpSpeedString
            }
        }

        RowLayout { // Uptime + swap + theme
            spacing: 6

            UptimeTile {
                Layout.fillWidth: true
            }
            SwapTile {
                Layout.fillWidth: true
            }
            ThemeToggleTile {
                Layout.fillWidth: true
            }
        }

        // Collapsible graphs
        Revealer {
            id: graphsReveal
            Layout.fillWidth: true
            vertical: true

            ColumnLayout {
                width: parent.width
                spacing: 6

                GraphTile {
                    label: Translation.tr("CPU")
                    iconName: "planner_review"
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
        }
    }

    component ResourcePill: ColumnLayout {
        id: pill
        required property string iconName
        required property string label
        required property real percentage
        required property string text
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            MaterialSymbol {
                text: pill.iconName
                iconSize: 16
                color: Appearance.colors.colOnLayer1
            }
            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: pill.label
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colOnLayer1
                elide: Text.ElideRight
            }
            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: pill.text
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colOnLayer1
            }
        }

        StyledProgressBar {
            Layout.fillWidth: true
            value: pill.percentage
            valueBarWidth: pill.width
            valueBarHeight: 6
            highlightColor: pill.percentage >= 0.85 ? Appearance.colors.colError : Appearance.colors.colPrimary
            trackColor: ColorUtils.applyAlpha(Appearance.colors.colLayer2Base, 0.5)
        }
    }

    component NetTile: ColumnLayout {
        id: netTile
        required property string iconName
        required property string label
        required property string value
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            MaterialSymbol {
                text: netTile.iconName
                iconSize: 16
                color: Appearance.colors.colOnLayer1
            }
            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: netTile.label
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colSubtext
            }
            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: netTile.value
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
                color: Appearance.colors.colOnLayer1
            }
        }
    }

    component TempPill: ColumnLayout {
        id: temp
        required property string iconName
        required property string label
        required property real temp
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            MaterialSymbol {
                text: temp.iconName
                iconSize: 16
                color: temp.temp >= 80 ? Appearance.colors.colError : Appearance.colors.colOnLayer1
            }
            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: temp.label
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colSubtext
            }
            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: `${Math.round(temp.temp)}°C`
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
                color: temp.temp >= 80 ? Appearance.colors.colError : Appearance.colors.colOnLayer1
            }
        }
    }

    component UptimeTile: Rectangle {
        id: uptimeTile
        Layout.fillWidth: true
        Layout.preferredHeight: 44
        radius: Appearance.rounding.small
        color: ColorUtils.applyAlpha(Appearance.colors.colLayer1Base, 0.35)
        border.width: 1
        border.color: Appearance.colors.colLayer0Border
        clip: true

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            MaterialSymbol {
                text: "timer"
                iconSize: 20
                color: Appearance.colors.colOnLayer1
                fill: 1
            }
            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Uptime")
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colOnLayer1
            }
            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: ResourceUsage.uptimeString
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
                color: Appearance.colors.colOnLayer1
            }
        }
    }

    component SwapTile: Rectangle {
        id: swapTile
        Layout.fillWidth: true
        Layout.preferredHeight: 44
        radius: Appearance.rounding.small
        color: ColorUtils.applyAlpha(Appearance.colors.colLayer1Base, 0.35)
        border.width: 1
        border.color: Appearance.colors.colLayer0Border
        clip: true

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            MaterialSymbol {
                text: "storage"
                iconSize: 20
                color: Appearance.colors.colOnLayer1
                fill: 1
            }
            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: Translation.tr("Swap")
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colOnLayer1
            }
            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: `${Math.round(ResourceUsage.swapUsedPercentage * 100)}%`
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
                color: Appearance.colors.colOnLayer1
            }
        }
    }

    component ThemeToggleTile: Rectangle {
        id: themeTile
        Layout.fillWidth: true
        Layout.preferredHeight: 44
        radius: Appearance.rounding.small
        color: ColorUtils.applyAlpha(Appearance.colors.colLayer1Base, 0.35)
        border.width: 1
        border.color: Appearance.colors.colLayer0Border
        clip: true

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: {
                if (Appearance.m3colors.darkmode) {
                    Quickshell.execDetached([Directories.wallpaperSwitchScriptPath, "--mode", "light", "--noswitch"]);
                } else {
                    Quickshell.execDetached([Directories.wallpaperSwitchScriptPath, "--mode", "dark", "--noswitch"]);
                }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            MaterialSymbol {
                text: "contrast"
                iconSize: 20
                color: Appearance.colors.colOnLayer1
                fill: 1
            }
            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: Appearance.m3colors.darkmode ? Translation.tr("Dark mode") : Translation.tr("Light mode")
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colOnLayer1
            }
            MaterialSymbol {
                text: Appearance.m3colors.darkmode ? "dark_mode" : "light_mode"
                iconSize: 18
                color: Appearance.colors.colSubtext
            }
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
