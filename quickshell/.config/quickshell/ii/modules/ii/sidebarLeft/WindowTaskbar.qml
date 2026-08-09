import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets

StyledGlassSurface {
    id: root
    fillOpacity: 0.38

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    readonly property string monitorName: monitor?.name ?? ""

    property var windows: []
    property var windowsKeys: []

    property bool collapsed: Persistent.states.sidebar.windowPanel.collapsed

    function refresh() {
        const list = [];
        for (const t of ToplevelManager.toplevels.values) {
            const hy = t.HyprlandToplevel;
            if (!hy) continue;
            if (root.monitorName.length === 0 || hy.monitor?.name === root.monitorName) {
                list.push(t);
            }
        }
        root.windows = list;
        root.windowsKeys = [...list];
    }

    function setCollapsed(state) {
        Persistent.states.sidebar.windowPanel.collapsed = state;
    }

    Connections {
        target: ToplevelManager.toplevels
        function onValuesChanged() { root.refresh(); }
    }
    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() { root.refresh(); }
    }
    Component.onCompleted: root.refresh()

    readonly property var activeToplevel: {
        for (const t of root.windowsKeys) {
            if (t.HyprlandToplevel?.activated) return t;
        }
        return null;
    }

    implicitWidth: 200
    implicitHeight: collapsed ? headerRow.implicitHeight + 12 : Math.min(list.count * 46 + headerRow.implicitHeight + 22, 320)

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Appearance.animation.elementMove.duration
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout { // Header
            id: headerRow
            Layout.fillWidth: true
            Layout.topMargin: 7
            Layout.bottomMargin: collapsed ? 0 : 4
            Layout.leftMargin: 10
            Layout.rightMargin: 6
            spacing: 8

            MaterialSymbol {
                text: "apps"
                iconSize: 15
                color: Appearance.colors.colOnLayer1
            }
            StyledText {
                Layout.fillWidth: true
                text: Translation.tr("Windows")
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
                color: Appearance.colors.colOnLayer1
            }
            Rectangle { // Window count badge
                visible: root.windowsKeys.length > 0
                implicitWidth: Math.max(20, countText.contentWidth + 8)
                implicitHeight: 16
                radius: height / 2
                color: Appearance.colors.colPrimary
                Layout.alignment: Qt.AlignVCenter
                StyledText {
                    id: countText
                    anchors.centerIn: parent
                    text: root.windowsKeys.length
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colOnPrimary
                }
            }
            RowLayout { // Active window quick controls
                visible: !root.collapsed && root.activeToplevel
                spacing: 2
                WindowActionButton {
                    icon: "minimize"
                    tooltip: Translation.tr("Minimize")
                    onClicked: root.activeToplevel.minimized = true
                }
                WindowActionButton {
                    icon: "crop_square"
                    tooltip: Translation.tr("Maximize / Restore")
                    onClicked: root.activeToplevel.maximized = !root.activeToplevel.maximized
                }
                WindowActionButton {
                    icon: "close"
                    tooltip: Translation.tr("Close")
                    onClicked: root.activeToplevel.close()
                }
            }
            MaterialSymbol {
                text: root.collapsed ? "expand_less" : "expand_more"
                iconSize: 16
                color: Appearance.colors.colSubtext
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.setCollapsed(!root.collapsed)
                }
            }
        }

        ListView {
            id: list
            visible: !root.collapsed
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            Layout.bottomMargin: 8
            clip: true
            model: root.windowsKeys
            spacing: 5

            delegate: WindowButton {
                id: row
                required property var modelData
                width: ListView.view.width
                height: 40
                toplevel: modelData
            }
        }
    }

    component WindowActionButton: Rectangle {
        id: actButton
        required property string icon
        required property string tooltip
        signal clicked
        implicitWidth: 22
        implicitHeight: 22
        radius: Appearance.rounding.small
        color: actMouseArea.containsMouse ? ColorUtils.applyAlpha(Appearance.colors.colLayer2Base, 0.6) : "transparent"

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }

        MaterialSymbol {
            anchors.centerIn: parent
            text: actButton.icon
            iconSize: 14
            color: Appearance.colors.colSubtext
        }
        MouseArea {
            id: actMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: actButton.clicked()
        }
        StyledToolTip {
            text: actButton.tooltip
        }
    }

    component WindowButton: Rectangle {
        id: button
        required property var toplevel
        radius: Appearance.rounding.small
        color: ColorUtils.applyAlpha(Appearance.colors.colLayer2Base, button.isActive ? 0.55 : 0.3)
        border.width: button.isActive ? 1 : 0
        border.color: Appearance.colors.colPrimary

        readonly property bool isActive: toplevel.HyprlandToplevel?.activated ?? false
        readonly property int workspaceId: toplevel.HyprlandToplevel?.workspace?.id ?? 0
        property var desktopEntry: DesktopEntries.heuristicLookup(toplevel.appId)

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: toplevel.activate()
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            IconImage {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                Layout.alignment: Qt.AlignVCenter
                source: Quickshell.iconPath(button.desktopEntry?.icon ?? "", "image-missing")
            }

            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: button.toplevel.title || button.desktopEntry?.name || button.toplevel.appId
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: button.isActive ? Font.DemiBold : Font.Normal
                color: Appearance.colors.colOnLayer1
                elide: Text.ElideRight
            }

            Rectangle { // Workspace badge
                implicitWidth: Math.max(16, wsText.contentWidth + 6)
                implicitHeight: 16
                radius: Appearance.rounding.full
                color: ColorUtils.applyAlpha(Appearance.colors.colLayer2Base, 0.8)
                border.width: 1
                border.color: Appearance.colors.colLayer0Border
                Layout.alignment: Qt.AlignVCenter
                StyledText {
                    id: wsText
                    anchors.centerIn: parent
                    text: button.workspaceId
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colOnLayer1
                }
            }

            MaterialSymbol {
                Layout.alignment: Qt.AlignVCenter
                text: "close"
                iconSize: 14
                color: Appearance.colors.colSubtext
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: toplevel.close()
                }
            }
        }
    }
}
