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
    property var courseValues: Grades.revision !== -1 ? Grades.courses() : []

    Connections {
        target: Grades
        function onRevisionChanged() {
            root.courseValues = Grades.courses()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        // Semester average card
        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 4
            radius: Appearance.rounding.normal
            color: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.12)
            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    StyledText {
                        text: Translation.tr("Semester average")
                        font.pixelSize: Appearance.font.pixelSize.smallest
                        color: Appearance.colors.colSubtext
                    }
                    StyledText {
                        text: root.formatAverage(Grades.currentSemesterAverage())
                        font.pixelSize: Appearance.font.pixelSize.larger
                        font.weight: Font.DemiBold
                        color: Appearance.colors.colPrimary
                    }
                }
                StyledText {
                    text: Translation.tr("%1 assignments").arg(Grades.list.length)
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    color: Appearance.colors.colSubtext
                }
            }
        }

        // Course breakdown
        StyledListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6
            model: ScriptModel {
                values: root.courseValues
            }
            delegate: Item {
                required property string modelData
                required property int index
                implicitHeight: 64
                width: ListView.view.width
                Rectangle {
                    id: courseCard
                    implicitHeight: 64
                    anchors.fill: parent
                    radius: Appearance.rounding.small
                    color: Appearance.colors.colLayer2
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 4
                        RowLayout {
                            Layout.fillWidth: true
                            StyledText {
                                Layout.fillWidth: true
                                text: modelData
                                font.weight: Font.DemiBold
                                font.pixelSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colOnLayer1
                            }
                            StyledText {
                                text: root.formatAverage(Grades.average(modelData))
                                font.weight: Font.DemiBold
                                font.pixelSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colPrimary
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            StyledText {
                                Layout.fillWidth: true
                                text: root.gradeCountText(modelData)
                                font.pixelSize: Appearance.font.pixelSize.smallest
                                color: Appearance.colors.colSubtext
                            }
                        }
                    }
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
                nameInput.text = ""
                scoreInput.text = ""
                maxInput.text = ""
                weightInput.text = ""
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
                    color: Appearance.m3colors.m3onSurface
                    font.pixelSize: Appearance.font.pixelSize.larger
                    text: Translation.tr("Add grade")
                }

                TextField {
                    id: courseInput
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.fillWidth: true
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
                    id: nameInput
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.fillWidth: true
                    padding: 10
                    color: Appearance.m3colors.m3onSurface
                    placeholderText: Translation.tr("Assignment name")
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
                        id: scoreInput
                        Layout.fillWidth: true
                        placeholderText: Translation.tr("Score")
                        placeholderTextColor: Appearance.m3colors.m3outline
                        color: Appearance.m3colors.m3onSurface
                        padding: 8
                    }
                    TextField {
                        id: maxInput
                        Layout.fillWidth: true
                        placeholderText: Translation.tr("Max (100)")
                        placeholderTextColor: Appearance.m3colors.m3outline
                        color: Appearance.m3colors.m3onSurface
                        padding: 8
                    }
                }

                TextField {
                    id: weightInput
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.fillWidth: true
                    padding: 8
                    color: Appearance.m3colors.m3onSurface
                    placeholderText: Translation.tr("Weight (default 1)")
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
                    Layout.alignment: Qt.AlignRight
                    Layout.bottomMargin: 16
                    spacing: 6
                    DialogButton {
                        buttonText: Translation.tr("Cancel")
                        onClicked: root.showAddDialog = false
                    }
                    DialogButton {
                        buttonText: Translation.tr("Add")
                        enabled: courseInput.text.length > 0 && scoreInput.text.length > 0
                        onClicked: {
                            Grades.addGrade(courseInput.text, nameInput.text, parseFloat(scoreInput.text) || 0, parseFloat(maxInput.text) || 100, parseFloat(weightInput.text) || 1)
                            root.showAddDialog = false
                        }
                    }
                }
            }
        }
    }

    function formatAverage(avg) {
        if (avg === null || avg === undefined || isNaN(avg)) return "—"
        const grade = avg >= 90 ? "A" : avg >= 80 ? "B" : avg >= 70 ? "C" : avg >= 60 ? "D" : "F"
        return `${grade} (${avg.toFixed(1)}%)`
    }
    function gradeCountText(course) {
        const n = Grades.list.filter(g => g.course === course).length
        return n === 1 ? Translation.tr("1 assignment") : Translation.tr("%1 assignments").arg(n)
    }
}