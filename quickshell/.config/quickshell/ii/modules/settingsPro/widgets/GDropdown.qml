import qs.modules.common
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Glass dropdown. Replaces StyledComboBox for long option lists.
ComboBox {
    id: root
    property string buttonIcon: ""

    implicitHeight: 38
    Layout.fillWidth: true

    background: GlassSurface {
        radius: Appearance.rounding.full
        fillOpacity: root.down ? 0.6 : root.hovered ? 0.5 : 0.35
        showSheen: false
        Behavior on fillOpacity { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }

    indicator: GIcon {
        x: root.width - width - 16
        y: root.height / 2 - height / 2
        text: "keyboard_arrow_down"
        size: Appearance.font.pixelSize.larger
        color: Appearance.colors.colOnLayer1
        rotation: root.popup.visible ? 180 : 0
        Behavior on rotation { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this) }
    }

    contentItem: Item {
        implicitWidth: buttonLayout.implicitWidth
        implicitHeight: buttonLayout.implicitHeight

        RowLayout {
            id: buttonLayout
            anchors.fill: parent
            spacing: 8
            anchors.leftMargin: 16
            anchors.rightMargin: 40

            Loader {
                Layout.alignment: Qt.AlignVCenter
                active: root.buttonIcon.length > 0 || (root.currentIndex >= 0 && typeof root.model[root.currentIndex] === 'object' && root.model[root.currentIndex]?.icon)
                visible: active
                sourceComponent: GIcon {
                    text: (root.currentIndex >= 0 && typeof root.model[root.currentIndex] === 'object' && root.model[root.currentIndex]?.icon)
                        ? root.model[root.currentIndex].icon : root.buttonIcon
                    size: Appearance.font.pixelSize.larger
                    color: Appearance.colors.colOnLayer1
                }
            }

            GText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: root.displayText
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    delegate: ItemDelegate {
        id: itemDelegate
        width: ListView.view ? ListView.view.width : root.width
        implicitHeight: 38

        required property var model
        required property int index

        background: Rectangle {
            anchors.fill: parent
            radius: Appearance.rounding.small
            color: root.currentIndex === itemDelegate.index
                ? ColorUtils.applyAlpha(Appearance.colors.colPrimary, itemDelegate.hovered ? 0.3 : 0.22)
                : itemDelegate.hovered ? ColorUtils.applyAlpha(Appearance.m3colors.m3onBackground, 0.08) : "transparent"
            Behavior on color { animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this) }
            MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton; cursorShape: Qt.PointingHandCursor }
        }

        contentItem: RowLayout {
            spacing: 8
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            Loader {
                Layout.alignment: Qt.AlignVCenter
                active: typeof itemDelegate.model === 'object' && itemDelegate.model?.icon?.length > 0
                visible: active
                sourceComponent: GIcon {
                    text: itemDelegate.model?.icon ?? ""
                    size: Appearance.font.pixelSize.larger
                    color: Appearance.colors.colOnLayer1
                }
            }
            GText {
                Layout.fillWidth: true
                text: itemDelegate.model[root.textRole]
                elide: Text.ElideRight
            }
        }
    }

    popup: Popup {
        y: root.height + 6
        width: root.width
        height: Math.min(listView.contentHeight + topPadding + bottomPadding, 320)
        padding: 6

        enter: Transition {
            PropertyAnimation { properties: "opacity"; to: 1; duration: Appearance.animation.elementMoveFast.duration }
        }
        exit: Transition {
            PropertyAnimation { properties: "opacity"; to: 0; duration: Appearance.animation.elementMoveFast.duration }
        }

        background: GlassPane {
            radius: Appearance.rounding.normal
            fillOpacity: 0.75
            shadowBlur: 20
        }

        contentItem: ListView {
            id: listView
            clip: true
            implicitHeight: contentHeight
            spacing: 2
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex
        }
    }
}
