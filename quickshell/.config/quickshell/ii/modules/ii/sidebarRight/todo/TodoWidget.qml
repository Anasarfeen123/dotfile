import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property var tabButtonList: [{"icon": "checklist", "name": Translation.tr("Unfinished")}, {"name": Translation.tr("Done"), "icon": "check_circle"}]
    property bool showAddDialog: false
    property int dialogMargins: 20
    property int fabSize: 48
    property int fabMargins: 14
    property int selectedPriority: 1
    property date selectedDueDate

    Keys.onPressed: (event) => {
        if ((event.key === Qt.Key_PageDown || event.key === Qt.Key_PageUp) && event.modifiers === Qt.NoModifier) {
            if (event.key === Qt.Key_PageDown) {
                tabBar.incrementCurrentIndex();
            } else if (event.key === Qt.Key_PageUp) {
                tabBar.decrementCurrentIndex();
            }
            event.accepted = true;
        }
        // Open add dialog on "N" (any modifiers)
        else if (event.key === Qt.Key_N) {
            root.showAddDialog = true
            event.accepted = true;
        }
        // Close dialog on Esc if open
        else if (event.key === Qt.Key_Escape && root.showAddDialog) {
            root.showAddDialog = false
            event.accepted = true;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        SecondaryTabBar {
            id: tabBar
            currentIndex: swipeView.currentIndex

            Repeater {
                model: root.tabButtonList
                delegate: SecondaryTabButton {
                    buttonText: modelData.name
                    buttonIcon: modelData.icon
                }
            }
        }

        SwipeView {
            id: swipeView
            Layout.topMargin: 10
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            clip: true
            currentIndex: tabBar.currentIndex

            // To Do tab
            TaskList {
                listBottomPadding: root.fabSize + root.fabMargins * 2
                emptyPlaceholderIcon: "check_circle"
                emptyPlaceholderText: Translation.tr("Nothing here!")
                taskList: Todo.list
                    .map(function(item, i) { return Object.assign({}, item, {originalIndex: i}); })
                    .filter(function(item) { return !item.done; })
                    .sort(function(a, b) {
                        const dueA = a.dueDate ? new Date(a.dueDate).getTime() : Infinity;
                        const dueB = b.dueDate ? new Date(b.dueDate).getTime() : Infinity;
                        const pa = (a.priority ?? 1) === 2 ? 0 : 1;
                        const pb = (b.priority ?? 1) === 2 ? 0 : 1;
                        if ((a.dueDate ?? "") && (b.dueDate ?? "")) return dueA - dueB;
                        if (a.dueDate) return -1;
                        if (b.dueDate) return 1;
                        if (pa !== pb) return pa - pb;
                        return (a.originalIndex ?? 0) - (b.originalIndex ?? 0);
                    })
            }
            TaskList {
                listBottomPadding: root.fabSize + root.fabMargins * 2
                emptyPlaceholderIcon: "checklist"
                emptyPlaceholderText: Translation.tr("Finished tasks will go here")
                taskList: Todo.list
                    .map(function(item, i) { return Object.assign({}, item, {originalIndex: i}); })
                    .filter(function(item) { return item.done; })
            }

        }
    }

    // + FAB
    StyledRectangularShadow {
        target: fabButton
        radius: fabButton.buttonRadius
        blur: 0.6 * Appearance.sizes.elevationMargin
    }
    FloatingActionButton {
        id: fabButton
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: root.fabMargins
        anchors.bottomMargin: root.fabMargins

        onClicked: root.showAddDialog = true
        iconText: "add"
    }

    Item {
        anchors.fill: parent
        z: 9999

        visible: opacity > 0
        opacity: root.showAddDialog ? 1 : 0
        Behavior on opacity {
            NumberAnimation { 
                duration: Appearance.animation.elementMoveFast.duration
                easing.type: Appearance.animation.elementMoveFast.type
                easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
            }
        }

        onVisibleChanged: {
            if (!visible) {
                todoInput.text = ""
                fabButton.focus = true
            }
        }

        Rectangle { // Scrim
            anchors.fill: parent
            radius: Appearance.rounding.small
            color: Appearance.colors.colScrim
            MouseArea {
                hoverEnabled: true
                anchors.fill: parent
                preventStealing: true
                propagateComposedEvents: false
            }
        }

        Rectangle { // The dialog
            id: dialog
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: root.dialogMargins
            implicitHeight: dialogColumnLayout.implicitHeight

            color: Appearance.m3colors.m3surfaceContainerHigh
            radius: Appearance.rounding.normal

            function addTask() {
                if (todoInput.text.length > 0) {
                    const due = dueCheckBox.checked && dueDateInput.text !== "" ? new Date(dueDateInput.text).toISOString() : "";
                    Todo.addTask(todoInput.text, due, root.selectedPriority)
                    todoInput.text = ""
                    root.showAddDialog = false
                    tabBar.setCurrentIndex(0) // Show unfinished tasks
                }
            }

            ColumnLayout {
                id: dialogColumnLayout
                anchors.fill: parent
                spacing: 16

                StyledText {
                    Layout.topMargin: 16
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.alignment: Qt.AlignLeft
                    color: Appearance.m3colors.m3onSurface
                    font.pixelSize: Appearance.font.pixelSize.larger
                    text: Translation.tr("Add task")
                }

                TextField {
                    id: todoInput
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    padding: 10
                    color: activeFocus ? Appearance.m3colors.m3onSurface : Appearance.m3colors.m3onSurfaceVariant
                    renderType: Text.NativeRendering
                    selectedTextColor: Appearance.m3colors.m3onSecondaryContainer
                    selectionColor: Appearance.colors.colSecondaryContainer
                    placeholderText: Translation.tr("Task description")
                    placeholderTextColor: Appearance.m3colors.m3outline
                    focus: root.showAddDialog
                    onAccepted: dialog.addTask()

                    background: Rectangle {
                        anchors.fill: parent
                        radius: Appearance.rounding.verysmall
                        border.width: 2
                        border.color: todoInput.activeFocus ? Appearance.colors.colPrimary : Appearance.m3colors.m3outline
                        color: "transparent"
                    }

                    cursorDelegate: Rectangle {
                        width: 1
                        color: todoInput.activeFocus ? Appearance.colors.colPrimary : "transparent"
                        radius: 1
                    }
                }

                RowLayout { // Due date + priority
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    spacing: 8

                    CheckBox {
                        id: dueCheckBox
                        text: Translation.tr("Due date")
                        checked: false
                        onToggled: {
                            if (checked && dueDateInput.text === "")
                                dueDateInput.text = new Date().toISOString().slice(0, 10)
                        }
                    }

                    TextField {
                        id: dueDateInput
                        visible: dueCheckBox.checked
                        Layout.fillWidth: true
                        padding: 8
                        placeholderText: "YYYY-MM-DD"
                        placeholderTextColor: Appearance.m3colors.m3outline
                        background: Rectangle {
                            anchors.fill: parent
                            radius: Appearance.rounding.verysmall
                            border.width: 1
                            border.color: Appearance.m3colors.m3outline
                            color: "transparent"
                        }
                    }

                    StyledText {
                        text: Translation.tr("Priority")
                        color: Appearance.m3colors.m3onSurfaceVariant
                    }
                }

                RowLayout {
                    id: priorityRow
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.bottomMargin: 4
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Repeater {
                            model: [
                                { "key": 0, "label": Translation.tr("Low") },
                                { "key": 1, "label": Translation.tr("Normal") },
                                { "key": 2, "label": Translation.tr("High") }
                            ]
                            delegate: Button {
                                required property var modelData
                                text: modelData.label
                                flat: root.selectedPriority !== modelData.key
                                height: 28
                                onClicked: root.selectedPriority = modelData.key
                                contentItem: Text {
                                    text: root.selectedPriority === modelData.key ? Translation.tr("● %1").arg(parent.text) : parent.text
                                    color: root.selectedPriority === modelData.key ? Appearance.m3colors.m3onSecondaryContainer : Appearance.m3colors.m3onSurface
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    radius: Appearance.rounding.verysmall
                                    color: root.selectedPriority === modelData.key ? Appearance.m3colors.m3secondaryContainer : "transparent"
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.bottomMargin: 16
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.alignment: Qt.AlignRight
                    spacing: 5

                    DialogButton {
                        buttonText: Translation.tr("Cancel")
                        onClicked: root.showAddDialog = false
                    }
                    DialogButton {
                        buttonText: Translation.tr("Add")
                        enabled: todoInput.text.length > 0
                        onClicked: dialog.addTask()
                    }
                }
            }
        }
    }
}
