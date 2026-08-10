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
    Layout.topMargin: 12
    Layout.alignment: Qt.AlignTop
    spacing: 4
    visible: sectionTitles.length > 1

    ColumnLayout {
        visible: root.selected
        Layout.fillWidth: true
        spacing: 3

        GText {
            Layout.leftMargin: 12
            Layout.topMargin: 2
            Layout.bottomMargin: 4
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
                implicitHeight: 32
                buttonRadius: Appearance.rounding.normal
                toggled: root.currentIndex === index
                primary: false
                baseFillOpacity: toggled ? 0.34 : 0.0
                onClicked: root.sectionClicked(index)

                contentItem: RowLayout {
                    spacing: 8
                    Rectangle {
                        property real indicatorHeight: toggled ? 18 : 8
                        Layout.preferredWidth: 3
                        Layout.preferredHeight: indicatorHeight
                        radius: Appearance.rounding.full
                        color: toggled ? Appearance.colors.colPrimary : ColorUtils.applyAlpha(Appearance.colors.colOnLayer2, 0.28)
                        opacity: toggled ? 1 : 0.55

                        Behavior on indicatorHeight { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }
                        Behavior on color { animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this) }
                        Behavior on opacity { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }
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
                width: active ? 16 : 6
                height: 6
                radius: Appearance.rounding.full
                color: active ? Appearance.colors.colPrimary : ColorUtils.applyAlpha(Appearance.colors.colOnLayer2, 0.55)

                Behavior on width { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }
                Behavior on color { animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this) }

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
