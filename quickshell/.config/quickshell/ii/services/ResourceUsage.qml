pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Simple polled resource usage service with RAM, Swap, and CPU usage.
 */
Singleton {
    id: root
	property real memoryTotal: 1
	property real memoryFree: 0
	property real memoryUsed: memoryTotal - memoryFree
    property real memoryUsedPercentage: memoryUsed / memoryTotal
    property real swapTotal: 1
	property real swapFree: 0
	property real swapUsed: swapTotal - swapFree
    property real swapUsedPercentage: swapTotal > 0 ? (swapUsed / swapTotal) : 0
    property real cpuUsage: 0
    property var previousCpuStats
    property real cpuTemp: 0
    property bool cpuHighTemp: cpuTemp >= 80
    property bool gpuHighTemp: gpuTemp >= 80

    property real uptimeSeconds: 0
    property string uptimeString: "0m"

    property real gpuUsage: 0
    property real gpuTemp: 0
    property real gpuMemoryUsed: 0
    property real gpuMemoryTotal: 4096
    property real gpuMemoryUsedPercentage: 0

    property real diskTotal: 1
    property real diskUsed: 0
    property real diskFree: 0
    property real diskUsedPercentage: 0

    property real netDownSpeed: 0
    property real netUpSpeed: 0
    property string netDownSpeedString: "0 KB/s"
    property string netUpSpeedString: "0 KB/s"
    property real lastRxBytes: 0
    property real lastTxBytes: 0

    property string maxAvailableMemoryString: kbToGbString(ResourceUsage.memoryTotal)
    property string maxAvailableSwapString: kbToGbString(ResourceUsage.swapTotal)
    property string maxAvailableCpuString: "--"

    readonly property int historyLength: Config?.options.resources.historyLength ?? 60
    property list<real> cpuUsageHistory: []
    property list<real> memoryUsageHistory: []
    property list<real> swapUsageHistory: []
    property list<real> gpuUsageHistory: []

    function kbToGbString(kb) {
        return (kb / (1024 * 1024)).toFixed(1) + " GB";
    }

    function updateMemoryUsageHistory() {
        memoryUsageHistory = [...memoryUsageHistory, memoryUsedPercentage]
        if (memoryUsageHistory.length > historyLength) {
            memoryUsageHistory.shift()
        }
    }
    function updateSwapUsageHistory() {
        swapUsageHistory = [...swapUsageHistory, swapUsedPercentage]
        if (swapUsageHistory.length > historyLength) {
            swapUsageHistory.shift()
        }
    }
    function updateCpuUsageHistory() {
        cpuUsageHistory = [...cpuUsageHistory, cpuUsage]
        if (cpuUsageHistory.length > historyLength) {
            cpuUsageHistory.shift()
        }
    }
    function updateGpuUsageHistory() {
        gpuUsageHistory = [...gpuUsageHistory, gpuUsage]
        if (gpuUsageHistory.length > historyLength) {
            gpuUsageHistory.shift()
        }
    }
    function updateHistories() {
        updateMemoryUsageHistory()
        updateSwapUsageHistory()
        updateCpuUsageHistory()
        updateGpuUsageHistory()
    }

    function formatSpeed(bytes) {
        if (bytes >= 1048576) return (bytes / 1048576).toFixed(1) + " MB/s";
        if (bytes >= 1024) return (bytes / 1024).toFixed(0) + " KB/s";
        return bytes.toFixed(0) + " B/s";
    }

	Timer {
		interval: 1
        running: true 
        repeat: true
		onTriggered: {
            // Reload files
            fileMeminfo.reload()
            fileStat.reload()

            // Parse memory and swap usage
            const textMeminfo = fileMeminfo.text()
            memoryTotal = Number(textMeminfo.match(/MemTotal: *(\d+)/)?.[1] ?? 1)
            memoryFree = Number(textMeminfo.match(/MemAvailable: *(\d+)/)?.[1] ?? 0)
            swapTotal = Number(textMeminfo.match(/SwapTotal: *(\d+)/)?.[1] ?? 1)
            swapFree = Number(textMeminfo.match(/SwapFree: *(\d+)/)?.[1] ?? 0)

            // Parse CPU usage
            const textStat = fileStat.text()
            const cpuLine = textStat.match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)
            if (cpuLine) {
                const stats = cpuLine.slice(1).map(Number)
                const total = stats.reduce((a, b) => a + b, 0)
                const idle = stats[3]

                if (previousCpuStats) {
                    const totalDiff = total - previousCpuStats.total
                    const idleDiff = idle - previousCpuStats.idle
                    cpuUsage = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0
                }

                previousCpuStats = { total, idle }
            }

            // Parse network speed
            fileNetDev.reload()
            const textNetDev = fileNetDev.text()
            let rxTotal = 0
            let txTotal = 0
            const netLines = textNetDev.split("\n")
            for (let i = 0; i < netLines.length; i++) {
                const line = netLines[i].trim()
                if (line.includes(":") && !line.startsWith("lo:")) {
                    const parts = line.split(":")[1].trim().split(/\s+/)
                    if (parts.length >= 9) {
                        rxTotal += Number(parts[0]) || 0
                        txTotal += Number(parts[8]) || 0
                    }
                }
            }
            if (lastRxBytes > 0 && rxTotal >= lastRxBytes) {
                const sec = (interval > 0 ? interval : 3000) / 1000
                netDownSpeed = (rxTotal - lastRxBytes) / sec
                netUpSpeed = (txTotal - lastTxBytes) / sec
                netDownSpeedString = formatSpeed(netDownSpeed)
                netUpSpeedString = formatSpeed(netUpSpeed)
            }
            lastRxBytes = rxTotal
            lastTxBytes = txTotal

            // Parse CPU temp
            fileCpuTemp.reload()
            root.cpuTemp = Math.round((Number(fileCpuTemp.text()) || 0) / 1000)

            // Parse Uptime
            fileUptime.reload()
            const upSec = parseFloat(fileUptime.text().split(" ")[0]) || 0
            root.uptimeSeconds = upSec
            const hours = Math.floor(upSec / 3600)
            const mins = Math.floor((upSec % 3600) / 60)
            root.uptimeString = hours > 0 ? `${hours}h ${mins}m` : `${mins}m`

            // Trigger GPU & Disk update
            gpuProc.running = true
            diskProc.running = true

            root.updateHistories()
            interval = Config.options?.resources?.updateInterval ?? 3000
        }
	}

	FileView { id: fileMeminfo; path: "/proc/meminfo" }
    FileView { id: fileStat; path: "/proc/stat" }
    FileView { id: fileNetDev; path: "/proc/net/dev" }
    FileView { id: fileCpuTemp; path: "/sys/class/thermal/thermal_zone0/temp" }
    FileView { id: fileUptime; path: "/proc/uptime" }

    Process {
        id: diskProc
        command: ["df", "-B1", "/"]
        stdout: StdioCollector {
            id: diskCollector
            onStreamFinished: {
                const lines = diskCollector.text.trim().split("\n")
                if (lines.length >= 2) {
                    const parts = lines[1].trim().split(/\s+/)
                    if (parts.length >= 4) {
                        root.diskTotal = (parseFloat(parts[1]) || 1) / (1024 * 1024 * 1024)
                        root.diskUsed = (parseFloat(parts[2]) || 0) / (1024 * 1024 * 1024)
                        root.diskFree = (parseFloat(parts[3]) || 0) / (1024 * 1024 * 1024)
                        root.diskUsedPercentage = root.diskUsed / root.diskTotal
                    }
                }
            }
        }
    }

    Process {
        id: gpuProc
        command: ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total", "--format=csv,noheader,nounits"]
        stdout: StdioCollector {
            id: gpuOutputCollector
            onStreamFinished: {
                const text = gpuOutputCollector.text.trim()
                const parts = text.split(",").map(s => parseFloat(s.trim()))
                if (parts.length >= 4 && !isNaN(parts[0])) {
                    root.gpuUsage = parts[0] / 100
                    root.gpuTemp = parts[1] || 0
                    root.gpuMemoryUsed = parts[2] || 0
                    root.gpuMemoryTotal = parts[3] || 4096
                    root.gpuMemoryUsedPercentage = root.gpuMemoryUsed / root.gpuMemoryTotal
                }
            }
        }
    }

    Process {
        id: findCpuMaxFreqProc
        environment: ({
            LANG: "C",
            LC_ALL: "C"
        })
        command: ["bash", "-c", "lscpu | grep 'CPU max MHz' | awk '{print $4}'"]
        running: true
        stdout: StdioCollector {
            id: outputCollector
            onStreamFinished: {
                root.maxAvailableCpuString = (parseFloat(outputCollector.text) / 1000).toFixed(0) + " GHz"
            }
        }
    }
}
