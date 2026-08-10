import QtQuick
import Quickshell

QtObject {
    enum IconType { Material, Text, System, None }
    enum FontType { Normal, Monospace }

    // General stuff
    property string type: ""
    property var fontType: LauncherSearchResult.FontType.Normal
    property string name: ""
    property string rawValue: ""
    property string iconName: ""
    property var iconType: LauncherSearchResult.IconType.None
    property string verb: ""
    property bool blurImage: false
    property var execute: () => {
        print("Not implemented");
    }
    property var actions: []
    
    // Stuff needed for DesktopEntry 
    property string id: ""
    property bool shown: true
    property string comment: ""
    property bool runInTerminal: false
    property string genericName: ""
    property list<string> keywords: []

    // Extra stuff to allow for more flexibility
    property string category: type

    // SearchWidget's results ScriptModel diffs entries by this (objectProp:
    // "key") to animate additions/removals/reordering smoothly instead of
    // remounting the whole list. This property didn't exist before, so
    // every entry's "key" was just undefined -- indistinguishable from
    // every other entry's -- which meant the model couldn't tell an
    // unchanged result from a new one on the next debounced update and
    // just tore down and recreated everything each keystroke, replaying
    // every add-in animation at once. Deterministic per-content instead,
    // so the same result gets the same key across updates.
    readonly property string key: `${type}:${name}:${rawValue}`
}
