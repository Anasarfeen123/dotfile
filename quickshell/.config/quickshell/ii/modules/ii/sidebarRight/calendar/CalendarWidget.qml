import qs.services
import qs.modules.common
import qs.modules.common.widgets
import "calendar_layout.js" as CalendarLayout
import QtQuick
import QtQuick.Layouts

Item {
    // Layout.topMargin: 10
    anchors.topMargin: 10
    property int monthShift: 0
    property var viewingDate: CalendarLayout.getDateInXMonthsTime(monthShift)
    property var calendarLayout: CalendarLayout.getCalendarLayout(viewingDate, monthShift === 0)
    width: calendarColumn.width
    implicitHeight: calendarColumn.height + 10 * 2

    Keys.onPressed: (event) => {
        if ((event.key === Qt.Key_PageDown || event.key === Qt.Key_PageUp)
            && event.modifiers === Qt.NoModifier) {
            if (event.key === Qt.Key_PageDown) {
                monthShift++;
            } else if (event.key === Qt.Key_PageUp) {
                monthShift--;
            }
            event.accepted = true;
        }
    }
    MouseArea {
        anchors.fill: parent
        onWheel: (event) => {
            if (event.angleDelta.y > 0) {
                monthShift--;
            } else if (event.angleDelta.y < 0) {
                monthShift++;
            }
        }
    }

    ColumnLayout {
        id: calendarColumn
        anchors.centerIn: parent
        spacing: 5

        // Calendar header
        RowLayout {
            Layout.fillWidth: true
            spacing: 5
            CalendarHeaderButton {
                clip: true
                buttonText: `${monthShift != 0 ? "• " : ""}${viewingDate.toLocaleDateString(Qt.locale(), "MMMM yyyy")}`
                tooltipText: (monthShift === 0) ? "" : Translation.tr("Jump to current month")
                downAction: () => {
                    monthShift = 0;
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: false
            }
            CalendarHeaderButton {
                forceCircle: true
                downAction: () => {
                    monthShift--;
                }
                contentItem: MaterialSymbol {
                    text: "chevron_left"
                    iconSize: Appearance.font.pixelSize.larger
                    horizontalAlignment: Text.AlignHCenter
                    color: Appearance.colors.colOnLayer1
                }
            }
            CalendarHeaderButton {
                forceCircle: true
                downAction: () => {
                    monthShift++;
                }
                contentItem: MaterialSymbol {
                    text: "chevron_right"
                    iconSize: Appearance.font.pixelSize.larger
                    horizontalAlignment: Text.AlignHCenter
                    color: Appearance.colors.colOnLayer1
                }
            }
        }

        // Week days row
        RowLayout {
            id: weekDaysRow
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: false
            spacing: 5
            Repeater {
                model: CalendarLayout.weekDays
                delegate: CalendarDayButton {
                    day: Translation.tr(modelData.day)
                    isToday: modelData.today
                    bold: true
                    enabled: false
                }
            }
        }

        // Real week rows
        Repeater {
            id: calendarRows
            // model: calendarLayout
            model: 6
            delegate: RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillHeight: false
                spacing: 5
                Repeater {
                    model: Array(7).fill(modelData)
                    delegate: CalendarDayButton {
                        day: calendarLayout[modelData][index].day
                        isToday: calendarLayout[modelData][index].today
                    }
                }
            }
        }
    }

    RowLayout { // Google Calendar actions
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.bottomMargin: 8
        spacing: 8

        StyledText {
            Layout.fillWidth: true
            text: Translation.tr("%1 · %2").arg(DateTime.longDate).arg(Todo.upcomingCount() === 0 ? Translation.tr("No deadlines") : Translation.tr("%1 deadlines").arg(Todo.upcomingCount()))
            font.pixelSize: Appearance.font.pixelSize.smallest
            color: Appearance.colors.colSubtext
            elide: Text.ElideRight
        }
        CalendarHeaderButton {
            forceCircle: true
            tooltipText: Translation.tr("Open Google Calendar")
            downAction: () => {
                Quickshell.execDetached(["xdg-open", "https://calendar.google.com"])
            }
            contentItem: MaterialSymbol {
                text: "calendar_add_on"
                iconSize: Appearance.font.pixelSize.larger
                horizontalAlignment: Text.AlignHCenter
                color: Appearance.colors.colOnLayer1
            }
        }
    }
}