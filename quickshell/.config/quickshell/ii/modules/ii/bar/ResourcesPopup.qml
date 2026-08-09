import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root

    // Helper function to format KB to GB
    function formatKB(kb) {
        return (kb / (1024 * 1024)).toFixed(1) + " GB";
    }

    Row {
        anchors.centerIn: parent
        spacing: 12

        Column {
            anchors.top: parent.top
            spacing: 8

            StyledPopupHeaderRow {
                icon: "memory"
                label: "RAM"
            }
            Column {
                spacing: 4
                StyledPopupValueRow {
                    icon: "clock_loader_60"
                    label: Translation.tr("Used:")
                    value: root.formatKB(ResourceUsage.memoryUsed)
                }
                StyledPopupValueRow {
                    icon: "check_circle"
                    label: Translation.tr("Free:")
                    value: root.formatKB(ResourceUsage.memoryFree)
                }
                StyledPopupValueRow {
                    icon: "empty_dashboard"
                    label: Translation.tr("Total:")
                    value: root.formatKB(ResourceUsage.memoryTotal)
                }
            }
        }

        Column {
            visible: ResourceUsage.swapTotal > 0
            anchors.top: parent.top
            spacing: 8

            StyledPopupHeaderRow {
                icon: "swap_horiz"
                label: "Swap"
            }
            Column {
                spacing: 4
                StyledPopupValueRow {
                    icon: "clock_loader_60"
                    label: Translation.tr("Used:")
                    value: root.formatKB(ResourceUsage.swapUsed)
                }
                StyledPopupValueRow {
                    icon: "check_circle"
                    label: Translation.tr("Free:")
                    value: root.formatKB(ResourceUsage.swapFree)
                }
                StyledPopupValueRow {
                    icon: "empty_dashboard"
                    label: Translation.tr("Total:")
                    value: root.formatKB(ResourceUsage.swapTotal)
                }
            }
        }

        Column {
            anchors.top: parent.top
            spacing: 8

            StyledPopupHeaderRow {
                icon: "planner_review"
                label: "CPU"
            }
            Column {
                spacing: 4
                StyledPopupValueRow {
                    icon: "bolt"
                    label: Translation.tr("Load:")
                    value: `${Math.round(ResourceUsage.cpuUsage * 100)}%`
                }
                StyledPopupValueRow {
                    icon: "thermostat"
                    label: Translation.tr("Temp:")
                    value: `${ResourceUsage.cpuTemp}°C`
                }
            }
        }

        Column {
            anchors.top: parent.top
            spacing: 8

            StyledPopupHeaderRow {
                icon: "sports_esports"
                label: "GPU"
            }
            Column {
                spacing: 4
                StyledPopupValueRow {
                    icon: "bolt"
                    label: Translation.tr("Usage:")
                    value: `${Math.round(ResourceUsage.gpuUsage * 100)}%`
                }
                StyledPopupValueRow {
                    icon: "thermostat"
                    label: Translation.tr("Temp:")
                    value: `${ResourceUsage.gpuTemp}°C`
                }
                StyledPopupValueRow {
                    icon: "memory"
                    label: Translation.tr("VRAM:")
                    value: `${Math.round(ResourceUsage.gpuMemoryUsed)} MB / ${Math.round(ResourceUsage.gpuMemoryTotal)} MB`
                }
            }
        }

        Column {
            anchors.top: parent.top
            spacing: 8

            StyledPopupHeaderRow {
                icon: "hard_drive"
                label: "Storage"
            }
            Column {
                spacing: 4
                StyledPopupValueRow {
                    icon: "clock_loader_60"
                    label: Translation.tr("Used:")
                    value: `${ResourceUsage.diskUsed.toFixed(1)} GB`
                }
                StyledPopupValueRow {
                    icon: "check_circle"
                    label: Translation.tr("Free:")
                    value: `${ResourceUsage.diskFree.toFixed(1)} GB`
                }
                StyledPopupValueRow {
                    icon: "empty_dashboard"
                    label: Translation.tr("Total:")
                    value: `${ResourceUsage.diskTotal.toFixed(1)} GB`
                }
            }
        }

        Column {
            anchors.top: parent.top
            spacing: 8

            StyledPopupHeaderRow {
                icon: "swap_calls"
                label: "Network"
            }
            Column {
                spacing: 4
                StyledPopupValueRow {
                    icon: "arrow_downward"
                    label: Translation.tr("Down:")
                    value: ResourceUsage.netDownSpeedString
                }
                StyledPopupValueRow {
                    icon: "arrow_upward"
                    label: Translation.tr("Up:")
                    value: ResourceUsage.netUpSpeedString
                }
            }
        }
    }
}
