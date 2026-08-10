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
    readonly property int workspacesShown: Config.options.bar.workspaces.shown
    readonly property int activeWorkspaceId: monitor?.activeWorkspace?.id ?? 1

    property bool collapsed: Persistent.states.sidebar.dock.collapsed
    property int selectedTab: Persistent.states.sidebar.dock.tab

    property var windows: []
    property var windowsKeys: []

    property var occupiedIds: {
        const set = new Set();
        Hyprland.workspaces.values.forEach(ws => {
            if (ws.monitor?.name === monitor?.name) set.add(ws.id);
        });
        return set;
    }
    property var occupiedIdsKeys: [...occupiedIds]

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
        Persistent.states.sidebar.dock.collapsed = state;
    }

    function setTab(index) {
        root.selectedTab = index;
        Persistent.states.sidebar.dock.tab = index;
    }

    Connections {
        target: ToplevelManager.toplevels
        function onValuesChanged() { root.refresh(); }
    }
    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            root.refresh();
            root.occupiedIdsKeys = [...root.occupiedIds];
        }
    }
    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            root.occupiedIdsKeys = [...root.occupiedIds];
        }
    }
    Component.onCompleted: root.refresh()

    readonly property var activeToplevel: {
        for (const t of root.windowsKeys) {
            if (t.HyprlandToplevel?.activated) return t;
        }
        return null;
    }

    implicitWidth: 200
    implicitHeight: collapsed ? headerRow.implicitHeight + 12 : headerRow.implicitHeight + tabBar.implicitHeight + (selectedTab === 0 ? Math.min(windowsList.count * 34 + 16, 280) : workspaceGrid.implicitHeight + 12)

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
            Layout.bottomMargin: 2
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
                text: root.selectedTab === 0 ? Translation.tr("Windows") : Translation.tr("Workspaces")
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
                color: Appearance.colors.colOnLayer1
            }
            Rectangle { // Window count badge
                visible: !collapsed && root.selectedTab === 0 && root.windowsKeys.length > 0
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

        SecondaryTabBar { // Tab switcher (Windows | Workspaces)
            // Was using bare TabButton for its children — every other
            // SecondaryTabBar in the shell (timetable, pomodoro, todo,
            // volume mixer, resources) uses SecondaryTabButton instead,
            // which is what actually carries the pill background, colored
            // checked-state text and ripple. Plain TabButton falls back to
            // the app's Basic QQC2 style, so this one tab bar rendered as a
            // crude flat segmented control instead of matching the rest of
            // the app.
            id: tabBar
            visible: !collapsed
            Layout.fillWidth: true
            Layout.leftMargin: 6
            Layout.rightMargin: 6
            currentIndex: root.selectedTab
            onCurrentIndexChanged: root.setTab(tabBar.currentIndex)

            SecondaryTabButton {
                buttonText: Translation.tr("Windows")
                buttonIcon: "list"
            }
            SecondaryTabButton {
                buttonText: Translation.tr("Workspaces")
                buttonIcon: "grid_view"
            }
        }

        ListView { // Windows list
            id: windowsList
            visible: !collapsed && root.selectedTab === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            Layout.bottomMargin: 8
            Layout.topMargin: 4
            clip: true
            model: root.windowsKeys
            spacing: 4

            delegate: WindowButton {
                id: row
                required property var modelData
                width: ListView.view.width
                height: 30
                toplevel: modelData
            }
        }

        GridLayout { // Workspace grid
            id: workspaceGrid
            visible: !collapsed && root.selectedTab === 1
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            Layout.bottomMargin: 8
            Layout.topMargin: 4
            columns: 3
            rowSpacing: 4
            columnSpacing: 4

            Repeater {
                model: root.workspacesShown
                delegate: Item {
                    id: wsWrapper
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24
                    required property int index

                    WorkspaceButton {
                        anchors.fill: parent
                        workspaceId: wsWrapper.index + 1
                        active: workspaceId === root.activeWorkspaceId
                        occupied: root.occupiedIds.has(workspaceId)
                        onClicked: Quickshell.execDetached(["hyprctl", "dispatch", "workspace", String(workspaceId)])
                    }
                }
            }
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
            anchors.margins: 6
            spacing: 8

            IconImage {
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
                Layout.alignment: Qt.AlignVCenter
                source: Quickshell.iconPath(button.desktopEntry?.icon ?? "", "image-missing")
            }

            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: button.toplevel.title || button.desktopEntry?.name || button.toplevel.appId
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.weight: button.isActive ? Font.DemiBold : Font.Normal
                color: Appearance.colors.colOnLayer1
                elide: Text.ElideRight
            }

            MaterialSymbol {
                Layout.alignment: Qt.AlignVCenter
                text: "close"
                iconSize: 13
                color: Appearance.colors.colSubtext
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: toplevel.close()
                }
            }
        }
    }

    component WorkspaceButton: Rectangle {
        id: wsButton
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
            onClicked: wsButton.clicked()
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 4

            MaterialSymbol {
                text: "circle"
                iconSize: 9
                color: wsButton.active ? Appearance.m3colors.m3onPrimary : Appearance.colors.colOnLayer1
                fill: wsButton.occupied ? 1 : 0
            }
            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: wsButton.workspaceId
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.weight: Font.DemiBold
                color: wsButton.active ? Appearance.m3colors.m3onPrimary : Appearance.colors.colOnLayer1
            }
        }
    }
}
