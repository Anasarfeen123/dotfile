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

StyledGlassSurface {
    id: root
    fillOpacity: 0.38

    readonly property int workspacesShown: Config.options.bar.workspaces.shown
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    readonly property int activeWorkspaceId: monitor?.activeWorkspace?.id ?? 1

    property bool collapsed: Persistent.states.sidebar.workspaceGrid.collapsed

    property var occupiedIds: {
        const set = new Set();
        Hyprland.workspaces.values.forEach(ws => {
            if (ws.monitor?.name === monitor?.name) set.add(ws.id);
        });
        return set;
    }
    property var occupiedIdsKeys: [...occupiedIds]

    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            root.occupiedIdsKeys = [...root.occupiedIds];
        }
    }
    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            root.occupiedIdsKeys = [...root.occupiedIds];
        }
    }

    function setCollapsed(state) {
        Persistent.states.sidebar.workspaceGrid.collapsed = state;
    }

    implicitWidth: 200
    implicitHeight: collapsed ? headerRow.implicitHeight + 14 : grid.implicitHeight + headerRow.implicitHeight + 24

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
            Layout.topMargin: 6
            Layout.bottomMargin: collapsed ? 0 : 4
            Layout.leftMargin: 10
            Layout.rightMargin: 6
            spacing: 8

            MaterialSymbol {
                text: "grid_view"
                iconSize: 15
                color: Appearance.colors.colOnLayer1
            }
            StyledText {
                Layout.fillWidth: true
                text: Translation.tr("Workspaces")
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
                color: Appearance.colors.colOnLayer1
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

        GridLayout { // Workspace buttons
            id: grid
            visible: !collapsed
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 6
            columnSpacing: 6
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            Layout.bottomMargin: 8

            Repeater {
                model: root.workspacesShown
                delegate: Item {
                    id: wrapper
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    required property int index

                    WorkspaceButton {
                        anchors.fill: parent
                        workspaceId: wrapper.index + 1
                        active: workspaceId === root.activeWorkspaceId
                        occupied: root.occupiedIds.has(workspaceId)
                        onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${workspaceId}})`)
                    }
                }
            }
        }
    }

    component WorkspaceButton: Rectangle {
        id: button
        required property int workspaceId
        required property bool active
        required property bool occupied
        signal clicked
        radius: Appearance.rounding.small
        color: active ? Appearance.colors.colPrimary : ColorUtils.applyAlpha(Appearance.colors.colLayer2Base, 0.4)
        border.width: occupied && !active ? 1 : 0
        border.color: Appearance.colors.colLayer0Border

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 6

            MaterialSymbol {
                text: "circle"
                iconSize: 10
                color: button.active ? Appearance.m3colors.m3onPrimary : Appearance.colors.colOnLayer1
                fill: button.occupied ? 1 : 0
            }
            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: button.workspaceId
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
                color: button.active ? Appearance.m3colors.m3onPrimary : Appearance.colors.colOnLayer1
            }
        }
    }
}
