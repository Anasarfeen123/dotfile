import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services

/**
 * In-page section navigation shown in the nav rail below the categories.
 * Expanded mode lists section titles; collapsed (narrow window) mode shows
 * a vertical stack of clickable dots so navigation still works in windowed mode.
 */
ColumnLayout {
    id: root
    property list<string> sectionTitles: []
    property int currentIndex: -1
    property bool selected: false
    signal sectionClicked(int index)

    Layout.fillWidth: true
    Layout.topMargin: 12
    Layout.alignment: Qt.AlignTop
    spacing: 2
    visible: sectionTitles.length > 1

    // Expanded list
    ColumnLayout {
        visible: root.selected
        Layout.fillWidth: true
        spacing: 2

        StyledText {
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
            SectionNavItem {
                required property int index
                required property string modelData
                label: modelData
                toggled: root.currentIndex === index
                Layout.fillWidth: true
                onClicked: root.sectionClicked(index)
            }
        }
    }

    // Collapsed dot indicators (windowed mode)
    ColumnLayout {
        visible: !root.selected
        Layout.alignment: Qt.AlignHCenter
        spacing: 6

        Repeater {
            model: root.sectionTitles
            SectionDot {
                required property int index
                active: root.currentIndex === index
                Layout.alignment: Qt.AlignHCenter
                onClicked: root.sectionClicked(index)
                StyledToolTip {
                    text: (root.sectionTitles[index] || "")
                }
            }
        }
    }

    component SectionNavItem: RippleButton {
        id: item
        property string label
        property bool toggled: false
        Layout.fillWidth: true
        Layout.preferredHeight: 30
        colBackground: "transparent"
        colBackgroundHover: Appearance.colors.colLayer1Hover
        colBackgroundToggled: Appearance.colors.colSecondaryContainer
        colBackgroundToggledHover: Appearance.colors.colSecondaryContainerHover
        colRipple: Appearance.colors.colLayer1Active
        colRippleToggled: Appearance.colors.colSecondaryContainerActive

        contentItem: RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Rectangle {
                Layout.preferredWidth: 3
                Layout.preferredHeight: 16
                radius: Appearance.rounding.full
                color: toggled ? Appearance.colors.colPrimary : "transparent"
            }
            StyledText {
                Layout.fillWidth: true
                text: label
                color: toggled ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnLayer1
                font {
                    pixelSize: Appearance.font.pixelSize.small
                    weight: toggled ? Font.DemiBold : Font.Normal
                }
                elide: Text.ElideRight
            }
        }
    }

    component SectionDot: RippleButton {
        id: dot
        property bool active: false
        implicitWidth: 20
        implicitHeight: 8
        buttonRadius: Appearance.rounding.full
        colBackground: "transparent"
        colBackgroundHover: "transparent"
        colRipple: Appearance.colors.colLayer1Active

        Rectangle {
            anchors.centerIn: parent
            width: dot.active ? 8 : 5
            height: dot.active ? 8 : 5
            radius: Appearance.rounding.full
            color: dot.active ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer2
            Behavior on width {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }
            Behavior on height {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }
            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
        }
    }
}