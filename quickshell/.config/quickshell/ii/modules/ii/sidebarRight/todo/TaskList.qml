import qs.modules.common
import qs.modules.common.widgets
import qs.services
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    required property var taskList
    property string emptyPlaceholderIcon
    property string emptyPlaceholderText
    property int todoListItemSpacing: 5
    property int todoListItemPadding: 8
    property int listBottomPadding: 80

    StyledListView {
        id: listView
        anchors.fill: parent
        spacing: root.todoListItemSpacing
        animateAppearance: false
        model: ScriptModel {
            values: root.taskList
        }
        delegate: Item {
            id: todoItem
            required property var modelData
            property bool pendingDoneToggle: false
            property bool pendingDelete: false
            property bool enableHeightAnimation: false

            implicitHeight: todoItemRectangle.implicitHeight
            width: ListView.view.width
            clip: true

            Behavior on implicitHeight {
                enabled: enableHeightAnimation
                NumberAnimation {
                    duration: Appearance.animation.elementMoveFast.duration
                    easing.type: Appearance.animation.elementMoveFast.type
                    easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
                }
            }

            Rectangle {
                id: todoItemRectangle
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                implicitHeight: todoContentRowLayout.implicitHeight
                color: Appearance.colors.colLayer2
                radius: Appearance.rounding.small

                ColumnLayout {
                    id: todoContentRowLayout
                    anchors.left: parent.left
                    anchors.right: parent.right

                    StyledText {
                        id: todoContentText
                        Layout.fillWidth: true // Needed for wrapping
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        Layout.topMargin: todoListItemPadding
                        text: todoItem.modelData.content
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        maximumLineCount: 3
                    }
                    RowLayout { // Due date + priority
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        Layout.fillWidth: true
                        spacing: 5
                        visible: (todoItem.modelData.dueDate ?? "") !== "" || (todoItem.modelData.priority ?? 1) !== 1
                        StyledText {
                            Layout.fillWidth: true
                            visible: (todoItem.modelData.dueDate ?? "") !== ""
                            text: {
                                const due = new Date(todoItem.modelData.dueDate);
                                if (isNaN(due.getTime())) return "";
                                const today = new Date(); today.setHours(0,0,0,0);
                                const dueMs = due.getTime();
                                const todayMs = today.getTime();
                                if (dueMs < todayMs) return Translation.tr("⚠️ Overdue · %1").arg(due.toLocaleDateString());
                                if (dueMs < todayMs + 86400000) return Translation.tr("Today");
                                return "🗓 " + due.toLocaleDateString();
                            }
                            font.pixelSize: Appearance.font.pixelSize.smallest
                            color: {
                                const due = new Date(todoItem.modelData.dueDate);
                                const today = new Date(); today.setHours(0,0,0,0);
                                const overdue = !isNaN(due.getTime()) && due.getTime() < today.getTime();
                                if (overdue) return Appearance.colors.colError;
                                if (due.getTime() < today.getTime() + 86400000) return Appearance.colors.colPrimary;
                                return Appearance.colors.colSubtext;
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        StyledText {
                            visible: (todoItem.modelData.priority ?? 1) !== 1
                            text: (todoItem.modelData.priority ?? 1) >= 2 ? Translation.tr("High") : Translation.tr("Low")
                            font.pixelSize: Appearance.font.pixelSize.smallest
                            font.weight: Font.DemiBold
                            color: (todoItem.modelData.priority ?? 1) >= 2 ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
                        }
                    }
                    RowLayout {
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        Layout.bottomMargin: todoListItemPadding
                        Item {
                            Layout.fillWidth: true
                        }
                        TodoItemActionButton {
                            Layout.fillWidth: false
                            onClicked: {
                                if (!todoItem.modelData.done)
                                    Todo.markDone(todoItem.modelData.originalIndex);
                                else
                                    Todo.markUnfinished(todoItem.modelData.originalIndex);
                            }
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                text: todoItem.modelData.done ? "remove_done" : "check"
                                iconSize: Appearance.font.pixelSize.larger
                                color: Appearance.colors.colOnLayer1
                            }
                        }
                        TodoItemActionButton {
                            Layout.fillWidth: false
                            onClicked: {
                                Todo.deleteItem(todoItem.modelData.originalIndex);
                            }
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                text: "delete_forever"
                                iconSize: Appearance.font.pixelSize.larger
                                color: Appearance.colors.colOnLayer1
                            }
                        }
                    }
                }
            }
        }
    }

    Item {
        // Placeholder when list is empty
        visible: opacity > 0
        opacity: taskList.length === 0 ? 1 : 0
        anchors.fill: parent

        Behavior on opacity {
            animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 5

            MaterialSymbol {
                Layout.alignment: Qt.AlignHCenter
                iconSize: 55
                color: Appearance.m3colors.m3outline
                text: emptyPlaceholderIcon
            }
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Appearance.font.pixelSize.normal
                color: Appearance.m3colors.m3outline
                horizontalAlignment: Text.AlignHCenter
                text: emptyPlaceholderText
            }
        }
    }
}
