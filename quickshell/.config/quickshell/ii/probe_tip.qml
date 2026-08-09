import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Window {
    visible: false
    width: 300; height: 300

    ColumnLayout {
        anchors.fill: parent
        RowLayout {
            Layout.fillWidth: true
            ConfigSwitch {
                id: sw
                buttonIcon: "mouse"
                text: "Test switch"
                StyledToolTip {
                    id: swTip
                    text: "switch tooltip"
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            ConfigSpinBox {
                id: sb
                icon: "mouse"
                text: "Test spin"
                value: 120
                StyledToolTip {
                    id: sbTip
                    text: "spin tooltip"
                }
            }
        }
        Item { width: 1; height: 1 }
    }

    Timer {
        interval: 800
        repeat: true
        running: true
        onTriggered: {
            console.log("SW_TIP_VISIBLE=" + swTip.visible + " SW_HOVER=" + swTip.hoverHandler.hovered)
            console.log("SB_TIP_VISIBLE=" + sbTip.visible + " SB_HOVER=" + sbTip.hoverHandler.hovered)
            console.log("SW_GEO=" + sw.x + "," + sw.width + " SB_GEO=" + sb.x + "," + sb.width)
        }
    }
}
