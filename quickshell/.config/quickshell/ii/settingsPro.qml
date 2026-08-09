//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000
//@ pragma Env QT_SCALE_FACTOR=1

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.settingsPro.widgets
import qs.modules.common.functions as CF

// "ii Settings" — a from-scratch, glassy/translucent reskin of illogical-impulse's own
// settings app, wired to the same live Config singleton (~/.config/illogical-impulse/config.json)
// so every control here actually drives the running shell. See ../settings.qml for the
// original this is modeled on; that file is untouched.
ApplicationWindow {
    id: root
    property real contentPadding: 10
    property string pendingScrollTitle: ""

    property var pages: [
        { name: Translation.tr("Quick"), icon: "instant_mix", component: "modules/settingsPro/pages/QuickPage.qml" },
        { name: Translation.tr("General"), icon: "browse", component: "modules/settingsPro/pages/GeneralPage.qml" },
        { name: Translation.tr("Bar"), icon: "toast", iconRotation: 180, component: "modules/settingsPro/pages/BarPage.qml" },
        { name: Translation.tr("Background"), icon: "texture", component: "modules/settingsPro/pages/BackgroundPage.qml" },
        { name: Translation.tr("Interface"), icon: "bottom_app_bar", component: "modules/settingsPro/pages/InterfacePage.qml" },
        { name: Translation.tr("Services"), icon: "settings", component: "modules/settingsPro/pages/ServicesPage.qml" },
        { name: Translation.tr("Advanced"), icon: "construction", component: "modules/settingsPro/pages/AdvancedPage.qml" },
        { name: Translation.tr("About"), icon: "info", component: "modules/settingsPro/pages/AboutPage.qml" }
    ]

    // Same static search index as the original app (page indices line up 1:1 with `pages` above).
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
    title: "ii Settings"

    Component.onCompleted: {
        MaterialThemeLoader.reapplyTheme()
        Config.readWriteDelay = 0
    }

    minimumWidth: 780
    minimumHeight: 520
    width: 1150
    height: 780
    color: "transparent" // fully translucent — Hyprland's window blur/opacity rule does the rest

    ListModel { id: searchResultsModel }

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

    // Base wash so the whole window reads as one dark slab even where no card sits —
    // matches the rest of the shell's dark surfaces rather than washing out to the wallpaper.
    Rectangle {
        anchors.fill: parent
        radius: Appearance.rounding.windowRounding
        color: CF.ColorUtils.applyAlpha(Appearance.m3colors.m3background, 0.75)
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: root.contentPadding
        }
        spacing: root.contentPadding

        Keys.onPressed: event => {
            if (event.modifiers === Qt.ControlModifier) {
                if (event.key === Qt.Key_F) { root.openSearch(); event.accepted = true }
                else if (event.key === Qt.Key_PageDown) { root.currentPage = Math.min(root.currentPage + 1, root.pages.length - 1); event.accepted = true }
                else if (event.key === Qt.Key_PageUp) { root.currentPage = Math.max(root.currentPage - 1, 0); event.accepted = true }
                else if (event.key === Qt.Key_Tab) { root.currentPage = (root.currentPage + 1) % root.pages.length; event.accepted = true }
                else if (event.key === Qt.Key_Backtab) { root.currentPage = (root.currentPage - 1 + root.pages.length) % root.pages.length; event.accepted = true }
            }
        }

        Item { // Titlebar
            Layout.fillWidth: true
            Layout.fillHeight: false
            implicitHeight: Math.max(titleText.implicitHeight, searchAndControlsRow.implicitHeight) + 4

            GText {
                id: titleText
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 14
                }
                text: Translation.tr("Settings") + (root.currentPage > 0 ? ` — ${root.pages[root.currentPage].name}` : "")
                font {
                    family: Appearance.font.family.title
                    pixelSize: Appearance.font.pixelSize.title
                    variableAxes: Appearance.font.variableAxes.title
                }
            }

            RowLayout {
                id: searchAndControlsRow
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                spacing: 8

                GTextField {
                    id: searchField
                    implicitWidth: 320
                    implicitHeight: 40
                    placeholderText: Translation.tr("Search settings")
                    onTextChanged: root.updateSearchResults()
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) { searchField.text = ""; searchField.focus = false; event.accepted = true }
                        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (searchResultsModel.count > 0) root.navigateToSearchResult(searchResultsModel.get(0).page, searchResultsModel.get(0).sectionTitle)
                            event.accepted = true
                        }
                    }
                }

                GIconButton {
                    buttonRadius: Appearance.rounding.full
                    implicitWidth: 36
                    implicitHeight: 36
                    buttonIcon: "close"
                    onClicked: root.close()
                    GTooltip { text: Translation.tr("Close settings") }
                }
            }
        }

        RowLayout { // Nav rail + content
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: root.contentPadding

            GNavRail {
                id: navRail
                Layout.fillHeight: true
                expanded: root.width > 940

                GNavExpandButton { focus: root.visible }

                GButton {
                    id: fab
                    property bool justCopied: false
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    Layout.bottomMargin: 6
                    primary: true
                    buttonRadius: Appearance.rounding.full
                    implicitHeight: 44
                    buttonIcon: justCopied ? "check" : "edit"
                    buttonText: justCopied ? Translation.tr("Path copied") : Translation.tr("Config file")
                    horizontalPadding: navRail.expanded ? 14 : 0
                    mainContentComponent: Component {
                        GText {
                            visible: navRail.expanded && text.length > 0
                            text: fab.justCopied ? Translation.tr("Path copied") : Translation.tr("Config file")
                            color: fab.contentColor
                        }
                    }
                    downAction: () => { Qt.openUrlExternally(`${Directories.config}/illogical-impulse/config.json`) }
                    altAction: () => {
                        Quickshell.clipboardText = CF.FileUtils.trimFileProtocol(`${Directories.config}/illogical-impulse/config.json`)
                        fab.justCopied = true
                        revertTextTimer.restart()
                    }
                    Timer { id: revertTextTimer; interval: 1500; onTriggered: fab.justCopied = false }
                    GTooltip { text: Translation.tr("Open the shell config file\nAlternatively right-click to copy path") }
                }

                Repeater {
                    model: root.pages
                    GNavItem {
                        required property var index
                        required property var modelData
                        toggled: root.currentPage === index
                        onClicked: root.currentPage = index
                        expanded: navRail.expanded
                        buttonIcon: modelData.icon
                        buttonIconRotation: modelData.iconRotation || 0
                        buttonText: modelData.name
                    }
                }

                GSectionNavList {
                    sectionTitles: pageLoader.item ? pageLoader.item.sectionTitles : []
                    currentIndex: pageLoader.item ? pageLoader.item.currentSection : -1
                    selected: navRail.expanded
                    onSectionClicked: index => pageLoader.item?.scrollToSection(index)
                }

                Item { Layout.fillHeight: true }
            }

            GlassPane { // Content container
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Appearance.rounding.windowRounding - root.contentPadding
                fillOpacity: 0.8
                shadowBlur: 26
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 0

                    Loader {
                        id: pageLoader
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        opacity: 1.0
                        asynchronous: true

                        active: Config.ready
                        Component.onCompleted: source = root.pages[0].component
                        onLoaded: {
                            if (root.pendingScrollTitle.length > 0) {
                                pageLoader.item.scrollToTitle(root.pendingScrollTitle)
                                root.pendingScrollTitle = ""
                            }
                        }

                        Connections {
                            target: root
                            function onCurrentPageChanged() {
                                switchAnim.complete()
                                switchAnim.start()
                            }
                        }

                        SequentialAnimation {
                            id: switchAnim
                            NumberAnimation {
                                target: pageLoader
                                properties: "opacity"
                                from: 1; to: 0
                                duration: 70
                                easing.type: Appearance.animation.elementMoveExit.type
                                easing.bezierCurve: Appearance.animationCurves.emphasizedFirstHalf
                            }
                            ParallelAnimation {
                                PropertyAction { target: pageLoader; property: "source"; value: root.pages[root.currentPage].component }
                            }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: pageLoader
                                    properties: "opacity"
                                    from: 0; to: 1
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
                        implicitHeight: 34
                        spacing: 8

                        GIcon { Layout.leftMargin: 10; text: "cloud_done"; size: 16; color: Appearance.colors.colPrimary }
                        GText {
                            Layout.fillWidth: true
                            text: Translation.tr("Changes are saved automatically")
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.colOnLayer2
                            elide: Text.ElideRight
                        }
                        GText {
                            visible: Config.lastSavedTime.length > 0
                            text: Translation.tr("Saved") + " " + Config.lastSavedTime
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.colOnLayer2
                        }
                        GIconButton {
                            id: copyConfigBtn
                            property bool justCopied: false
                            implicitWidth: 32; implicitHeight: 30
                            buttonIcon: justCopied ? "check" : "content_copy"
                            onClicked: {
                                Quickshell.clipboardText = Config.toJsonString()
                                copyConfigBtn.justCopied = true
                                copyRevertTimer.restart()
                            }
                            GTooltip { text: copyConfigBtn.justCopied ? Translation.tr("Config copied") : Translation.tr("Copy the full config to clipboard") }
                            Timer { id: copyRevertTimer; interval: 1500; onTriggered: copyConfigBtn.justCopied = false }
                        }
                        GIconButton {
                            id: resetPageBtn
                            property bool armed: false
                            implicitWidth: 32; implicitHeight: 30
                            buttonIcon: armed ? "warning" : "restore"
                            onClicked: {
                                if (resetPageBtn.armed) {
                                    Config.resetToDefaults(pageLoader.item?.resetPaths ?? [])
                                    resetPageBtn.armed = false
                                } else {
                                    resetPageBtn.armed = true
                                    resetArmTimer.restart()
                                }
                            }
                            GTooltip { text: resetPageBtn.armed ? Translation.tr("Click again to reset this page to defaults") : Translation.tr("Reset this page to defaults") }
                            Timer { id: resetArmTimer; interval: 2500; onTriggered: resetPageBtn.armed = false }
                        }
                        GIconButton {
                            implicitWidth: 32; implicitHeight: 30
                            buttonIcon: "refresh"
                            onClicked: Config.reloadFromDisk()
                            GTooltip { text: Translation.tr("Reload the config from disk\n(undoes changes written outside the app)") }
                        }
                        GIconButton {
                            implicitWidth: 32; implicitHeight: 30
                            Layout.rightMargin: 6
                            buttonIcon: "open_in_new"
                            onClicked: Qt.openUrlExternally(`${Directories.config}/illogical-impulse/config.json`)
                            GTooltip { text: Translation.tr("Open the config file in your editor") }
                        }
                    }
                }

                GlassPane { // Search results dropdown
                    id: searchDropdown
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                        topMargin: 12
                    }
                    width: Math.min(600, parent.width - 40)
                    height: Math.min(searchResultsList.implicitHeight, 420)
                    radius: Appearance.rounding.normal
                    fillOpacity: 0.85
                    shadowBlur: 22
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
                                anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                                spacing: 10

                                GIcon { text: root.pages[model.page].icon; size: 20; color: Appearance.colors.colOnLayer1 }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    GText { text: model.sectionTitle; font.pixelSize: Appearance.font.pixelSize.normal; font.weight: Font.Medium; color: Appearance.colors.colOnLayer1 }
                                    GText { text: root.pages[model.page].name; font.pixelSize: Appearance.font.pixelSize.small; color: Appearance.colors.colOnLayer2 }
                                }
                                GIcon { text: "arrow_forward"; size: 16; color: Appearance.colors.colPrimary }
                            }

                            background: Rectangle {
                                radius: Appearance.rounding.normal
                                color: resultDelegate.hovered ? CF.ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.14) : "transparent"
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
