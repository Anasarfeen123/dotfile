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

Scope { // Scope
    id: root
    property bool pinned: Config.options?.dock.pinnedOnStartup ?? false

    Variants {
        // For each monitor
        model: Quickshell.screens

        PanelWindow {
            id: dockRoot
            // Window
            required property var modelData
            screen: modelData
            visible: !GlobalStates.screenLocked

            // Dropped the old "reveal whenever no window is focused" clause
            // entirely — it fired during completely normal things (closing
            // a window, switching workspaces, anything with a momentary gap
            // between one window losing focus and the next gaining it), so
            // the dock would pop up unpredictably outside of an actual
            // hover or pin. Reveal is now just: pinned, hovering, or a
            // preview popup wants it visible — nothing implicit.
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

            // How far the dock floats above the actual screen edge — a
            // proper macOS-style floating dock needs a real visible gap of
            // its own here, not the same small value used for in-between
            // window gaps elsewhere (Appearance.sizes.hyprlandGapsOut,
            // which this used to reuse and which reads as "barely lifted"
            // rather than "floating").
            readonly property real floatGap: 16

            exclusiveZone: root.pinned ? implicitHeight - floatGap - (Appearance.sizes.elevationMargin - floatGap) : 0

            implicitWidth: dockBackground.implicitWidth
            WlrLayershell.namespace: "quickshell:dock"
            color: "transparent"

            implicitHeight: (Config.options?.dock.height ?? 70) + Appearance.sizes.elevationMargin + floatGap

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

                        implicitWidth: dockRow.implicitWidth + 5 * 2
                        height: parent.height - Appearance.sizes.elevationMargin - Appearance.sizes.hyprlandGapsOut

                        StyledRectangularShadow {
                            target: dockVisualBackground
                        }
                        Rectangle { // The real rectangle that is visible
                            id: dockVisualBackground
                            property real margin: Appearance.sizes.elevationMargin
                            anchors.fill: parent
                            anchors.topMargin: Appearance.sizes.elevationMargin
                            anchors.bottomMargin: dockRoot.floatGap
                            // Same fixed glass recipe as the sidebars
                            // (colLayer0Base @ 0.72 + hairline border), not
                            // the generic colLayer0 token — that one rides
                            // the global transparency setting and reads
                            // noticeably flatter/more opaque than the panels
                            // it sits next to.
                            color: ColorUtils.applyAlpha(Appearance.colors.colLayer0Base, 0.72)
                            border.width: 1
                            border.color: Appearance.colors.colLayer0Border
                            // A true capsule (fully rounded ends) instead of
                            // the fixed windowRounding token that every
                            // other rectangular panel uses — this is the
                            // one shape in the shell that's actually pill-
                            // shaped end to end, macOS-dock style, rather
                            // than just a rounded rectangle.
                            radius: height / 2
                            clip: true

                            // A faint top-edge highlight — the thin bright
                            // line real glass/acrylic catches along its top
                            // edge — for some actual material depth instead
                            // of a flat translucent fill.
                            Rectangle {
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    right: parent.right
                                }
                                height: 1
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: ColorUtils.transparentize(Appearance.colors.colOnLayer0, 1) }
                                    GradientStop { position: 0.5; color: ColorUtils.transparentize(Appearance.colors.colOnLayer0, 0.82) }
                                    GradientStop { position: 1.0; color: ColorUtils.transparentize(Appearance.colors.colOnLayer0, 1) }
                                }
                            }
                        }

                        RowLayout {
                            id: dockRow
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            // Both bumped up from 3/5 — a floating pill dock
                            // wants real breathing room between icons, not
                            // the tight spacing that suited the old flush-
                            // to-edge bar look.
                            spacing: 10
                            property real padding: 10

                            VerticalButtonGroup {
                                Layout.topMargin: Appearance.sizes.hyprlandGapsOut // why does this work
                                GroupButton {
                                    // Pin button — a filled circle once
                                    // toggled instead of a same-shaped
                                    // rounded-square as everything else, so
                                    // it reads as a distinct mode toggle
                                    // rather than another app-like icon.
                                    id: pinButton
                                    baseWidth: 38
                                    baseHeight: 38
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
                            DockSeparator {}
                            DockApps {
                                id: dockApps
                                buttonPadding: dockRow.padding
                            }
                            DockSeparator {}
                            DockButton {
                                id: launcherButton
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
