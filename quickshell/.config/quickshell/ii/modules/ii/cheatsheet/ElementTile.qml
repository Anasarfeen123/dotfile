import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RippleButton {
    id: root
    required property var element
    readonly property bool isReal: element.type != "empty"
    opacity: isReal ? 1 : 0
    enabled: isReal
    implicitHeight: 70
    implicitWidth: 70
    colBackground: Appearance.colors.colLayer2
    buttonRadius: Appearance.rounding.small

    onClicked: detailPopup.open()

    StyledToolTip {
        text: `${root.element.name} (${root.element.symbol}) • ${root.element.type}\n${Translation.tr("Click for details")}`
        extraVisibleCondition: root.isReal
    }

    // Full element details on click — previously these tiles rippled on
    // press like a button but did nothing, which is more misleading than
    // just not being clickable.
    Popup {
        id: detailPopup
        y: root.height + 6
        x: (root.width - width) / 2
        modal: false
        focus: false
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
        padding: 14

        background: Rectangle {
            color: Appearance.m3colors.m3surfaceContainer
            radius: Appearance.rounding.normal
            border.width: 1
            border.color: Appearance.colors.colLayer0Border
        }

        contentItem: ColumnLayout {
            spacing: 4

            StyledText {
                text: root.element.name
                font.pixelSize: Appearance.font.pixelSize.large
                font.weight: Font.DemiBold
                color: Appearance.colors.colOnLayer0
            }
            StyledText {
                text: Translation.tr("Symbol: %1").arg(root.element.symbol)
                color: Appearance.colors.colSubtext
            }
            StyledText {
                text: Translation.tr("Atomic number: %1").arg(root.element.number)
                color: Appearance.colors.colSubtext
            }
            StyledText {
                text: Translation.tr("Atomic weight: %1").arg(root.element.weight)
                color: Appearance.colors.colSubtext
            }
            StyledText {
                text: Translation.tr("Category: %1").arg(root.element.type)
                color: Appearance.colors.colSubtext
            }
        }
    }

    Rectangle {
        anchors {
            top: parent.top
            left: parent.left
            topMargin: 4
            leftMargin: 4
        }
        color: ColorUtils.transparentize(Appearance.colors.colLayer2)
        radius: Appearance.rounding.full
        implicitWidth: Math.max(20, elementNumber.implicitWidth)
        implicitHeight: Math.max(20, elementNumber.implicitHeight)
        width: height

        StyledText {
            id: elementNumber
            anchors.left: parent.left
            color: Appearance.colors.colOnLayer2
            text: root.element.number
            font.pixelSize: Appearance.font.pixelSize.smallest
        }
    }

    Rectangle {
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 4
            rightMargin: 4
        }
        color: ColorUtils.transparentize(Appearance.colors.colLayer2)
        radius: Appearance.rounding.full
        implicitWidth: Math.max(20, elementWeight.implicitWidth)
        implicitHeight: Math.max(20, elementWeight.implicitHeight)
        width: height

        StyledText {
            id: elementWeight
            anchors.right: parent.right
            color: Appearance.colors.colOnLayer2
            text: root.element.weight
            font.pixelSize: Appearance.font.pixelSize.smallest
        }
    }

    StyledText {
        id: elementSymbol
        anchors.centerIn: parent
        color: Appearance.colors.colSecondary
        font.pixelSize: Appearance.font.pixelSize.huge
        text: root.element.symbol
    }

    StyledText {
        id: elementName
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 4
        }
        font.pixelSize: Appearance.font.pixelSize.smallest
        color: Appearance.colors.colOnLayer2
        text: root.element.name
    }
}
