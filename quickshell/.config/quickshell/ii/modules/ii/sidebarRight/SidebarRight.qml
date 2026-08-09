import qs
import qs.services
import qs.modules.common
import QtQuick
import Quickshell.Io
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root

    PanelWindow {
        id: panelWindow
        visible: GlobalStates.sidebarRightOpen

        property bool extend: false
        property int sidebarWidth: panelWindow.extend ? Appearance.sizes.sidebarWidthExtended : Appearance.sizes.sidebarWidth

        function hide() {
            GlobalStates.sidebarRightOpen = false;
        }

        exclusiveZone: 0
        implicitWidth: Appearance.sizes.sidebarWidthExtended + Appearance.sizes.elevationMargin
        WlrLayershell.namespace: "quickshell:sidebarRight"
        WlrLayershell.keyboardFocus: GlobalStates.sidebarRightOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        color: "transparent"

        mask: Region {
            item: sidebarContentLoader.item?.contentBackground ?? sidebarContentLoader
        }

        anchors {
            top: true
            right: true
            bottom: true
        }

        onVisibleChanged: {
            if (visible) {
                GlobalFocusGrab.addDismissable(panelWindow);
            } else {
                GlobalFocusGrab.removeDismissable(panelWindow);
            }
        }
        Connections {
            target: GlobalFocusGrab
            function onDismissed() {
                panelWindow.hide();
            }
        }

        Loader {
            id: sidebarContentLoader
            active: GlobalStates.sidebarRightOpen || Config?.options.sidebar.keepRightSidebarLoaded
            anchors {
                top: parent.top
                right: parent.right
                bottom: parent.bottom
            }
            width: panelWindow.sidebarWidth - Appearance.sizes.hyprlandGapsOut
            height: parent.height - Appearance.sizes.hyprlandGapsOut * 2
            anchors.topMargin: Appearance.sizes.hyprlandGapsOut
            anchors.bottomMargin: Appearance.sizes.hyprlandGapsOut

            Behavior on width {
                animation: Appearance.animation.elementMoveSmall.numberAnimation.createObject(this)
            }

            focus: GlobalStates.sidebarRightOpen
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    panelWindow.hide();
                }
                if (event.modifiers === Qt.ControlModifier && event.key === Qt.Key_O) {
                    panelWindow.extend = !panelWindow.extend;
                    event.accepted = true;
                }
            }

            sourceComponent: SidebarRightContent {}
        }
    }

    IpcHandler {
        target: "sidebarRight"

        function toggle(): void {
            GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen;
        }

        function close(): void {
            GlobalStates.sidebarRightOpen = false;
        }

        function open(): void {
            GlobalStates.sidebarRightOpen = true;
        }
    }

    GlobalShortcut {
        name: "sidebarRightToggle"
        description: "Toggles right sidebar on press"

        onPressed: {
            GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen;
        }
    }
    GlobalShortcut {
        name: "sidebarRightOpen"
        description: "Opens right sidebar on press"

        onPressed: {
            GlobalStates.sidebarRightOpen = true;
        }
    }
    GlobalShortcut {
        name: "sidebarRightClose"
        description: "Closes right sidebar on press"

        onPressed: {
            GlobalStates.sidebarRightOpen = false;
        }
    }
}
