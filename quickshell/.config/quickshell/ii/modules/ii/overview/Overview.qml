import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import Qt.labs.synchronizer
import Qt5Compat.GraphicalEffects
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

        // Kept mapped a beat past overviewOpen going false so the shrink
        // animation on revealClip below has time to actually play —
        // otherwise the surface unmaps instantly and cuts it off mid-way.
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
            // Matches revealClip's IslandSpring duration (480ms) + margin —
            // has to outlast the shrink-to-pill animation or the window
            // unmaps mid-shrink.
            interval: 480 + 60
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

        // Dynamic-Island-style morph: a small pill sitting right at the
        // bar's bottom edge grows into the full search+overview panel.
        // Both width and height animate (not just height), the corner
        // radius is always min(width,height)/2 — maximally rounded on the
        // short axis, exactly like a real Dynamic Island's shape language —
        // so it reads as a pill at small sizes and eases into a rounded
        // rect once wide enough. No opacity animation anywhere: the content
        // is simply revealed as the clip grows, never faded.
        Item {
            id: revealClip
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }

            readonly property real collapsedWidth: 96
            readonly property real collapsedHeight: 32
            readonly property real islandRadius: Math.min(width, height) / 2

            width: panelWindow.wantsOpen ? columnLayout.implicitWidth : collapsedWidth
            height: panelWindow.wantsOpen ? columnLayout.implicitHeight : collapsedHeight

            component IslandSpring: NumberAnimation {
                // A springier, more pronounced curve than the usual
                // elementMove — this is the hero motion of the whole
                // panel, not a background chrome transition, so it earns
                // a bit more bounce (expressiveDefaultSpatial already has
                // overshoot built in; slowing it down further makes that
                // overshoot actually readable instead of snapping past it).
                duration: 480
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.animationCurves.expressiveDefaultSpatial
            }
            Behavior on width { IslandSpring {} }
            Behavior on height { IslandSpring {} }

            // Rounded-corner clipping (plain Item.clip only clips to the
            // rectangular bounds, ignoring radius — this OpacityMask
            // approach is the same one SearchWidget's own content already
            // uses for exactly this reason).
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: revealClip.width
                    height: revealClip.height
                    radius: revealClip.islandRadius
                }
            }

            // Fill visible during the collapsed/mid-transition states,
            // before the real content (which has its own background) has
            // grown large enough to cover the whole island itself.
            Rectangle {
                anchors.fill: parent
                radius: revealClip.islandRadius
                color: ColorUtils.applyAlpha(Appearance.colors.colLayer0Base, 0.72)
            }

            Column {
                id: columnLayout
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                }
                spacing: -8

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
