//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

// Adjust this to make the app smaller or larger
//@ pragma Env QT_SCALE_FACTOR=1

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions as CF

ApplicationWindow {
    id: root
    property string firstRunFilePath: CF.FileUtils.trimFileProtocol(`${Directories.state}/user/first_run.txt`)
    property string firstRunFileContent: "This file is just here to confirm you've been greeted :>"
    property real contentPadding: 8
    property bool showNextTime: false
    property string pendingScrollTitle: ""
    property var pages: [
        {
            name: Translation.tr("Quick"),
            icon: "instant_mix",
            component: "modules/settings/QuickConfig.qml"
        },
        {
            name: Translation.tr("General"),
            icon: "browse",
            component: "modules/settings/GeneralConfig.qml"
        },
        {
            name: Translation.tr("Bar"),
            icon: "toast",
            iconRotation: 180,
            component: "modules/settings/BarConfig.qml"
        },
        {
            name: Translation.tr("Background"),
            icon: "texture",
            component: "modules/settings/BackgroundConfig.qml"
        },
        {
            name: Translation.tr("Interface"),
            icon: "bottom_app_bar",
            component: "modules/settings/InterfaceConfig.qml"
        },
        {
            name: Translation.tr("Services"),
            icon: "settings",
            component: "modules/settings/ServicesConfig.qml"
        },
        {
            name: Translation.tr("Advanced"),
            icon: "construction",
            component: "modules/settings/AdvancedConfig.qml"
        },
        {
            name: Translation.tr("About"),
            icon: "info",
            component: "modules/settings/About.qml"
        }
    ]

    // Static search index: every top-level settings section, with keywords.
    // `page` indexes into `pages`; `title` must match the ContentSection title.
    property var searchIndex: [
        { page: 0, title: Translation.tr("Wallpaper & Colors"), keywords: "wallpaper colors color palette theme background wallpaper" },
        { page: 0, title: Translation.tr("Bar & screen"), keywords: "bar screen corner round" },
        { page: 1, title: Translation.tr("Audio"), keywords: "audio volume sound output" },
        { page: 1, title: Translation.tr("Battery"), keywords: "battery power charge" },
        { page: 1, title: Translation.tr("Language"), keywords: "language locale translation interface" },
        { page: 1, title: Translation.tr("Policies"), keywords: "policies policy consent data" },
        { page: 1, title: Translation.tr("Sounds"), keywords: "sounds sound effects" },
        { page: 1, title: Translation.tr("Time"), keywords: "time clock format date" },
        { page: 1, title: Translation.tr("Work safety"), keywords: "work safety health pomodoro" },
        { page: 2, title: Translation.tr("Notifications"), keywords: "notifications notif notify" },
        { page: 2, title: Translation.tr("Positioning"), keywords: "position bar position hide corner style group" },
        { page: 2, title: Translation.tr("Tray"), keywords: "tray system tray icons" },
        { page: 2, title: Translation.tr("Utility buttons"), keywords: "utility buttons tools" },
        { page: 2, title: Translation.tr("Audio visualizer"), keywords: "audio visualizer music bars" },
        { page: 2, title: Translation.tr("Weather"), keywords: "weather forecast" },
        { page: 2, title: Translation.tr("Workspaces"), keywords: "workspaces numbers style" },
        { page: 2, title: Translation.tr("Tooltips"), keywords: "tooltips tooltip hover" },
        { page: 3, title: Translation.tr("Parallax"), keywords: "parallax depth wallpaper" },
        { page: 3, title: Translation.tr("Widget: Clock"), keywords: "clock widget digital cookie dial hands quote date" },
        { page: 3, title: Translation.tr("Widget: Weather"), keywords: "weather widget forecast" },
        { page: 4, title: Translation.tr("Cheat sheet"), keywords: "cheat sheet shortcuts keybinds super key" },
        { page: 4, title: Translation.tr("Dock"), keywords: "dock icons launcher" },
        { page: 4, title: Translation.tr("Lock screen"), keywords: "lock screen security blur style" },
        { page: 4, title: Translation.tr("Notifications"), keywords: "notifications notif notify" },
        { page: 4, title: Translation.tr("Overlay: General"), keywords: "overlay general" },
        { page: 4, title: Translation.tr("Overlay: Crosshair"), keywords: "overlay crosshair" },
        { page: 4, title: Translation.tr("Overlay: Floating Image"), keywords: "overlay floating image" },
        { page: 4, title: Translation.tr("Region selector (screen snipping/Google Lens)"), keywords: "region selector snipping screenshot google lens selection" },
        { page: 4, title: Translation.tr("Sidebars"), keywords: "sidebar toggles sliders corner" },
        { page: 4, title: Translation.tr("Scrolling"), keywords: "scrolling scroll speed" },
        { page: 4, title: Translation.tr("Blur"), keywords: "blur background glass" },
        { page: 4, title: Translation.tr("On-screen display"), keywords: "on screen display osd" },
        { page: 4, title: Translation.tr("Overview"), keywords: "overview windows workspace" },
        { page: 4, title: Translation.tr("Wallpaper selector"), keywords: "wallpaper selector" },
        { page: 4, title: Translation.tr("Fonts"), keywords: "fonts font main numbers title monospace nerd reading expressive" },
        { page: 5, title: Translation.tr("AI"), keywords: "ai assistant gemini model" },
        { page: 5, title: Translation.tr("Music Recognition"), keywords: "music recognition shazam song" },
        { page: 5, title: Translation.tr("Networking"), keywords: "networking network wifi" },
        { page: 5, title: Translation.tr("Resources"), keywords: "resources system monitor cpu memory" },
        { page: 5, title: Translation.tr("Save paths"), keywords: "save paths directory screenshots" },
        { page: 5, title: Translation.tr("Search"), keywords: "search web prefix google" },
        { page: 5, title: Translation.tr("Weather"), keywords: "weather forecast" },
        { page: 6, title: Translation.tr("Color generation"), keywords: "color generation scheme material" },
        { page: 7, title: Translation.tr("Distro"), keywords: "distro system os" },
        { page: 7, title: Translation.tr("Dotfiles"), keywords: "dotfiles config files" }
    ]

    property int currentPage: 0

    visible: true
    onClosing: Qt.quit()
    title: "illogical-impulse Settings"

    Component.onCompleted: {
        MaterialThemeLoader.reapplyTheme()
        Config.readWriteDelay = 0 // Settings app always only sets one var at a time so delay isn't needed
    }

    minimumWidth: 750
    minimumHeight: 500
    width: 1100
    height: 750
    color: Appearance.m3colors.m3background

    ListModel {
        id: searchResultsModel
    }

    function updateSearchResults() {
        searchResultsModel.clear()
        const q = searchField.text.trim().toLowerCase()
        if (q.length === 0) return
        const tokens = q.split(/\s+/)
        for (const entry of searchIndex) {
            const hay = (entry.title + " " + entry.keywords).toLowerCase()
            if (tokens.every(t => hay.includes(t))) {
                searchResultsModel.append({ page: entry.page, sectionTitle: entry.title })
                if (searchResultsModel.count >= 40) return
            }
        }
    }

    function navigateToSearchResult(page, sectionTitle) {
        searchField.text = ""
        searchField.focus = false
        if (root.currentPage !== page) {
            root.pendingScrollTitle = sectionTitle
            root.currentPage = page
        } else {
            pageLoader.item?.scrollToTitle(sectionTitle)
        }
    }

    function openSearch() {
        searchField.forceActiveFocus()
        searchField.selectAll()
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: contentPadding
        }

        Keys.onPressed: (event) => {
            if (event.modifiers === Qt.ControlModifier) {
                if (event.key === Qt.Key_F) {
                    root.openSearch()
                    event.accepted = true;
                }
                else if (event.key === Qt.Key_PageDown) {
                    root.currentPage = Math.min(root.currentPage + 1, root.pages.length - 1)
                    event.accepted = true;
                }
                else if (event.key === Qt.Key_PageUp) {
                    root.currentPage = Math.max(root.currentPage - 1, 0)
                    event.accepted = true;
                }
                else if (event.key === Qt.Key_Tab) {
                    root.currentPage = (root.currentPage + 1) % root.pages.length;
                    event.accepted = true;
                }
                else if (event.key === Qt.Key_Backtab) {
                    root.currentPage = (root.currentPage - 1 + root.pages.length) % root.pages.length;
                    event.accepted = true;
                }
            }
        }

        Item { // Titlebar
            visible: Config.options?.windows.showTitlebar
            Layout.fillWidth: true
            Layout.fillHeight: false
            implicitHeight: Math.max(titleText.implicitHeight, searchAndControlsRow.implicitHeight)
            StyledText {
                id: titleText
                anchors {
                    left: Config.options.windows.centerTitle ? undefined : parent.left
                    horizontalCenter: Config.options.windows.centerTitle ? parent.horizontalCenter : undefined
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                }
                color: Appearance.colors.colOnLayer0
                text: Translation.tr("Settings") + (root.currentPage > 0 ? ` — ${root.pages[root.currentPage].name}` : "")
                font {
                    family: Appearance.font.family.title
                    pixelSize: Appearance.font.pixelSize.title
                    variableAxes: Appearance.font.variableAxes.title
                }
            }

            RowLayout { // Search + window controls
                id: searchAndControlsRow
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                spacing: 6

                Rectangle { // Search field
                    id: searchBar
                    implicitWidth: 320
                    implicitHeight: 40
                    radius: Appearance.rounding.full
                    color: Appearance.m3colors.m3surfaceContainerHigh
                    border.color: searchField.activeFocus ? Appearance.colors.colPrimary : Appearance.colors.colOutlineVariant

                    RowLayout {
                        anchors {
                            fill: parent
                            margins: 4
                        }
                        spacing: 4

                        MaterialSymbol {
                            Layout.leftMargin: 8
                            text: "search"
                            iconSize: 18
                            color: Appearance.m3colors.m3outline
                            verticalAlignment: Text.AlignVCenter
                        }

                        TextField {
                            id: searchField
                            Layout.fillWidth: true
                            verticalAlignment: Text.AlignVCenter
                            placeholderText: Translation.tr("Search settings")
                            color: Appearance.colors.colOnLayer1
                            placeholderTextColor: Appearance.m3colors.m3outline
                            selectionColor: Appearance.colors.colSecondaryContainer
                            selectedTextColor: Appearance.colors.colOnSecondaryContainer
                            font {
                                family: Appearance.font.family.main
                                pixelSize: Appearance.font.pixelSize.small
                                hintingPreference: Font.PreferFullHinting
                                variableAxes: Appearance.font.variableAxes.main
                            }
                            renderType: Text.NativeRendering
                            clip: true
                            background: Item {}
                            onTextChanged: root.updateSearchResults()
                            Keys.onPressed: (event) => {
                                if (event.key === Qt.Key_Escape) {
                                    searchField.text = ""
                                    searchField.focus = false
                                    event.accepted = true;
                                }
                                else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    if (searchResultsModel.count > 0) {
                                        root.navigateToSearchResult(searchResultsModel.get(0).page, searchResultsModel.get(0).sectionTitle)
                                    }
                                    event.accepted = true;
                                }
                                else if (event.key === Qt.Key_Down) {
                                    searchResultsList.forceActiveFocus()
                                    searchResultsList.currentIndex = 0
                                    event.accepted = true;
                                }
                            }
                        }

                        RippleButton {
                            visible: searchField.text.length > 0
                            implicitWidth: 26
                            implicitHeight: 26
                            buttonRadius: Appearance.rounding.full
                            onClicked: searchField.text = ""
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                text: "close"
                                iconSize: 16
                            }
                            StyledToolTip {
                                text: Translation.tr("Clear search (Esc)")
                            }
                        }

                        Item { Layout.preferredWidth: 2 }
                    }
                }

                RippleButton { // Window controls
                    buttonRadius: Appearance.rounding.full
                    implicitWidth: 35
                    implicitHeight: 35
                    onClicked: root.close()
                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: "close"
                        iconSize: 20
                    }
                    StyledToolTip {
                        text: Translation.tr("Close settings")
                    }
                }
            }
        }

        RowLayout { // Window content with navigation rail and content pane
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: contentPadding
            Item {
                id: navRailWrapper
                Layout.fillHeight: true
                Layout.margins: 5
                implicitWidth: navRail.expanded ? 150 : fab.baseSize
                Behavior on implicitWidth {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
                NavigationRail { // Window content with navigation rail and content pane
                    id: navRail
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    spacing: 10
                    expanded: root.width > 900
                    
                    NavigationRailExpandButton {
                        focus: root.visible
                    }

                    FloatingActionButton {
                        id: fab
                        property bool justCopied: false
                        iconText: justCopied ? "check" : "edit"
                        buttonText: justCopied ? Translation.tr("Path copied") : Translation.tr("Config file")
                        expanded: navRail.expanded
                        downAction: () => {
                            Qt.openUrlExternally(`${Directories.config}/illogical-impulse/config.json`);
                        }
                        altAction: () => {
                            Quickshell.clipboardText = CF.FileUtils.trimFileProtocol(`${Directories.config}/illogical-impulse/config.json`);
                            fab.justCopied = true;
                            revertTextTimer.restart()
                        }

                        Timer {
                            id: revertTextTimer
                            interval: 1500
                            onTriggered: {
                                fab.justCopied = false;
                            }
                        }

                        StyledToolTip {
                            text: Translation.tr("Open the shell config file\nAlternatively right-click to copy path")
                        }
                    }

                    NavigationRailTabArray {
                        currentIndex: root.currentPage
                        expanded: navRail.expanded
                        Repeater {
                            model: root.pages
                            NavigationRailButton {
                                required property var index
                                required property var modelData
                                toggled: root.currentPage === index
                                onPressed: root.currentPage = index;
                                expanded: navRail.expanded
                                buttonIcon: modelData.icon
                                buttonIconRotation: modelData.iconRotation || 0
                                buttonText: modelData.name
                                showToggledHighlight: false
                            }
                        }
                    }

                    SectionNavList {
                        sectionTitles: pageLoader.item ? pageLoader.item.sectionTitles : []
                        currentIndex: pageLoader.item ? pageLoader.item.currentSection : -1
                        selected: navRail.expanded
                        onSectionClicked: index => pageLoader.item?.scrollToSection(index)
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
            Rectangle { // Content container
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Appearance.m3colors.m3surfaceContainerLow
                radius: Appearance.rounding.windowRounding - root.contentPadding
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Loader {
                        id: pageLoader
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        opacity: 1.0
                        asynchronous: true

                        active: Config.ready
                        Component.onCompleted: {
                            source = root.pages[0].component
                        }
                        onLoaded: {
                            if (root.pendingScrollTitle.length > 0) {
                                pageLoader.item.scrollToTitle(root.pendingScrollTitle)
                                root.pendingScrollTitle = ""
                            }
                        }

                        Connections {
                            target: root
                            function onCurrentPageChanged() {
                                switchAnim.complete();
                                switchAnim.start();
                            }
                        }

                        SequentialAnimation {
                            id: switchAnim

                            NumberAnimation {
                                target: pageLoader
                                properties: "opacity"
                                from: 1
                                to: 0
                                duration: 70
                                easing.type: Appearance.animation.elementMoveExit.type
                                easing.bezierCurve: Appearance.animationCurves.emphasizedFirstHalf
                            }
                            ParallelAnimation {
                                PropertyAction {
                                    target: pageLoader
                                    property: "source"
                                    value: root.pages[root.currentPage].component
                                }
                            }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: pageLoader
                                    properties: "opacity"
                                    from: 0
                                    to: 1
                                    duration: 140
                                    easing.type: Appearance.animation.elementMoveEnter.type
                                    easing.bezierCurve: Appearance.animationCurves.emphasizedLastHalf
                                }
                            }
                        }
                    }

                    RowLayout { // Footer: save status + config actions
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        implicitHeight: 30
                        spacing: 8

                        MaterialSymbol {
                            Layout.leftMargin: 10
                            text: "cloud_done"
                            iconSize: 16
                            color: Appearance.colors.colPrimary
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: Translation.tr("Changes are saved automatically")
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.colOnLayer2
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                        }
                        StyledText {
                            visible: Config.lastSavedTime.length > 0
                            text: Translation.tr("Saved") + " " + Config.lastSavedTime
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.colOnLayer3
                        }
                        RippleButton { // Copy config to clipboard
                            id: copyConfigBtn
                            buttonRadius: Appearance.rounding.full
                            implicitWidth: 32
                            implicitHeight: 28
                            onClicked: {
                                Quickshell.clipboardText = Config.toJsonString()
                                copyConfigBtn.justCopied = true
                                copyRevertTimer.restart()
                            }
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                text: copyConfigBtn.justCopied ? "check" : "content_copy"
                                iconSize: 16
                            }
                            StyledToolTip {
                                text: copyConfigBtn.justCopied ? Translation.tr("Config copied") : Translation.tr("Copy the full config to clipboard")
                            }
                            property bool justCopied: false
                            Timer {
                                id: copyRevertTimer
                                interval: 1500
                                onTriggered: copyConfigBtn.justCopied = false
                            }
                        }
                        RippleButton { // Reset this page to defaults
                            id: resetPageBtn
                            buttonRadius: Appearance.rounding.full
                            implicitWidth: 32
                            implicitHeight: 28
                            onClicked: {
                                if (resetPageBtn.armed) {
                                    Config.resetToDefaults(pageLoader.item?.resetPaths ?? [])
                                    resetPageBtn.armed = false
                                } else {
                                    resetPageBtn.armed = true
                                    resetArmTimer.restart()
                                }
                            }
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                text: resetPageBtn.armed ? "warning" : "restore"
                                iconSize: 16
                            }
                            StyledToolTip {
                                text: resetPageBtn.armed ? Translation.tr("Click again to reset this page to defaults") : Translation.tr("Reset this page to defaults")
                            }
                            property bool armed: false
                            Timer {
                                id: resetArmTimer
                                interval: 2500
                                onTriggered: resetPageBtn.armed = false
                            }
                        }
                        RippleButton { // Reload config from disk
                            buttonRadius: Appearance.rounding.full
                            implicitWidth: 32
                            implicitHeight: 28
                            onClicked: Config.reloadFromDisk()
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                text: "refresh"
                                iconSize: 16
                            }
                            StyledToolTip {
                                text: Translation.tr("Reload the config from disk\n(undoes changes written outside the app)")
                            }
                        }
                        RippleButton {  // Open config file
                            buttonRadius: Appearance.rounding.full
                            implicitWidth: 32
                            implicitHeight: 28
                            onClicked: Qt.openUrlExternally(`${Directories.config}/illogical-impulse/config.json`)
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                text: "open_in_new"
                                iconSize: 16
                            }
                            StyledToolTip {
                                text: Translation.tr("Open the config file in your editor")
                            }
                        }
                    }
                }

                Rectangle { // Search results dropdown
                    id: searchDropdown
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                        topMargin: 12
                    }
                    width: Math.min(600, parent.width - 40)
                    height: Math.min(searchResultsList.implicitHeight, 420)
                    radius: Appearance.rounding.windowRounding - root.contentPadding
                    color: Appearance.m3colors.m3surfaceContainerHigh
                    border.color: Appearance.colors.colOutlineVariant
                    z: 100
                    visible: searchField.text.length > 0

                    ListView {
                        id: searchResultsList
                        anchors.fill: parent
                        anchors.margins: 4
                        clip: true
                        model: searchResultsModel
                        currentIndex: -1

                        delegate: ItemDelegate {
                            required property var model
                            id: resultDelegate
                            width: ListView.view.width - 8
                            height: 44
                            opacity: 0
                            Behavior on opacity { NumberAnimation { duration: 90 } }
                            Component.onCompleted: opacity = 1

                            RowLayout {
                                anchors {
                                    fill: parent
                                    leftMargin: 12
                                    rightMargin: 12
                                }
                                spacing: 10

                                MaterialSymbol {
                                    text: root.pages[model.page].icon
                                    iconSize: 20
                                    color: Appearance.colors.colOnLayer1
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    StyledText {
                                        text: model.sectionTitle
                                        font.pixelSize: Appearance.font.pixelSize.normal
                                        font.weight: Font.Medium
                                        color: Appearance.colors.colOnLayer1
                                    }
                                    StyledText {
                                        text: root.pages[model.page].name
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer2
                                    }
                                }
                                MaterialSymbol {
                                    text: "arrow_forward"
                                    iconSize: 16
                                    color: Appearance.colors.colPrimary
                                }
                            }

                            background: Rectangle {
                                radius: Appearance.rounding.normal
                                color: resultDelegate.hovered ? Appearance.colors.colSecondaryContainerHover : "transparent"
                            }
                            hoverEnabled: true
                            onClicked: root.navigateToSearchResult(model.page, model.sectionTitle)
                        }
                    }
                }
            }
        }
    }
}
