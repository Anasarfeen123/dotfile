import qs.modules.common
import qs.services
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    property bool borderless: Config.options.bar.borderless
    property bool alwaysShowAllResources: false
    implicitWidth: rowLayout.implicitWidth + rowLayout.anchors.leftMargin + rowLayout.anchors.rightMargin
    implicitHeight: Appearance.sizes.barHeight
    hoverEnabled: !Config.options.bar.tooltips.clickToShow

    RowLayout {
        id: rowLayout

        spacing: 0
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4

        Resource {
            iconName: "memory"
            percentage: ResourceUsage.memoryUsedPercentage
            warningThreshold: Config.options.bar.resources.memoryWarningThreshold
        }

        Resource {
            iconName: "swap_horiz"
            percentage: ResourceUsage.swapUsedPercentage
            // Hover detail already lives in ResourcesPopup below; expanding
            // inline here on hover pushed Media/CavaVisualizer sideways and
            // overlapped the music visualizer, since this bar group has a
            // fixed width. Only expand for the "always show" shortened form.
            shown: root.alwaysShowAllResources
            Layout.leftMargin: shown ? 6 : 0
            warningThreshold: Config.options.bar.resources.swapWarningThreshold
        }

        Resource {
            iconName: ResourceUsage.cpuHighTemp ? "local_fire_department" : "planner_review"
            percentage: ResourceUsage.cpuUsage
            shown: true
            Layout.leftMargin: 6
            warningThreshold: ResourceUsage.cpuHighTemp ? 0 : Config.options.bar.resources.cpuWarningThreshold
        }

        Resource {
            iconName: ResourceUsage.gpuHighTemp ? "local_fire_department" : "sports_esports"
            percentage: ResourceUsage.gpuUsage
            shown: root.alwaysShowAllResources || ResourceUsage.gpuHighTemp
            Layout.leftMargin: shown ? 6 : 0
            warningThreshold: ResourceUsage.gpuHighTemp ? 0 : 90
        }

        Resource {
            iconName: "hard_drive"
            percentage: ResourceUsage.diskUsedPercentage
            shown: root.alwaysShowAllResources
            Layout.leftMargin: shown ? 6 : 0
            warningThreshold: 90
        }

    }

    ResourcesPopup {
        hoverTarget: root
    }
}
