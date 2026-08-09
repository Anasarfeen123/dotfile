import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

StyledFlickable {
    id: root
    property real baseWidth: 600
    property bool forceWidth: false
    property real bottomContentPadding: 100
    // Config subtrees this page controls (dot paths). Used by the "Reset page" action.
    property var resetPaths: []

    default property alias contentData: contentColumn.data

    // Discovered top-level ContentSections, used for in-page section navigation
    property list<QtObject> sections: []
    property list<string> sectionKeys: []
    property list<string> sectionTitles: []
    property int currentSection: -1
    signal sectionActivated(int index)

    function rebuildSections() {
        const found = []
        for (let i = 0; i < contentColumn.children.length; i++) {
            const child = contentColumn.children[i]
            if (child && child.isSettingsSection) found.push(child)
        }
        sections = found
        const keys = []
        const titles = []
        for (let i = 0; i < found.length; i++) {
            keys.push(found[i].key || `section_${i}`)
            titles.push(found[i].title || Translation.tr("Section") + ` ${i + 1}`)
        }
        sectionKeys = keys
        sectionTitles = titles
    }

    function scrollToSection(index) {
        if (index < 0 || index >= sections.length) return
        const target = sections[index]
        const targetY = target.mapToItem(root.contentItem, 0, 0).y
        contentY = Math.max(0, targetY - 12)
        currentSection = index
        sectionActivated(index)
    }

    function scrollToKey(key) {
        const index = sectionKeys.indexOf(key)
        if (index !== -1) scrollToSection(index)
    }

    function scrollToTitle(title) {
        const index = sectionTitles.indexOf(title)
        if (index !== -1) scrollToSection(index)
    }

    clip: true
    contentHeight: contentColumn.implicitHeight + root.bottomContentPadding // Add some padding at the bottom
    implicitWidth: contentColumn.implicitWidth
    
    ColumnLayout {
        id: contentColumn
        // Responsive: never overflow the viewport (no horizontal clipping at narrow
        // window widths), but cap to the natural/base width on wide windows.
        width: {
            const avail = root.width - 40
            if (root.forceWidth) return Math.max(320, Math.min(root.baseWidth, avail))
            return Math.min(Math.max(root.baseWidth, implicitWidth), Math.max(320, avail))
        }
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            margins: 20
        }
        spacing: 36
    }

    Component.onCompleted: rebuildSections()
    onContentHeightChanged: rebuildSections()
    onContentYChanged: syncCurrentSection()

    function syncCurrentSection() {
        if (sections.length === 0) return
        const viewportY = contentY + 40
        let idx = 0
        for (let i = 0; i < sections.length; i++) {
            const y = sections[i].mapToItem(root.contentItem, 0, 0).y
            if (y <= viewportY) idx = i
        }
        if (idx !== currentSection) {
            currentSection = idx
            sectionActivated(idx)
        }
    }

}
