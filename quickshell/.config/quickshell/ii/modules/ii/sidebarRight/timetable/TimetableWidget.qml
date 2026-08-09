import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    property bool showAddDialog: false
    property int dialogMargins: 20
    property int fabMargins: 14
    property int fabSize: 40
    property int selectedDay: (new Date().getDay() + 6) % 7 // Mon=0 ... Sun=6
    property var selectedEntries: Timetable.entriesForDay(root.selectedDay)

    Connections {
        target: Timetable
        function onListChanged() {
            root.selectedEntries = Timetable.entriesForDay(root.selectedDay)
        }
    }
    onSelectedDayChanged: {
        root.selectedEntries = Timetable.entriesForDay(root.selectedDay)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        SecondaryTabBar {
            id: dayBar
            Layout.fillWidth: true
            Layout.topMargin: 4
            currentIndex: root.selectedDay
            onCurrentIndexChanged: root.selectedDay = dayBar.currentIndex
            Repeater {
                model: Timetable.dayNames
                delegate: SecondaryTabButton {
                    required property int index
                    required property string modelData
                    buttonText: modelData
                    onPressed: root.selectedDay = index
                }
            }
        }

        StyledListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 8
            spacing: 5
            model: ScriptModel {
                values: root.selectedEntries
            }
            delegate: Item {
                required property var modelData
                required property int index
                implicitHeight: 58
                width: ListView.view.width
                Rectangle {
                    anchors.fill: parent
                    radius: Appearance.rounding.small
                    color: Appearance.colors.colLayer2
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        StyledText {
                            id: timeText
                            text: `${modelData.start || "--:--"} – ${modelData.end || "--:--"}`
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.colSubtext
                            Layout.preferredWidth: 110
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            StyledText {
                                text: modelData.course
                                font.weight: Font.DemiBold
                                font.pixelSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colOnLayer1
                                elide: Text.ElideRight
                            }
                            StyledText {
                                text: modelData.room ? Translation.tr("Room %1").arg(modelData.room) : ""
                                font.pixelSize: Appearance.font.pixelSize.smallest
                                color: Appearance.colors.colSubtext
                            }
                        }
                        Button {
                            flat: true
                            implicitWidth: 28
                            implicitHeight: 28
                            onClicked: Timetable.removeEntry(modelData)
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                text: "close"
                                iconSize: 16
                                horizontalAlignment: Text.AlignHCenter
                                color: Appearance.colors.colSubtext
                            }
                        }
                    }
                }
            }
        }

        Item {
            // Placeholder when the selected day has no classes
            anchors.fill: parent
            visible: root.selectedEntries.length === 0
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 5
                MaterialSymbol {
                    Layout.alignment: Qt.AlignHCenter
                    iconSize: 45
                    color: Appearance.m3colors.m3outline
                    text: "calendar_view_month"
                }
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.m3colors.m3outline
                    text: Translation.tr("No classes this day")
                }
            }
        }
    }

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
                courseInput.text = ""
                roomInput.text = ""
                startInput.text = ""
                endInput.text = ""
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

        Rectangle { // Dialog
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: root.dialogMargins
            implicitHeight: dialogColumn.implicitHeight
            color: Appearance.m3colors.m3surfaceContainerHigh
            radius: Appearance.rounding.normal

            ColumnLayout {
                id: dialogColumn
                anchors.fill: parent
                spacing: 12

                StyledText {
                    Layout.topMargin: 16
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.alignment: Qt.AlignLeft
                    color: Appearance.m3colors.m3onSurface
                    font.pixelSize: Appearance.font.pixelSize.larger
                    text: Translation.tr("Add class")
                }

                TextField {
                    id: courseInput
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    padding: 10
                    color: Appearance.m3colors.m3onSurface
                    placeholderText: Translation.tr("Course name")
                    placeholderTextColor: Appearance.m3colors.m3outline
                    background: Rectangle {
                        anchors.fill: parent
                        radius: Appearance.rounding.verysmall
                        border.width: 1
                        border.color: Appearance.m3colors.m3outline
                        color: "transparent"
                    }
                }

                TextField {
                    id: roomInput
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    padding: 10
                    color: Appearance.m3colors.m3onSurface
                    placeholderText: Translation.tr("Room (optional)")
                    placeholderTextColor: Appearance.m3colors.m3outline
                    background: Rectangle {
                        anchors.fill: parent
                        radius: Appearance.rounding.verysmall
                        border.width: 1
                        border.color: Appearance.m3colors.m3outline
                        color: "transparent"
                    }
                }

                RowLayout {
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    spacing: 10
                    TextField {
                        id: startInput
                        Layout.fillWidth: true
                        placeholderText: Translation.tr("Start e.g. 08:30")
                        placeholderTextColor: Appearance.m3colors.m3outline
                        color: Appearance.m3colors.m3onSurface
                        padding: 8
                    }
                    TextField {
                        id: endInput
                        Layout.fillWidth: true
                        placeholderText: Translation.tr("End e.g. 09:30")
                        placeholderTextColor: Appearance.m3colors.m3outline
                        color: Appearance.m3colors.m3onSurface
                        padding: 8
                    }
                }

                RowLayout {
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.alignment: Qt.AlignRight
                    Layout.bottomMargin: 16
                    spacing: 6
                    DialogButton {
                        buttonText: Translation.tr("Cancel")
                        onClicked: root.showAddDialog = false
                    }
                    DialogButton {
                        buttonText: Translation.tr("Add")
                        enabled: courseInput.text.length > 0 && startInput.text.length > 0
                        onClicked: {
                            Timetable.addEntry(root.selectedDay, startInput.text, endInput.text, courseInput.text, roomInput.text)
                            root.showAddDialog = false
                        }
                    }
                }
            }
        }
    }
}