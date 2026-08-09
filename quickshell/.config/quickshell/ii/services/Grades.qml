pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import Quickshell;
import Quickshell.Io;
import QtQuick;

/**
 * Assignment / grade tracker.
 * Each item: { "course": "Math", "name": "HW1", "score": 90, "max": 100, "weight": 0.2 }
 */
Singleton {
    id: root
    property var filePath: Directories.gradesPath
    property var list: []
    property int revision: 0 // Incremented to force UI refresh

    function save() {
        root.list = list.slice(0)
        root.revision++
        gradesFileView.setText(JSON.stringify(root.list))
    }

    function addGrade(course, name, score, max, weight) {
        list.push({ "course": course, "name": name, "score": score, "max": max ?? 100, "weight": weight ?? 1 })
        save()
    }

    function removeGrade(index) {
        if (index >= 0 && index < list.length) {
            list.splice(index, 1)
            save()
        }
    }

    // Course names, sorted alphabetically
    function courses() {
        return [...new Set(list.map(g => g.course))].sort()
    }

    // Weighted percentage average for a course, or overall if course is undefined
    function average(course) {
        const entries = course === undefined ? list : list.filter(g => g.course === course)
        if (entries.length === 0) return null
        let totalPoints = 0, totalWeight = 0
        entries.forEach(g => {
            const pct = (g.max > 0) ? (g.score / g.max) * 100 : 0
            totalPoints += pct * (g.weight ?? 1)
            totalWeight += (g.weight ?? 1)
        })
        return totalWeight > 0 ? totalPoints / totalWeight : 0
    }

    function currentSemesterAverage() {
        return root.average(undefined)
    }

    function refresh() {
        gradesFileView.reload()
    }

    Component.onCompleted: refresh()

    FileView {
        id: gradesFileView
        path: Qt.resolvedUrl(root.filePath)
        onLoaded: {
            root.list = JSON.parse(gradesFileView.text())
            console.log("[Grades] File loaded")
        }
        onLoadFailed: (error) => {
            if (error == FileViewError.FileNotFound) {
                console.log("[Grades] File not found, creating new file.")
                root.list = []
                gradesFileView.setText(JSON.stringify(root.list))
            } else {
                console.log("[Grades] Error loading file: " + error)
            }
        }
    }
}