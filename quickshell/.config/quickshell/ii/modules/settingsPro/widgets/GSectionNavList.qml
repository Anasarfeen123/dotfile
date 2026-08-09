import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.functions

// "On this page" in-page section navigation, shown below the main nav items.
// Expanded: a list of section titles. Collapsed: a column of small dots.
ColumnLayout {
    id: root
    property list<string> sectionTitles: []
    property int currentIndex: -1
    property bool selected: false
    signal sectionClicked(int index)

    Layout.fillWidth: true
    Layout.topMargin: 10
    Layout.alignment: Qt.AlignTop
    spacing: 2
    visible: sectionTitles.length > 1

    ColumnLayout {
        visible: root.selected
        Layout.fillWidth: true
        spacing: 2

        GText {
            Layout.leftMargin: 12
            Layout.bottomMargin: 2
            text: Translation.tr("On this page")
            color: Appearance.colors.colOnLayer2
            font {
                pixelSize: Appearance.font.pixelSize.smaller
                weight: Font.DemiBold
            }
        }

        Repeater {
            model: root.sectionTitles
            delegate: GButton {
                required property int index
                required property string modelData
                Layout.fillWidth: true
                implicitHeight: 30
                buttonRadius: Appearance.rounding.small
                toggled: root.currentIndex === index
                primary: false
                baseFillOpacity: toggled ? 0.28 : 0.0
                onClicked: root.sectionClicked(index)

                contentItem: RowLayout {
                    spacing: 6
                    Rectangle {
                        Layout.preferredWidth: 3
                        Layout.preferredHeight: 16
                        radius: Appearance.rounding.full
                        color: toggled ? Appearance.colors.colPrimary : "transparent"
                    }
                    GText {
                        Layout.fillWidth: true
                        text: modelData
                        color: toggled ? Appearance.colors.colOnLayer1 : Appearance.colors.colOnLayer2
                        font.weight: toggled ? Font.DemiBold : Font.Normal
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    ColumnLayout {
        visible: !root.selected
        Layout.alignment: Qt.AlignHCenter
        spacing: 6

        Repeater {
            model: root.sectionTitles
            delegate: Rectangle {
                required property int index
                required property string modelData
                property bool active: root.currentIndex === index
                Layout.alignment: Qt.AlignHCenter
                width: active ? 8 : 5
                height: active ? 8 : 5
                radius: Appearance.rounding.full
                color: active ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer2

                Behavior on width { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }
                Behavior on height { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.sectionClicked(index)
                }
                GTooltip { text: modelData }
            }
        }
    }
}
