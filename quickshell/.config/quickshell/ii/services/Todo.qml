pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import Quickshell;
import Quickshell.Io;
import QtQuick;

/**
 * Simple to-do list manager.
 * Each item is an object with "content", "done", "dueDate" (ISO timestamp or empty)
 * and "priority" (0=low, 1=normal, 2=high) properties.
 */
Singleton {
    id: root
    property var filePath: Directories.todoPath
    property var list: []
    property var deadlineNotificationIds: []
    property bool hasRemindedToday: false

    function todayStart() {
        const d = new Date();
        d.setHours(0, 0, 0, 0);
        return d.getTime();
    }

    function tomorrowISO() {
        const d = new Date();
        d.setDate(d.getDate() + 1);
        d.setHours(0, 0, 0, 0);
        return d.toISOString();
    }

    function addItem(item) {
        list.push(item)
        // Reassign to trigger onListChanged
        root.list = list.slice(0)
        todoFileView.setText(JSON.stringify(root.list))
    }

    function addTask(desc, dueDate = "", priority = 1) {
        const item = {
            "content": desc,
            "done": false,
            "dueDate": dueDate,
            "priority": priority,
        }
        addItem(item)
    }

    function markDone(index) {
        if (index >= 0 && index < list.length) {
            list[index].done = true
            // Reassign to trigger onListChanged
            root.list = list.slice(0)
            todoFileView.setText(JSON.stringify(root.list))
        }
    }

    function markUnfinished(index) {
        if (index >= 0 && index < list.length) {
            list[index].done = false
            // Reassign to trigger onListChanged
            root.list = list.slice(0)
            todoFileView.setText(JSON.stringify(root.list))
        }
    }

    function deleteItem(index) {
        if (index >= 0 && index < list.length) {
            list.splice(index, 1)
            // Reassign to trigger onListChanged
            root.list = list.slice(0)
            todoFileView.setText(JSON.stringify(root.list))
        }
    }

    // Count of unfinished tasks due today or earlier (overdue or due today)
    function upcomingCount() {
        const now = new Date();
        now.setHours(0, 0, 0, 0);
        const todayMs = now.getTime();
        return list.filter(task => {
            if (task.done || !task.dueDate) return false;
            const due = new Date(task.dueDate).getTime();
            return !isNaN(due) && due <= todayMs + 24 * 3600 * 1000;
        }).length;
    }

    // Tasks due today (or overdue) that aren't done
    function dueTodayList() {
        const todayMs = todayStart();
        const tomorrowMs = todayMs + 24 * 3600 * 1000;
        return list.filter(task => {
            if (task.done || !task.dueDate) return false;
            const due = new Date(task.dueDate).getTime();
            return !isNaN(due) && due >= todayMs && due < tomorrowMs;
        }).map(task => task.content);
    }

    function overdueList() {
        const todayMs = todayStart();
        return list.filter(task => {
            if (task.done || !task.dueDate) return false;
            const due = new Date(task.dueDate).getTime();
            return !isNaN(due) && due < todayMs;
        }).map(task => task.content);
    }

    function setDueDate(index, dueDate) {
        if (index >= 0 && index < list.length) {
            list[index].dueDate = dueDate;
            root.list = list.slice();
            todoFileView.setText(JSON.stringify(root.list));
        }
    }

    function setPriority(index, priority) {
        if (index >= 0 && index < list.length) {
            list[index].priority = priority;
            root.list = list.slice();
            todoFileView.setText(JSON.stringify(root.list));
        }
    }

    function refresh() {
        todoFileView.reload()
    }

    function checkDeadlines() {
        const now = new Date();
        if (root.hasRemindedToday && now.getHours() === 0) root.hasRemindedToday = false;
        if (root.hasRemindedToday) return;
        const dueToday = root.dueTodayList();
        const overdue = root.overdueList();
        if (dueToday.length === 0 && overdue.length === 0) return;
        root.hasRemindedToday = true;
        const lines = [];
        if (dueToday.length > 0) lines.push(`${dueToday.length} task(s) due today`);
        if (overdue.length > 0) lines.push(`${overdue.length} overdue`);
        Quickshell.execDetached(["notify-send", "-a", "Planner", "-i", "deadline", "Deadlines", lines.join(" · ")]);
    }

    Timer {
        id: deadlineTimer
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.checkDeadlines()
    }

    Component.onCompleted: {
        refresh()
        root.checkDeadlines()
    }

    FileView {
        id: todoFileView
        path: Qt.resolvedUrl(root.filePath)
        onLoaded: {
            const fileContents = todoFileView.text()
            root.list = JSON.parse(fileContents)
            console.log("[To Do] File loaded")
        }
        onLoadFailed: (error) => {
            if(error == FileViewError.FileNotFound) {
                console.log("[To Do] File not found, creating new file.")
                root.list = []
                todoFileView.setText(JSON.stringify(root.list))
            } else {
                console.log("[To Do] Error loading file: " + error)
            }
        }
    }
}

