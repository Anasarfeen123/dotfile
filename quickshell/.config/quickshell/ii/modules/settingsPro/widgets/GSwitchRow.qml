import qs.modules.common
import qs.modules.common.widgets as CW
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// Icon + label + toggle row. Replaces ConfigSwitch, whole row is clickable.
GButton {
    id: root
    property string buttonIcon
    property alias iconSize2: rowIcon.size

    Layout.fillWidth: true
    implicitHeight: rowContent.implicitHeight + 16
    buttonRadius: Appearance.rounding.small

    property var flashBaseValue: null
    Component.onCompleted: flashBaseValue = root.checked
    onCheckedChanged: {
        if (root.flashBaseValue === null) { root.flashBaseValue = root.checked; return }
        if (root.checked !== root.flashBaseValue) flashAnim.restart()
        root.flashBaseValue = root.checked
    }
    SequentialAnimation {
        id: flashAnim
        NumberAnimation { target: rowContent; property: "opacity"; from: 0.5; to: 1; duration: 200; easing.type: Easing.OutQuad }
    }

    onClicked: checked = !checked

    contentItem: RowLayout {
        id: rowContent
        spacing: 10
        GIcon {
            id: rowIcon
            visible: root.buttonIcon.length > 0
            text: root.buttonIcon
            size: Appearance.font.pixelSize.larger
            color: root.contentColor
            opacity: root.enabled ? 1 : 0.4
        }
        GText {
            Layout.fillWidth: true
            text: root.buttonText
            color: root.contentColor
            opacity: root.enabled ? 1 : 0.4
        }
        GToggle {
            checked: root.checked
            onClicked: root.clicked()
        }
    }
}
