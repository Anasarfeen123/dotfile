import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Qt.labs.synchronizer

Item {
    id: root
    required property var scopeRoot
    property int sidebarPadding: 10
    anchors.fill: parent
    property bool aiChatEnabled: Config.options.policies.ai !== 0
    property bool translatorEnabled: Config.options.sidebar.translator.enable
    property bool animeEnabled: Config.options.policies.weeb !== 0
    property bool animeCloset: Config.options.policies.weeb === 2
    property var tabButtonList: [
        ...(root.aiChatEnabled ? [{"icon": "neurology", "name": Translation.tr("Intelligence")}] : []),
        ...(root.translatorEnabled ? [{"icon": "translate", "name": Translation.tr("Translator")}] : []),
        ...((root.animeEnabled && !root.animeCloset) ? [{"icon": "bookmark_heart", "name": Translation.tr("Anime")}] : [])
    ]
    property int tabCount: swipeView.count

    opacity: 0
    transform: Translate {
        id: rootTranslate
        x: -24
        Behavior on x {
            animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
        }
    }
    scale: 0.98
    Behavior on opacity {
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
    Behavior on scale {
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }

    Connections {
        target: root.scopeRoot
        function onDetachChanged() {
            root.opacity = 1;
            rootTranslate.x = 0;
            root.scale = 1;
        }
    }

    Connections {
        target: GlobalStates
        function onSidebarLeftOpenChanged() {
            if (GlobalStates.sidebarLeftOpen) {
                root.opacity = 1;
                rootTranslate.x = 0;
                root.scale = 1;
            } else {
                root.opacity = 0;
                rootTranslate.x = -24;
                root.scale = 0.98;
            }
        }
    }

    Component.onCompleted: {
        if (GlobalStates.sidebarLeftOpen) {
            root.opacity = 1;
            rootTranslate.x = 0;
            root.scale = 1;
        }
    }

    function focusActiveItem() {
        swipeView.currentItem.forceActiveFocus()
    }

    Keys.onPressed: (event) => {
        if (event.modifiers === Qt.ControlModifier) {
            if (event.key === Qt.Key_PageDown) {
                swipeView.incrementCurrentIndex()
                event.accepted = true;
            }
            else if (event.key === Qt.Key_PageUp) {
                swipeView.decrementCurrentIndex()
                event.accepted = true;
            }
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: sidebarPadding
        }
        spacing: sidebarPadding

        Toolbar {
            visible: tabButtonList.length > 0
            Layout.alignment: Qt.AlignHCenter
            enableShadow: false
            glass: true
            ToolbarTabBar {
                id: tabBar
                Layout.alignment: Qt.AlignHCenter
                tabButtonList: root.tabButtonList
                currentIndex: swipeView.currentIndex
            }
        }

        QuickLaunch {
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitWidth: swipeView.implicitWidth
            implicitHeight: swipeView.implicitHeight
            radius: Appearance.rounding.normal
            color: ColorUtils.applyAlpha(Appearance.colors.colLayer1Base, 0.38)
            border.width: 1
            border.color: Appearance.colors.colLayer0Border
            clip: true

            SwipeView { // Content pages
                id: swipeView
                anchors.fill: parent
                spacing: 10
                currentIndex: tabBar.currentIndex

                clip: true
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: swipeView.width
                        height: swipeView.height
                        radius: Appearance.rounding.small
                    }
                }

                contentChildren: [
                    ...(root.aiChatEnabled ? [aiChat.createObject()] : []),
                    ...(root.translatorEnabled ? [translator.createObject()] : []),
                    ...((root.tabButtonList.length === 0 || (!root.aiChatEnabled && !root.translatorEnabled && root.animeCloset)) ? [placeholder.createObject()] : []),
                    ...(root.animeEnabled ? [anime.createObject()] : []),
                ]
            }
        }

        DockGroup {
            Layout.fillWidth: true
        }

        SessionButton {
            Layout.fillWidth: true
        }

    component SessionButton: StyledGlassSurface {
        fillOpacity: 0.38
        implicitHeight: 38

        RippleButton {
            anchors.fill: parent
            buttonRadius: Appearance.rounding.small
            colBackground: "transparent"
            colBackgroundHover: ColorUtils.applyAlpha(Appearance.colors.colLayer1Hover, 0.6)
            onClicked: GlobalStates.sessionOpen = true
            StyledToolTip {
                text: Translation.tr("Session / Logout")
            }

            MaterialSymbol {
                anchors.centerIn: parent
                text: "power_settings_new"
                iconSize: 18
                color: Appearance.colors.colOnLayer1
            }
        }
    }

    Component {
        id: aiChat
            AiChat {}
        }
        Component {
            id: translator
            Translator {}
        }
        Component {
            id: anime
            Anime {}
        }
        Component {
            id: placeholder
            Item {
                StyledText {
                    anchors.centerIn: parent
                    text: root.animeCloset ? Translation.tr("Nothing") : Translation.tr("Enjoy your empty sidebar...")
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}