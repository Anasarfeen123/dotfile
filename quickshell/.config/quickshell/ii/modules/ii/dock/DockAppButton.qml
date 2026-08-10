import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland

DockButton {
    id: root
    property var appToplevel
    property var appListRoot
    property int lastFocused: -1
    // Now user-adjustable — Settings > Interface > Dock > Icon size.
    property real iconSize: Config.options.dock.iconSize
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
    // existing isHovered scale below — the hovered button's own scale is
    // untouched, this only ever affects its neighbors.
    property real neighborBoost: {
        if (isHovered || isSeparator) return 0;
        const px = appListRoot?.pointerX ?? -1;
        if (px < 0) return 0;
        const maxDist = 70;
        const dist = Math.abs((root.x + root.width / 2) - px);
        if (dist >= maxDist) return 0;
        const t = 1 - dist / maxDist;
        return 0.14 * t * t;
    }

    // Was Easing.OutBack with a manual overshoot — the only place in the
    // dock (and one of very few in the whole shell) not using the app's own
    // BezierSpline motion tokens, which is likely why hovering felt off
    // compared to everything else. elementMoveFast matches the snappy
    // hover feedback used elsewhere (tab bars, resource icons, etc).
    //
    // scale/transform used to live directly on root (this whole button,
    // including its own hit-test area). Qt Quick's scale is a live
    // coordinate-space transform: children's hoverable/clickable bounds
    // grow with it too, not just the paint. With 10px spacing and a 30%
    // scale-up, a hovered icon's *interactive* area was genuinely
    // ballooning into its neighbors' territory mid-animation — landing the
    // pointer right in the overlap made hover state flip back and forth
    // between the two icons, which is what the flickering was. Both now
    // live on contentItem (the actual rendered visuals) below instead, so
    // root's own bounds — and therefore everyone's hit-test region — stay
    // fixed regardless of how big anything is drawn.
    // Was 1.30 — with the icon now framed inside a fixed-size canvas tile
    // (see contentItem below), too aggressive a scale-up visually pushed
    // the glow/edge of that tile past the dock's own top edge when
    // combined with the hover lift. 1.22 keeps the magnify effect clearly
    // readable while comfortably fitting within the dock's height.
    property real iconScale: (isHovered ? 1.22 : 1.0) + neighborBoost

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

    // Was margin(10) + padding(5) + rounding.normal(17) = 32px on *each*
    // side — 64px total on a button whose own height is ~60px, so this
    // separator (between pinned and running apps in the list) had
    // negative effective height and was never actually visible.
    Loader {
        active: isSeparator
        anchors {
            fill: parent
            topMargin: dockVisualBackground.margin + dockRow.padding
            bottomMargin: dockVisualBackground.margin + dockRow.padding
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
            // This overlay sits on top of RippleButton's own base MouseArea
            // (which does set a pointing-hand cursor) purely to track hover
            // state and wheel input — but being on top, its own default
            // ArrowCursor was winning regardless of what's underneath.
            cursorShape: Qt.PointingHandCursor
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

            // New: scroll over an icon with multiple windows to step
            // through them one at a time, without needing to click
            // repeatedly (click already cycles, but that also
            // launches/refocuses on every click — scroll is a quieter way
            // to just page through).
            onWheel: wheel => {
                if (appToplevel.toplevels.length <= 1) {
                    wheel.accepted = false;
                    return;
                }
                const dir = wheel.angleDelta.y > 0 ? -1 : 1;
                lastFocused = ((lastFocused + dir) % appToplevel.toplevels.length + appToplevel.toplevels.length) % appToplevel.toplevels.length;
                appToplevel.toplevels[lastFocused].activate();
                wheel.accepted = true;
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

    // Was an instant, unlabeled pin/unpin toggle on right-click — you had
    // to already know that gesture existed. A real menu instead, matching
    // what right-clicking a dock icon does everywhere else.
    //
    // This is a PopupWindow (its own Wayland surface, anchored to this
    // button), not a QtQuick.Controls.Popup — a QQC2 Popup is confined to
    // the *dock's own* layer-shell surface, which is exactly as tall as
    // the dock bar itself, so a menu positioned above the button (negative
    // y) was being silently clipped out of existence: the surface simply
    // didn't extend there. This is the same pattern DockApps.qml's window
    // preview popup already uses successfully for the same reason.
    altAction: () => {
        if (!root.isSeparator) contextMenu.menuOpen = !contextMenu.menuOpen;
    }

    PopupWindow {
        id: contextMenu
        property bool menuOpen: false
        visible: menuOpen
        color: "transparent"

        anchor {
            item: root
            edges: Edges.Top
            gravity: Edges.Top
            adjustment: PopupAdjustment.None
            margins.bottom: 8
        }

        implicitWidth: menuBackground.implicitWidth
        implicitHeight: menuBackground.implicitHeight

        // Own isolated focus grab (not the shared GlobalFocusGrab
        // singleton — that broadcasts one "dismissed" signal to every
        // dismissable window at once, which would risk this menu closing
        // the sidebar or overview too if either happened to be open).
        HyprlandFocusGrab {
            id: focusGrab
            windows: [contextMenu]
            active: contextMenu.menuOpen
            onCleared: contextMenu.menuOpen = false
        }

        readonly property var actions: [
            {
                icon: "open_in_new",
                text: Translation.tr("Open"),
                visible: true,
                danger: false,
                trigger: () => root.launch(),
            },
            {
                icon: TaskbarApps.isPinned(appToplevel.appId) ? "keep_off" : "keep",
                text: TaskbarApps.isPinned(appToplevel.appId) ? Translation.tr("Unpin from dock") : Translation.tr("Pin to dock"),
                visible: true,
                danger: false,
                trigger: () => TaskbarApps.togglePin(appToplevel.appId),
            },
            {
                icon: "close",
                text: Translation.tr("Quit"),
                visible: appToplevel.toplevels.length > 0,
                danger: true,
                trigger: () => appToplevel.toplevels.forEach(t => t.close()),
            },
        ]

        StyledRectangularShadow {
            target: menuBackground
        }
        Rectangle {
            id: menuBackground
            // Was a flat M3 surfaceContainer color — every other floating
            // surface in the shell (dock, sidebars, search/overview panel)
            // uses this same translucent glass recipe, so this menu looked
            // like a different, unrelated app's popup instead of part of
            // the same UI.
            color: ColorUtils.applyAlpha(Appearance.colors.colLayer0Base, 0.72)
            radius: Appearance.rounding.normal
            // Dropped the hard 1px border — a soft drop shadow alone reads
            // as a fluid floating glass surface; the border made it look
            // like a stiff, separate boxed-in panel instead.
            implicitWidth: menuColumn.implicitWidth + 12
            implicitHeight: menuColumn.implicitHeight + 12

            ColumnLayout {
                id: menuColumn
                anchors.centerIn: parent
                spacing: 2
                implicitWidth: 190

                Repeater {
                    model: contextMenu.actions
                    delegate: RippleButton {
                        id: menuRow
                        required property var modelData
                        visible: modelData.visible
                        Layout.fillWidth: true
                        Layout.preferredHeight: visible ? 36 : 0
                        buttonRadius: Appearance.rounding.small
                        colBackground: "transparent"
                        onClicked: {
                            contextMenu.menuOpen = false;
                            modelData.trigger();
                        }
                        leftPadding: 8
                        rightPadding: 8
                        contentItem: RowLayout {
                            spacing: 8
                            MaterialSymbol {
                                text: menuRow.modelData.icon
                                iconSize: Appearance.font.pixelSize.normal
                                color: menuRow.modelData.danger ? Appearance.colors.colError : Appearance.colors.colOnLayer0
                            }
                            StyledText {
                                text: menuRow.modelData.text
                                color: menuRow.modelData.danger ? Appearance.colors.colError : Appearance.colors.colOnLayer0
                            }
                        }
                    }
                }
            }
        }
    }

    contentItem: Loader {
        active: !isSeparator
        // Was relying on whatever size Control's default contentItem
        // layout assigned here, which turned out not to be the full
        // button height (padding/availableHeight quirks) — so the inner
        // Item's `centerIn: parent` below was centering within a *shorter*
        // box than the actual button, landing visibly above true center.
        // Binding straight to root's own real height sidesteps that
        // entirely.
        width: root.width
        height: root.height

        // Magnify + lift, moved here from root (see the comment above
        // iconScale) so only the drawn content grows/lifts on hover, never
        // the button's own interactive bounds.
        scale: root.iconScale
        Behavior on scale {
            NumberAnimation {
                duration: Appearance.animation.elementMoveFast.duration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
            }
        }
        transform: Translate {
            y: root.yOffset + root.bounceOffset
            Behavior on y {
                NumberAnimation {
                    duration: Appearance.animation.elementMoveFast.duration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
                }
            }
        }

        sourceComponent: Item {
            id: iconGroup
            // Anchored toward the bottom with a modest margin rather than
            // dead-centered — a real dock's icons sit grounded near its
            // floor, not floating in the exact middle, and this leaves
            // more headroom *above* for the hover magnify + lift to grow
            // into without ever nearing the pill's own top edge.
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                // -21 confirmed as the preferred value through live tuning.
                bottomMargin: -21
            }
            // canvasSize is the one source of truth for both the tile's
            // own size and this wrapper's layout budget below — every
            // other dimension here is derived from it, instead of the
            // tile and the icon each carrying their own independent size
            // that has to be kept in sync by hand.
            readonly property real canvasSize: root.iconSize + 16
            // Real width/height, not implicitWidth/implicitHeight — those
            // are only a *hint* the Loader is free to override, and the
            // Loader above has an explicit size of its own, so an unsized
            // child gets silently stretched to fill it (Loader's default
            // behavior), which would make this centerIn a no-op.
            width: iconGroup.canvasSize
            height: iconGroup.canvasSize + (appToplevel.toplevels.length > 0 ? 2 + root.countDotHeight : 0)

            // Every icon sits on its own permanent rounded-square "canvas"
            // — a consistent tile behind every icon regardless of the
            // actual icon's shape/transparency, macOS-dock style, rather
            // than raw icons of inconsistent visual weight floating with
            // nothing framing them. Anchored to this wrapper's own top
            // (not centered on the icon inside it) so it's the canvas —
            // the actual dominant visible shape — that's correctly
            // positioned within the wrapper's layout budget; the icon is
            // just centered inside *it*, one level down, where a size
            // mismatch between the two can't throw off the outer
            // centering.
            Rectangle {
                id: iconCanvas
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
                width: iconGroup.canvasSize
                height: iconGroup.canvasSize
                radius: Appearance.rounding.normal
                color: ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.4)
                border.width: 1
                border.color: ColorUtils.applyAlpha(Appearance.colors.colLayer0Border, 0.6)
                Behavior on color {
                    animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                }

                Loader {
                    id: iconImageLoader
                    anchors.centerIn: parent
                    active: !root.isSeparator
                    sourceComponent: IconImage {
                        source: Quickshell.iconPath(AppSearch.guessIcon(appToplevel.appId), "image-missing")
                        // A little smaller than the canvas around it, same
                        // margin macOS gives its own dock icons inside
                        // their tile, so nothing visually touches the
                        // canvas' own rounded edge.
                        implicitSize: root.iconSize - 4
                        // No .desktop entry matched this appId — dim the
                        // icon so a dead pin is visibly distinguishable
                        // rather than looking identical to a working one.
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
                            visible: true
                            anchors.fill: parent
                            source: iconImageLoader
                            desaturation: 1.0
                        }
                        ColorOverlay {
                            anchors.fill: desaturatedIcon
                            source: desaturatedIcon
                            color: Appearance.colors.colOnLayer1
                            opacity: 0.9
                        }
                    }
                }

                // A colored glow instead of just count-dots when this is
                // the focused app — glanceable at rest, not only on hover.
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.width: 1.5
                    border.color: Appearance.colors.colPrimary
                    opacity: root.appIsActive ? 0.9 : 0
                    Behavior on opacity {
                        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                    }
                }

                // The hover state layer — brighter overlay on top of the
                // permanent canvas, not a separate tile of its own.
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Appearance.colors.colLayer1Hover
                    opacity: root.isHovered ? 1 : 0
                    Behavior on opacity {
                        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                    }
                }
            }

            RowLayout {
                spacing: 3
                anchors {
                    top: iconCanvas.bottom
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
