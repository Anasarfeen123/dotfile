pragma ComponentBehavior: Bound
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

WindowDialog {
    id: root
    property bool isSink: true
    backgroundHeight: 600

    WindowDialogTitle {
        text: root.isSink ? Translation.tr("Audio output") : Translation.tr("Audio input")
    }

    WindowDialogSeparator {
        Layout.topMargin: -22
        Layout.leftMargin: 0
        Layout.rightMargin: 0
    }

    ConfigSwitch {
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: 4
            rightMargin: 4
        }
        iconSize: Appearance.font.pixelSize.larger
        buttonIcon: root.isSink ? "volume_off" : "mic_off"
        text: root.isSink ? Translation.tr("Mute output") : Translation.tr("Mute input")
        checked: root.isSink ? (Audio.sink?.audio.muted ?? false) : (Audio.source?.audio.muted ?? false)
        onCheckedChanged: {
            if (root.isSink) {
                if (Audio.sink) Audio.sink.audio.muted = checked;
            } else {
                if (Audio.source) Audio.source.audio.muted = checked;
            }
        }
    }

    VolumeDialogContent {
        isSink: root.isSink
    }

    WindowDialogButtonRow {
        DialogButton {
            buttonText: Translation.tr("Details")
            onClicked: {
                Quickshell.execDetached(["bash", "-c", `${Config.options.apps.volumeMixer}`]);
                GlobalStates.sidebarRightOpen = false;
            }
        }

        Item {
            Layout.fillWidth: true
        }

        DialogButton {
            buttonText: Translation.tr("Done")
            onClicked: root.dismiss()
        }
    }
}
