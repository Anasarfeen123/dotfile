pragma ComponentBehavior: Bound

import Qt.labs.synchronizer
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell

import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Item { // Wrapper
    id: root

    readonly property string xdgConfigHome: Directories.config
    readonly property int typingDebounceInterval: 200
    // This slices resultModel.values, i.e. what's *actually scrollable* --
    // not just what's visible at once (ListView virtualizes rendering, so a
    // large model here is cheap). Was 15, which is fine for app search
    // (narrows fast as you type) but silently broke clipboard browsing:
    // the footer's "395 results" reads LauncherSearch.results.length
    // directly (unsliced), while the real scrollable list quietly stopped
    // at item 15 — so scrolling past that showed nothing but blank panel,
    // looking exactly like the list had crashed.
    readonly property int typingResultLimit: 500

    // Exposed so the outer capsule (Overview.qml's revealClip) can match
    // its own expanded corner radius to this instead of using an unrelated
    // fixed token — the search bar sits right at the panel's top edge, so
    // their top corners are physically the same corner and need to agree.
    readonly property real cornerRadius: searchWidgetContent.radius

    property string searchingText: LauncherSearch.query
    property bool showResults: searchingText != ""
    implicitWidth: searchWidgetContent.implicitWidth + Appearance.sizes.elevationMargin * 2
    implicitHeight: searchWidgetContent.implicitHeight + searchBar.verticalPadding * 2 + Appearance.sizes.elevationMargin * 2

    function focusFirstItem() {
        appResults.currentIndex = 0;
    }

    function focusSearchInput() {
        searchBar.forceFocus();
    }

    function disableExpandAnimation() {
        searchBar.animateWidth = false;
    }

    function cancelSearch() {
        searchBar.searchInput.selectAll();
        LauncherSearch.query = "";
        searchBar.animateWidth = true;
    }

    function setSearchingText(text) {
        searchBar.searchInput.text = text;
        LauncherSearch.query = text;
    }

    Keys.onPressed: event => {
        // Prevent Esc and Backspace from registering
        if (event.key === Qt.Key_Escape)
            return;

        // Handle Backspace: focus and delete character if not focused
        if (event.key === Qt.Key_Backspace) {
            if (!searchBar.searchInput.activeFocus) {
                root.focusSearchInput();
                if (event.modifiers & Qt.ControlModifier) {
                    // Delete word before cursor
                    let text = searchBar.searchInput.text;
                    let pos = searchBar.searchInput.cursorPosition;
                    if (pos > 0) {
                        // Find the start of the previous word
                        let left = text.slice(0, pos);
                        let match = left.match(/(\s*\S+)\s*$/);
                        let deleteLen = match ? match[0].length : 1;
                        searchBar.searchInput.text = text.slice(0, pos - deleteLen) + text.slice(pos);
                        searchBar.searchInput.cursorPosition = pos - deleteLen;
                    }
                } else {
                    // Delete character before cursor if any
                    if (searchBar.searchInput.cursorPosition > 0) {
                        searchBar.searchInput.text = searchBar.searchInput.text.slice(0, searchBar.searchInput.cursorPosition - 1) + searchBar.searchInput.text.slice(searchBar.searchInput.cursorPosition);
                        searchBar.searchInput.cursorPosition -= 1;
                    }
                }
                // Always move cursor to end after programmatic edit
                searchBar.searchInput.cursorPosition = searchBar.searchInput.text.length;
                event.accepted = true;
            }
            // If already focused, let TextField handle it
            return;
        }

        // Only handle visible printable characters (ignore control chars, arrows, etc.)
        if (event.text && event.text.length === 1 && event.key !== Qt.Key_Enter && event.key !== Qt.Key_Return && event.key !== Qt.Key_Delete && event.text.charCodeAt(0) >= 0x20) // ignore control chars like Backspace, Tab, etc.
        {
            if (!searchBar.searchInput.activeFocus) {
                root.focusSearchInput();
                // Insert the character at the cursor position
                searchBar.searchInput.text = searchBar.searchInput.text.slice(0, searchBar.searchInput.cursorPosition) + event.text + searchBar.searchInput.text.slice(searchBar.searchInput.cursorPosition);
                searchBar.searchInput.cursorPosition += 1;
                event.accepted = true;
                root.focusFirstItem();
            }
        }
    }

    Rectangle { // Background
        id: searchWidgetContent
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: Appearance.sizes.elevationMargin
        }
        clip: true
        implicitWidth: columnLayout.implicitWidth
        implicitHeight: columnLayout.implicitHeight
        radius: searchBar.height / 2 + searchBar.verticalPadding
        // Same glass recipe as the sidebars/dock, rather than the M3
        // surface-container token this used before — keeps the whole
        // overview reading as one consistent frosted-glass surface.
        color: ColorUtils.applyAlpha(Appearance.colors.colLayer0Base, 0.72)

        Behavior on implicitHeight {
            id: searchHeightBehavior
            enabled: GlobalStates.overviewOpen && root.showResults
            animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
        }

        // This and OverviewWidget below it are two panes of one floating
        // capsule (Overview.qml's revealClip owns the outer shape + shadow
        // now), not separate standalone cards — each having its own border
        // and drop shadow made them read as two stacked boxes with a
        // visible seam between them instead of one fluid surface.

        ColumnLayout {
            id: columnLayout
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            spacing: 0

            // clip: true
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: searchWidgetContent.width
                    // Was searchWidgetContent.width here too — a square
                    // mask capped at the (usually narrower) width, which
                    // clips the bottom of the results list off once the
                    // widget expands taller than it is wide.
                    height: searchWidgetContent.height
                    radius: searchWidgetContent.radius
                }
            }

            SearchBar {
                id: searchBar
                property real verticalPadding: 4
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 4
                Layout.topMargin: verticalPadding
                Layout.bottomMargin: verticalPadding
                Synchronizer on searchingText {
                    property alias source: root.searchingText
                }
            }

            Rectangle {
                // Separator
                visible: root.showResults
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                height: 1
                color: ColorUtils.applyAlpha(Appearance.colors.colOutlineVariant, 0.6)
            }

            // Was a plain ListView — results popping in/reordering as you
            // type had zero animation, they just instantly appeared and
            // snapped into position. StyledListView adds the same fade+pop
            // add/remove transitions notifications and other lists already
            // use elsewhere in the shell.
            StyledListView { // App results
                id: appResults
                visible: root.showResults
                Layout.fillWidth: true
                // Was capped at 600 — for clipboard/big result sets that
                // made the whole glass panel stretch nearly the height of
                // the screen. Capped shorter so it stays a compact search
                // box that scrolls, instead of a giant black slab.
                implicitHeight: Math.min(420, appResults.contentHeight + topMargin + bottomMargin)
                clip: true
                topMargin: 10
                bottomMargin: 10
                spacing: 2
                KeyNavigation.up: searchBar
                highlightMoveDuration: 100

                onFocusChanged: {
                    if (focus)
                        appResults.currentIndex = 1;
                }

                Connections {
                    target: root
                    function onSearchingTextChanged() {
                        if (appResults.count > 0)
                            appResults.currentIndex = 0;
                    }
                }

                Timer {
                    id: debounceTimer
                    interval: root.typingDebounceInterval
                    onTriggered: {
                        resultModel.values = LauncherSearch.results ?? [];
                    }
                }

                Connections {
                    target: LauncherSearch
                    function onResultsChanged() {
                        resultModel.values = LauncherSearch.results.slice(0, root.typingResultLimit);
                        root.focusFirstItem();
                        debounceTimer.restart();
                    }
                }

                model: ScriptModel {
                    id: resultModel
                    objectProp: "key"
                }

                delegate: SearchItem {
                    id: searchItem
                    // The selectable item for each search result
                    required property var modelData
                    anchors.left: parent?.left
                    anchors.right: parent?.right
                    entry: modelData
                    query: StringUtils.cleanOnePrefix(root.searchingText, [Config.options.search.prefix.action, Config.options.search.prefix.app, Config.options.search.prefix.clipboard, Config.options.search.prefix.emojis, Config.options.search.prefix.math, Config.options.search.prefix.shellCommand, Config.options.search.prefix.webSearch, Config.options.search.prefix.windows, Config.options.search.prefix.weather, Config.options.search.prefix.file])

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Tab) {
                            if (LauncherSearch.results.length === 0)
                                return;
                            const tabbedText = searchItem.modelData.name;
                            LauncherSearch.query = tabbedText;
                            searchBar.searchInput.text = tabbedText;
                            event.accepted = true;
                            root.focusSearchInput();
                        }
                    }
                }

                // Footer: keyboard hint + result count
                //
                // This used to be a plain child of the ListView using
                // Layout.fillWidth/leftMargin/etc — but ListView isn't a
                // Layout, so none of those attached properties did anything.
                // The row just sat at its implicit (0,0) position instead of
                // trailing the list, which is why there was never a real
                // bottom margin below the results: this "footer" wasn't
                // actually part of the scrollable footer area at all. Using
                // the real ListView.footer property fixes that properly.
                footer: Item {
                    width: appResults.width
                    implicitHeight: visible ? footerRow.implicitHeight + 16 : 0
                    visible: root.showResults && resultModel.values.length > 0

                    RowLayout {
                        id: footerRow
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            leftMargin: 14
                            rightMargin: 12
                            topMargin: 6
                        }
                        spacing: 8

                        StyledText {
                            Layout.fillWidth: true
                            Layout.maximumWidth: 120
                            Layout.alignment: Qt.AlignVCenter
                            text: Translation.tr("%1 results").arg(LauncherSearch.results.length)
                            font.pixelSize: Appearance.font.pixelSize.smallest
                            color: Appearance.colors.colSubtext
                            elide: Text.ElideRight
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            RowLayout {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 10
                                Repeater {
                                    model: [
                                        {key: "↑↓", label: Translation.tr("Navigate")},
                                        {key: "Tab", label: Translation.tr("Tab")},
                                        {key: "↵", label: Translation.tr("Open")},
                                    ]
                                    delegate: RowLayout {
                                        required property var modelData
                                        spacing: 4
                                        KeyboardKey {
                                            key: modelData.key
                                            pixelSize: Appearance.font.pixelSize.smallest
                                        }
                                        StyledText {
                                            text: modelData.label
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            color: Appearance.colors.colSubtext
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
