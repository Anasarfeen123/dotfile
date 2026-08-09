pragma ComponentBehavior: Bound
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

StyledGlassSurface {
    id: root
    fillOpacity: 0.38
    

    property list<DesktopEntry> entries: []

    function refreshEntries() {
        root.entries = Config.ready ? Config.options.launcher.pinnedApps.map(appId => DesktopEntries.byId(appId)).filter(e => e != null) : [];
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() {
            root.refreshEntries();
        }
    }

    Connections {
        target: Config
        function onReadyChanged() {
            root.refreshEntries();
        }
    }

    Component.onCompleted: root.refreshEntries()

    implicitHeight: row.implicitHeight + 12
    implicitWidth: 200

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.margins: 6
        spacing: 4

        Repeater {
            model: root.entries
            delegate: QuickLaunchButton {
                id: btn
                required property var modelData
                desktopEntry: modelData
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                onClicked: {
                    if (desktopEntry) desktopEntry.execute();
                }
                PopupToolTip {
                    text: btn.desktopEntry?.name ?? ""
                    anchorEdges: Edges.Top
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    component QuickLaunchButton: RippleButton {
        id: qlb
        required property var desktopEntry
        buttonRadius: Appearance.rounding.small

        contentItem: Item {
            IconImage {
                anchors.centerIn: parent
                width: 22
                height: 22
                source: Quickshell.iconPath(qlb.desktopEntry?.icon ?? "", "image-missing")
            }
        }
    }
}
