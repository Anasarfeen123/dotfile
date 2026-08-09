import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import Qt.labs.synchronizer
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: overviewScope
    property bool dontAutoCancelSearch: false

    PanelWindow {
        id: panelWindow
        property string searchingText: ""
        readonly property HyprlandMonitor monitor: Hyprland.monitorFor(panelWindow.screen)
        property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)

        // Kept mapped a beat past overviewOpen going false so the exit
        // animation on columnLayout below has time to actually play —
        // otherwise the surface unmaps instantly and cuts the fade off.
        readonly property bool wantsOpen: GlobalStates.overviewOpen
        property bool closing: false
        visible: wantsOpen || closing

        onWantsOpenChanged: {
            closeTimer.stop();
            closing = wantsOpen ? false : true;
            if (closing) closeTimer.start();
        }

        Timer {
            id: closeTimer
            interval: Appearance.animation.elementMoveExit.duration + 30
            onTriggered: panelWindow.closing = false
        }

        WlrLayershell.namespace: "quickshell:overview"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: GlobalStates.overviewOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        color: "transparent"

        mask: Region {
            item: GlobalStates.overviewOpen ? revealClip : null
        }

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        Connections {
            target: GlobalStates
            function onOverviewOpenChanged() {
                if (!GlobalStates.overviewOpen) {
                    searchWidget.disableExpandAnimation();
                    overviewScope.dontAutoCancelSearch = false;
                    GlobalFocusGrab.dismiss();
                } else {
                    if (!overviewScope.dontAutoCancelSearch) {
                        searchWidget.cancelSearch();
                    }
                    GlobalFocusGrab.addDismissable(panelWindow);
                }
            }
        }

        Connections {
            target: GlobalFocusGrab
            function onDismissed() {
                GlobalStates.overviewOpen = false;
            }
        }
        implicitWidth: columnLayout.implicitWidth
        implicitHeight: columnLayout.implicitHeight

        function setSearchingText(text) {
            searchWidget.setSearchingText(text);
            searchWidget.focusFirstItem();
        }

        // Clips columnLayout to an animated height instead of scaling/fading
        // it: a literal curtain dropping down from the top edge (the bar),
        // which reads unambiguously as "growing out of the bar" rather than
        // just a fade. The actual window stays full-sized underneath (see
        // implicitWidth/implicitHeight above) so the Wayland surface itself
        // never resizes — only this wrapper's clip height animates.
        Item {
            id: revealClip
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }
            width: columnLayout.implicitWidth
            height: panelWindow.wantsOpen ? columnLayout.implicitHeight : 0
            clip: true

            Behavior on height {
                NumberAnimation {
                    duration: panelWindow.wantsOpen ? Appearance.animation.elementMoveEnter.duration : Appearance.animation.elementMoveExit.duration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: panelWindow.wantsOpen ? Appearance.animationCurves.emphasizedDecel : Appearance.animationCurves.emphasizedAccel
                }
            }

            Column {
                id: columnLayout
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                }
                spacing: -8

                // A light fade on top of the height-reveal just softens the
                // unmasking edge; it's not the primary motion cue here.
                opacity: panelWindow.wantsOpen ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: panelWindow.wantsOpen ? Appearance.animation.elementMoveEnter.duration : Appearance.animation.elementMoveExit.duration
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: panelWindow.wantsOpen ? Appearance.animationCurves.emphasizedDecel : Appearance.animationCurves.emphasizedAccel
                    }
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        GlobalStates.overviewOpen = false;
                    }
                }

                SearchWidget {
                    id: searchWidget
                    anchors.horizontalCenter: parent.horizontalCenter
                    Synchronizer on searchingText {
                        property alias source: panelWindow.searchingText
                    }
                }

                Loader {
                    id: overviewLoader
                    anchors.horizontalCenter: parent.horizontalCenter
                    active: (panelWindow.wantsOpen || panelWindow.closing) && (Config?.options.overview.enable ?? true)
                    sourceComponent: OverviewWidget {
                        screen: panelWindow.screen
                        visible: (panelWindow.searchingText == "")
                    }
                }
            }
        }
    }

    function toggleClipboard() {
        if (GlobalStates.overviewOpen && overviewScope.dontAutoCancelSearch) {
            GlobalStates.overviewOpen = false;
            return;
        }
        overviewScope.dontAutoCancelSearch = true;
        panelWindow.setSearchingText(Config.options.search.prefix.clipboard);
        GlobalStates.overviewOpen = true;
    }

    function toggleEmojis() {
        if (GlobalStates.overviewOpen && overviewScope.dontAutoCancelSearch) {
            GlobalStates.overviewOpen = false;
            return;
        }
        overviewScope.dontAutoCancelSearch = true;
        panelWindow.setSearchingText(Config.options.search.prefix.emojis);
        GlobalStates.overviewOpen = true;
    }

    IpcHandler {
        target: "search"

        function toggle() {
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen;
        }
        function workspacesToggle() {
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen;
        }
        function close() {
            GlobalStates.overviewOpen = false;
        }
        function open() {
            GlobalStates.overviewOpen = true;
        }
        function toggleReleaseInterrupt() {
            GlobalStates.superReleaseMightTrigger = false;
        }
        function clipboardToggle() {
            overviewScope.toggleClipboard();
        }
    }

    GlobalShortcut {
        name: "searchToggle"
        description: "Toggles search on press"

        onPressed: {
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen;
        }
    }
    GlobalShortcut {
        name: "overviewWorkspacesClose"
        description: "Closes overview on press"

        onPressed: {
            GlobalStates.overviewOpen = false;
        }
    }
    GlobalShortcut {
        name: "overviewWorkspacesToggle"
        description: "Toggles overview on press"

        onPressed: {
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen;
        }
    }
    GlobalShortcut {
        name: "searchToggleRelease"
        description: "Toggles search on release"

        onPressed: {
            GlobalStates.superReleaseMightTrigger = true;
        }

        onReleased: {
            if (!GlobalStates.superReleaseMightTrigger) {
                GlobalStates.superReleaseMightTrigger = true;
                return;
            }
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen;
        }
    }
    GlobalShortcut {
        name: "searchToggleReleaseInterrupt"
        description: "Interrupts possibility of search being toggled on release. " + "This is necessary because GlobalShortcut.onReleased in quickshell triggers whether or not you press something else while holding the key. " + "To make sure this works consistently, use binditn = MODKEYS, catchall in an automatically triggered submap that includes everything."

        onPressed: {
            GlobalStates.superReleaseMightTrigger = false;
        }
    }
    GlobalShortcut {
        name: "overviewClipboardToggle"
        description: "Toggle clipboard query on overview widget"

        onPressed: {
            overviewScope.toggleClipboard();
        }
    }

    GlobalShortcut {
        name: "overviewEmojiToggle"
        description: "Toggle emoji query on overview widget"

        onPressed: {
            overviewScope.toggleEmojis();
        }
    }
}
