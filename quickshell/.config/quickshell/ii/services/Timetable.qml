pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import Quickshell;
import Quickshell.Io;
import QtQuick;

/**
 * Weekly timetable/class schedule manager.
 * Each item: { "day": 0-6, "start": "08:30", "end": "09:30", "course": "Math", "room": "A101" }
 */
Singleton {
    id: root
    property var filePath: Directories.timetablePath
    property var list: []

    property var dayNames: [
        Translation.tr("Mon"),
        Translation.tr("Tue"),
        Translation.tr("Wed"),
        Translation.tr("Thu"),
        Translation.tr("Fri"),
        Translation.tr("Sat"),
        Translation.tr("Sun"),
    ]

    function save() {
        root.list = list.slice(0)
        timetableFileView.setText(JSON.stringify(root.list))
    }

    function addEntry(day, start, end, course, room) {
        list.push({ "day": day, "start": start, "end": end, "course": course, "room": room })
        save()
    }

    function removeEntry(entry) {
        const i = list.findIndex(e => e === entry)
        if (i >= 0) {
            list.splice(i, 1)
            save()
        }
    }

    function clearDay(day) {
        root.list = list.filter(e => e.day !== day)
        save()
    }

    function entriesForDay(day) {
        return list
            .filter(e => e.day === day)
            .sort((a, b) => (a.start || "00:00").localeCompare(b.start || "00:00"))
    }

    function refresh() {
        timetableFileView.reload()
    }

    Component.onCompleted: refresh()

    FileView {
        id: timetableFileView
        path: Qt.resolvedUrl(root.filePath)
        onLoaded: {
            root.list = JSON.parse(timetableFileView.text())
            console.log("[Timetable] File loaded")
        }
        onLoadFailed: (error) => {
            if (error == FileViewError.FileNotFound) {
                console.log("[Timetable] File not found, creating new file.")
                root.list = []
                timetableFileView.setText(JSON.stringify(root.list))
            } else {
                console.log("[Timetable] Error loading file: " + error)
            }
        }
    }
}