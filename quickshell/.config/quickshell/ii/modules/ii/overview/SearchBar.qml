pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

RowLayout {
    id: root
    spacing: 8
    property bool animateWidth: false
    property alias searchInput: searchInput
    property string searchingText

    function forceFocus() {
        searchInput.forceActiveFocus();
    }

    function activatePrefix(prefix) {
        searchInput.forceActiveFocus();
        if (root.searchingText.startsWith(prefix)) {
            searchInput.selectAll();
            return;
        }
        searchInput.text = prefix;
        searchInput.cursorPosition = searchInput.text.length;
        LauncherSearch.query = searchInput.text;
    }

    enum SearchPrefixType { Action, App, Clipboard, Emojis, Math, ShellCommand, WebSearch, Windows, Weather, File, DefaultSearch }

    property var searchPrefixType: {
        if (root.searchingText.startsWith(Config.options.search.prefix.action)) return SearchBar.SearchPrefixType.Action;
        if (root.searchingText.startsWith(Config.options.search.prefix.app)) return SearchBar.SearchPrefixType.App;
        if (root.searchingText.startsWith(Config.options.search.prefix.clipboard)) return SearchBar.SearchPrefixType.Clipboard;
        if (root.searchingText.startsWith(Config.options.search.prefix.emojis)) return SearchBar.SearchPrefixType.Emojis;
        if (root.searchingText.startsWith(Config.options.search.prefix.math)) return SearchBar.SearchPrefixType.Math;
        if (root.searchingText.startsWith(Config.options.search.prefix.shellCommand)) return SearchBar.SearchPrefixType.ShellCommand;
        if (root.searchingText.startsWith(Config.options.search.prefix.webSearch)) return SearchBar.SearchPrefixType.WebSearch;
        if (root.searchingText.startsWith(Config.options.search.prefix.windows)) return SearchBar.SearchPrefixType.Windows;
        if (root.searchingText.startsWith(Config.options.search.prefix.weather)) return SearchBar.SearchPrefixType.Weather;
        if (root.searchingText.startsWith(Config.options.search.prefix.file)) return SearchBar.SearchPrefixType.File;
        return SearchBar.SearchPrefixType.DefaultSearch;
    }
    
    MaterialShapeWrappedMaterialSymbol {
        id: searchIcon
        Layout.alignment: Qt.AlignVCenter
        iconSize: Appearance.font.pixelSize.huge
        color: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.42)
        colSymbol: Appearance.colors.colOnSecondaryContainer
        shape: switch(root.searchPrefixType) {
            case SearchBar.SearchPrefixType.Action: return MaterialShape.Shape.Pill;
            case SearchBar.SearchPrefixType.App: return MaterialShape.Shape.Clover4Leaf;
            case SearchBar.SearchPrefixType.Clipboard: return MaterialShape.Shape.Gem;
            case SearchBar.SearchPrefixType.Emojis: return MaterialShape.Shape.Sunny;
            case SearchBar.SearchPrefixType.Math: return MaterialShape.Shape.PuffyDiamond;
            case SearchBar.SearchPrefixType.ShellCommand: return MaterialShape.Shape.PixelCircle;
            case SearchBar.SearchPrefixType.WebSearch: return MaterialShape.Shape.SoftBurst;
            case SearchBar.SearchPrefixType.Windows: return MaterialShape.Shape.Pentagon;
            case SearchBar.SearchPrefixType.Weather: return MaterialShape.Shape.Sunny;
            case SearchBar.SearchPrefixType.File: return MaterialShape.Shape.PixelTriangle;
            default: return MaterialShape.Shape.Cookie7Sided;
        }
        text: switch (root.searchPrefixType) {
            case SearchBar.SearchPrefixType.Action: return "settings_suggest";
            case SearchBar.SearchPrefixType.App: return "apps";
            case SearchBar.SearchPrefixType.Clipboard: return "content_paste_search";
            case SearchBar.SearchPrefixType.Emojis: return "add_reaction";
            case SearchBar.SearchPrefixType.Math: return "calculate";
            case SearchBar.SearchPrefixType.ShellCommand: return "terminal";
            case SearchBar.SearchPrefixType.WebSearch: return "travel_explore";
            case SearchBar.SearchPrefixType.Windows: return "window";
            case SearchBar.SearchPrefixType.Weather: return "partly_cloudy_day";
            case SearchBar.SearchPrefixType.File: return "description";
            case SearchBar.SearchPrefixType.DefaultSearch: return "search";
            default: return "search";
        }
    }
    ToolbarTextField { // Search box
        id: searchInput
        Layout.topMargin: 4
        Layout.bottomMargin: 4
        implicitHeight: 40
        focus: GlobalStates.overviewOpen
        font.pixelSize: Appearance.font.pixelSize.small
        placeholderText: Translation.tr("Search, calculate or run")
        implicitWidth: root.searchingText == "" ? Math.max(Appearance.sizes.searchWidthCollapsed, 280) : Math.max(Appearance.sizes.searchWidth, 430)
        color: Appearance.colors.colOnLayer2
        placeholderTextColor: ColorUtils.applyAlpha(Appearance.colors.colOnLayer2, 0.62)
        colBackground: ColorUtils.applyAlpha(Appearance.colors.colLayer1Base, 0.46)

        Behavior on implicitWidth {
            id: searchWidthBehavior
            enabled: root.animateWidth
            NumberAnimation {
                duration: 300
                easing.type: Appearance.animation.elementMove.type
                easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
            }
        }

        onTextChanged: LauncherSearch.query = text

        onAccepted: {
            if (appResults.count > 0) {
                // Get the first visible delegate and trigger its click
                let firstItem = appResults.itemAtIndex(0);
                if (firstItem && firstItem.clicked) {
                    firstItem.clicked();
                }
            }
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Tab) {
                if (LauncherSearch.results.length === 0) return;
                const tabbedText = LauncherSearch.results[0].name;
                LauncherSearch.query = tabbedText;
                searchInput.text = tabbedText;
                event.accepted = true;
            }
        }
    }

    IconToolbarButton {
        Layout.topMargin: 4
        Layout.bottomMargin: 4
        Layout.leftMargin: 2
        toggled: root.searchingText.startsWith(Config.options.search.prefix.clipboard)
        colText: toggled ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnLayer2
        onClicked: root.activatePrefix(Config.options.search.prefix.clipboard)
        text: "content_paste_search"
        StyledToolTip {
            text: Translation.tr("Clipboard")
        }
    }

    IconToolbarButton {
        Layout.topMargin: 4
        Layout.bottomMargin: 4
        toggled: root.searchingText.startsWith(Config.options.search.prefix.emojis)
        colText: toggled ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnLayer2
        onClicked: root.activatePrefix(Config.options.search.prefix.emojis)
        text: "add_reaction"
        StyledToolTip {
            text: Translation.tr("Emojis")
        }
    }

    IconToolbarButton {
        Layout.topMargin: 4
        Layout.bottomMargin: 4
        toggled: root.searchingText.startsWith(Config.options.search.prefix.windows)
        colText: toggled ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnLayer2
        onClicked: root.activatePrefix(Config.options.search.prefix.windows)
        text: "window"
        StyledToolTip {
            text: Translation.tr("Windows")
        }
    }

    IconToolbarButton {
        Layout.topMargin: 4
        Layout.bottomMargin: 4
        toggled: root.searchingText.startsWith(Config.options.search.prefix.file)
        colText: toggled ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnLayer2
        onClicked: root.activatePrefix(Config.options.search.prefix.file)
        text: "description"
        StyledToolTip {
            text: Translation.tr("Files")
        }
    }

    IconToolbarButton {
        Layout.topMargin: 4
        Layout.bottomMargin: 4
        colText: Appearance.colors.colOnLayer2
        onClicked: {
            GlobalStates.overviewOpen = false;
            Quickshell.execDetached(["qs", "-p", Quickshell.shellPath(""), "ipc", "call", "region", "search"]);
        }
        text: "image_search"
        StyledToolTip {
            text: Translation.tr("Google Lens")
        }
    }

    IconToolbarButton {
        id: songRecButton
        Layout.topMargin: 4
        Layout.bottomMargin: 4
        Layout.rightMargin: 8
        toggled: SongRec.running
        colText: toggled ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer2
        onClicked: SongRec.toggleRunning()
        text: "music_cast"

        StyledToolTip {
            text: Translation.tr("Recognize music")
        }

        background: MaterialShape {
            RotationAnimation on rotation {
                running: songRecButton.toggled
                duration: 12000
                easing.type: Easing.Linear
                loops: Animation.Infinite
                from: 0
                to: 360
            }
            shape: {
                if (songRecButton.down) {
                    return songRecButton.toggled ? MaterialShape.Shape.Circle : MaterialShape.Shape.Square
                } else {
                    return songRecButton.toggled ? MaterialShape.Shape.SoftBurst : MaterialShape.Shape.Circle
                }
            }
            color: {
                if (songRecButton.toggled) {
                    return songRecButton.hovered ? Appearance.colors.colPrimaryHover : Appearance.colors.colPrimary
                } else {
                    return songRecButton.hovered ? Appearance.colors.colSurfaceContainerHigh : ColorUtils.transparentize(Appearance.colors.colSurfaceContainerHigh)
                }
            }
            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
        }
    }
}
