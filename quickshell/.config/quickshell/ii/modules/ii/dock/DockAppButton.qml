import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

DockButton {
    id: root
    property var appToplevel
    property var appListRoot
    property int lastFocused: -1
    property real iconSize: 35
    property real countDotWidth: 10
    property real countDotHeight: 4
    property bool appIsActive: appToplevel.toplevels.find(t => (t.activated == true)) !== undefined

    readonly property bool isSeparator: appToplevel.appId === "SEPARATOR"
    property var desktopEntry: DesktopEntries.heuristicLookup(appToplevel.appId)
    // True once we've tried and failed to find a matching .desktop entry.
    // Every dock icon should still do *something* when clicked rather than
    // silently no-op, so this drives both a raw-command fallback below and
    // a dimmed look so a broken pin is visibly distinguishable.
    readonly property bool unresolvable: !isSeparator && !desktopEntry
    enabled: !isSeparator
    implicitWidth: isSeparator ? 1 : implicitHeight - topInset - bottomInset

    function launch() {
        if (root.desktopEntry) {
            root.desktopEntry.execute();
        } else {
            // No matching .desktop entry — fall back to running the appId
            // itself as a command rather than doing nothing.
            Quickshell.execDetached(["sh", "-c", appToplevel.appId]);
        }
    }

    property bool isHovered: mouseAreaLoader.item ? mouseAreaLoader.item.containsMouse : false
    property real yOffset: isHovered ? -8 : 0
    property real bounceOffset: 0

    // The classic macOS dock trick: icons near the pointer grow a little
    // too, tapering off with distance, so the hovered icon doesn't look
    // like it's growing in isolation. Purely additive on top of the
    // existing isHovered scale below — the hovered button's own 1.30 is
    // untouched, this only ever affects its neighbors.
    property real neighborBoost: {
        if (isHovered || isSeparator) return 0;
        const px = appListRoot?.pointerX ?? -1;
        if (px < 0) return 0;
        const maxDist = 70;
        const dist = Math.abs((root.x + root.width / 2) - px);
        if (dist >= maxDist) return 0;
        const t = 1 - dist / maxDist;
        return 0.18 * t * t;
    }

    scale: (isHovered ? 1.30 : 1.0) + neighborBoost
    Behavior on scale {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutBack
            easing.overshoot: 1.6
        }
    }

    transform: Translate {
        y: root.yOffset + root.bounceOffset
        Behavior on y {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }
    }

    SequentialAnimation {
        id: launchBounceAnim
        running: false
        NumberAnimation { target: root; property: "bounceOffset"; to: -14; duration: 140; easing.type: Easing.OutQuad }
        NumberAnimation { target: root; property: "bounceOffset"; to: 0; duration: 240; easing.type: Easing.OutBounce }
    }

    StyledToolTip {
        text: root.desktopEntry?.name || (root.unresolvable
            ? Translation.tr("%1 (no matching app found, will try to run it directly)").arg(appToplevel.appId)
            : appToplevel.appId)
        extraVisibleCondition: root.isHovered
    }

    Connections {
        target: DesktopEntries

        function onApplicationsChanged() {
            root.desktopEntry = DesktopEntries.heuristicLookup(appToplevel.appId);
        }
    }

    Loader {
        active: isSeparator
        anchors {
            fill: parent
            topMargin: dockVisualBackground.margin + dockRow.padding + Appearance.rounding.normal
            bottomMargin: dockVisualBackground.margin + dockRow.padding + Appearance.rounding.normal
        }
        sourceComponent: DockSeparator {}
    }

    Loader {
        id: mouseAreaLoader
        anchors.fill: parent
        active: appToplevel.toplevels.length > 0
        sourceComponent: MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: {
                appListRoot.lastHoveredButton = root
                appListRoot.buttonHovered = true
                lastFocused = appToplevel.toplevels.length - 1
            }
            onExited: {
                if (appListRoot.lastHoveredButton === root) {
                    appListRoot.buttonHovered = false
                }
            }
        }
    }

    onClicked: {
        launchBounceAnim.restart();
        if (appToplevel.toplevels.length === 0) {
            root.launch();
            return;
        }
        lastFocused = (lastFocused + 1) % appToplevel.toplevels.length
        appToplevel.toplevels[lastFocused].activate()
    }

    middleClickAction: () => {
        launchBounceAnim.restart();
        root.launch();
    }

    altAction: () => {
        TaskbarApps.togglePin(appToplevel.appId);
    }

    contentItem: Loader {
        active: !isSeparator
        sourceComponent: Item {
            anchors.centerIn: parent

            Loader {
                id: iconImageLoader
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                active: !root.isSeparator
                sourceComponent: IconImage {
                    source: Quickshell.iconPath(AppSearch.guessIcon(appToplevel.appId), "image-missing")
                    implicitSize: root.iconSize
                    // No .desktop entry matched this appId — dim the icon so
                    // a dead pin is visibly distinguishable rather than
                    // looking identical to a working one.
                    opacity: root.unresolvable ? 0.5 : 1
                    Behavior on opacity {
                        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                    }
                }
            }

            Loader {
                active: Config.options.dock.monochromeIcons
                anchors.fill: iconImageLoader
                sourceComponent: Item {
                    Desaturate {
                        id: desaturatedIcon
                        visible: false // There's already color overlay
                        anchors.fill: parent
                        source: iconImageLoader
                        desaturation: 0.8
                    }
                    ColorOverlay {
                        anchors.fill: desaturatedIcon
                        source: desaturatedIcon
                        color: ColorUtils.transparentize(Appearance.colors.colPrimary, 0.9)
                    }
                }
            }

            RowLayout {
                spacing: 3
                anchors {
                    top: iconImageLoader.bottom
                    topMargin: 2
                    horizontalCenter: parent.horizontalCenter
                }
                Repeater {
                    model: Math.min(appToplevel.toplevels.length, 3)
                    delegate: Rectangle {
                        required property int index
                        radius: Appearance.rounding.full
                        implicitWidth: (appToplevel.toplevels.length <= 3) ? 
                            root.countDotWidth : root.countDotHeight // Circles when too many
                        implicitHeight: root.countDotHeight
                        color: appIsActive ? Appearance.colors.colPrimary : ColorUtils.transparentize(Appearance.colors.colOnLayer0, 0.4)
                    }
                }
            }
        }
    }
}
