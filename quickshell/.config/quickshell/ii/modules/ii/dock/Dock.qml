import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell.Io
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland

// A floating, macOS-style glass dock. One PanelWindow per monitor, hidden
// until hovered (or pinned open), housing an optional pin toggle, the
// running/pinned app row, and an optional "show all apps" launcher.
Scope {
    id: root
    // Explicit Config.ready dependency (the pattern used elsewhere in the
    // shell for exactly this reason) rather than relying on Config.options
    // being read through the ?. chain alone to register as a live binding
    // dependency once the config file actually finishes loading.
    property bool pinned: Config.ready && (Config.options?.dock.pinnedOnStartup ?? false)

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: dockRoot
            required property var modelData
            screen: modelData
            visible: !GlobalStates.screenLocked

            // Reveal is just: pinned, hovering the reveal strip, or a
            // window-preview popup wants to stay visible — nothing
            // implicit like "no window is focused", which used to pop the
            // dock up unpredictably during totally normal things (closing
            // a window, switching workspaces).
            //
            // Still debounced: show instantly, hide only after a short
            // grace period, so a momentary mouse blip off the hover region
            // (e.g. crossing into a dock icon's own bounds) doesn't cause a
            // visible show/hide/show flicker.
            readonly property bool wantsReveal: root.pinned || (Config.options?.dock.hoverToReveal && dockMouseArea.containsMouse) || dockApps.requestDockShow
            property bool reveal: wantsReveal

            onWantsRevealChanged: {
                if (wantsReveal) {
                    hideDelayTimer.stop();
                    reveal = true;
                } else {
                    hideDelayTimer.restart();
                }
            }

            Timer {
                id: hideDelayTimer
                interval: 180
                onTriggered: dockRoot.reveal = dockRoot.wantsReveal
            }

            anchors {
                bottom: true
                left: true
                right: true
            }

            // How far the dock floats above the actual screen edge. A
            // proper macOS-style floating dock needs a real, deliberate
            // gap of its own — not the same small value used for
            // in-between window gaps elsewhere, which reads as "barely
            // lifted" rather than "floating".
            readonly property real floatGap: 18
            // More headroom than the icon canvas strictly needs at rest —
            // guarantees the hover magnify + lift never visually pokes
            // past the pill's own top edge, no matter how it's tuned.
            readonly property real dockHeight: Config.options?.dock.height ?? 88

            exclusiveZone: root.pinned ? implicitHeight - floatGap - (Appearance.sizes.elevationMargin - floatGap) : 0

            implicitWidth: dockBackground.implicitWidth
            implicitHeight: dockHeight + Appearance.sizes.elevationMargin + floatGap
            WlrLayershell.namespace: "quickshell:dock"
            color: "transparent"

            mask: Region {
                item: dockMouseArea
            }

            MouseArea {
                id: dockMouseArea
                height: parent.height
                anchors {
                    top: parent.top
                    topMargin: dockRoot.reveal ? 0 : Config.options?.dock.hoverToReveal ? (dockRoot.implicitHeight - Config.options.dock.hoverRegionHeight) : (dockRoot.implicitHeight + 1)
                    horizontalCenter: parent.horizontalCenter
                }
                implicitWidth: dockHoverRegion.implicitWidth + Appearance.sizes.elevationMargin * 2
                hoverEnabled: true

                Behavior on anchors.topMargin {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }

                Item {
                    id: dockHoverRegion
                    anchors.fill: parent
                    implicitWidth: dockBackground.implicitWidth

                    Item { // Wrapper for the dock background
                        id: dockBackground
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            horizontalCenter: parent.horizontalCenter
                        }

                        // Was + 5*2 — a leftover from the old flush-taskbar
                        // sizing that left almost no real end-cap padding
                        // on the pill once everything else got more
                        // generous. A proper floating pill wants visible
                        // rounded space at both ends, not content sitting
                        // right at the curve.
                        implicitWidth: dockRow.implicitWidth + 26 * 2
                        height: parent.height - Appearance.sizes.elevationMargin - Appearance.sizes.hyprlandGapsOut

                        StyledRectangularShadow {
                            target: dockVisualBackground
                        }
                        Rectangle { // The real, visible glass surface
                            id: dockVisualBackground
                            property real margin: Appearance.sizes.elevationMargin
                            anchors.fill: parent
                            anchors.topMargin: Appearance.sizes.elevationMargin
                            anchors.bottomMargin: dockRoot.floatGap

                            // A soft vertical gradient instead of a flat
                            // fill — real glass/acrylic isn't a single flat
                            // tint, it reads lighter/more see-through near
                            // the top and a little denser toward the
                            // bottom, on top of the compositor blur behind
                            // it (see rules.lua's dock[0-9]* layer rule).
                            gradient: Gradient {
                                orientation: Gradient.Vertical
                                GradientStop { position: 0.0; color: ColorUtils.applyAlpha(Appearance.colors.colLayer0Base, 0.56) }
                                GradientStop { position: 1.0; color: ColorUtils.applyAlpha(Appearance.colors.colLayer0Base, 0.7) }
                            }
                            border.width: 1
                            border.color: Appearance.colors.colLayer0Border
                            // A true capsule (fully rounded ends), not the
                            // fixed windowRounding token every other panel
                            // uses — this is the one shape in the shell
                            // that's actually pill-shaped end to end.
                            radius: height / 2
                            clip: true

                            // Edge highlights — the thin bright line real
                            // glass/acrylic catches along its curved
                            // profile, top and (fainter) bottom, for actual
                            // material depth instead of a flat translucent
                            // fill.
                            Rectangle {
                                anchors { top: parent.top; left: parent.left; right: parent.right }
                                height: 1
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: ColorUtils.transparentize(Appearance.colors.colOnLayer0, 1) }
                                    GradientStop { position: 0.5; color: ColorUtils.transparentize(Appearance.colors.colOnLayer0, 0.82) }
                                    GradientStop { position: 1.0; color: ColorUtils.transparentize(Appearance.colors.colOnLayer0, 1) }
                                }
                            }
                            Rectangle {
                                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                                height: 1
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: ColorUtils.transparentize(Appearance.colors.colOnLayer0, 1) }
                                    GradientStop { position: 0.5; color: ColorUtils.transparentize(Appearance.colors.colOnLayer0, 0.92) }
                                    GradientStop { position: 1.0; color: ColorUtils.transparentize(Appearance.colors.colOnLayer0, 1) }
                                }
                            }
                        }

                        RowLayout {
                            id: dockRow
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            // Generous spacing/padding — a floating pill
                            // dock wants real breathing room between icons,
                            // not the tight spacing that suited the old
                            // flush-to-edge taskbar look.
                            spacing: 20
                            property real padding: 16

                            VerticalButtonGroup {
                                // Off by default — see
                                // Config.options.dock.showControlButtons.
                                // Pin/launcher are control chrome, not
                                // apps; a bare macOS-style dock reads
                                // cleaner without them, and this is
                                // re-enableable in Settings.
                                visible: Config.options.dock.showControlButtons
                                Layout.topMargin: Appearance.sizes.hyprlandGapsOut
                                GroupButton {
                                    // A filled circle once toggled instead
                                    // of a same-shaped rounded-square as
                                    // everything else, so it reads as a
                                    // distinct mode toggle rather than
                                    // another app-like icon.
                                    id: pinButton
                                    baseWidth: 40
                                    baseHeight: 40
                                    clickedWidth: baseWidth
                                    clickedHeight: baseHeight + 20
                                    buttonRadius: root.pinned ? Appearance.rounding.full : Appearance.rounding.normal
                                    Behavior on buttonRadius {
                                        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                                    }
                                    toggled: root.pinned
                                    onClicked: root.pinned = !root.pinned
                                    contentItem: MaterialSymbol {
                                        text: "keep"
                                        fill: pinButton.toggled ? 1 : 0
                                        horizontalAlignment: Text.AlignHCenter
                                        iconSize: Appearance.font.pixelSize.larger
                                        color: root.pinned ? Appearance.m3colors.m3onPrimary : Appearance.colors.colOnLayer0
                                    }
                                    StyledToolTip {
                                        text: root.pinned ? Translation.tr("Unpin dock") : Translation.tr("Keep dock open")
                                    }
                                }
                            }
                            DockSeparator { visible: Config.options.dock.showControlButtons }
                            DockApps {
                                id: dockApps
                                buttonPadding: dockRow.padding
                            }
                            DockSeparator { visible: Config.options.dock.showControlButtons }
                            DockButton {
                                id: launcherButton
                                visible: Config.options.dock.showControlButtons
                                Layout.fillHeight: true
                                onClicked: GlobalStates.overviewOpen = !GlobalStates.overviewOpen
                                topInset: Appearance.sizes.hyprlandGapsOut + dockRow.padding
                                bottomInset: Appearance.sizes.hyprlandGapsOut + dockRow.padding
                                buttonRadius: Appearance.rounding.full
                                // Distinct filled pill instead of a plain
                                // icon like the app buttons — this is the
                                // one "show everything" action, not an app.
                                colBackground: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.16)
                                colBackgroundHover: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.28)
                                contentItem: MaterialSymbol {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: parent.width / 2
                                    text: "apps"
                                    color: Appearance.colors.colPrimary
                                }
                                StyledToolTip {
                                    text: Translation.tr("Show all apps")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
