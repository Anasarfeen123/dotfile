import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.modules.common
import qs.modules.settingsPro.widgets
import qs.modules.common.widgets as CW

GPage {
    forceWidth: true

    GSection {
        icon: "box"
        title: Translation.tr("Distro")

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            IconImage {
                implicitSize: 80
                source: Quickshell.iconPath(SystemInfo.logo)
            }
            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                GText { text: SystemInfo.distroName; font.pixelSize: Appearance.font.pixelSize.title }
                GText {
                    font.pixelSize: Appearance.font.pixelSize.normal
                    text: SystemInfo.homeUrl
                    textFormat: Text.MarkdownText
                    onLinkActivated: link => Qt.openUrlExternally(link)
                    CW.PointingHandLinkHover {}
                }
            }
        }

        Flow {
            Layout.fillWidth: true
            spacing: 6

            GButton { buttonIcon: "auto_stories"; buttonText: Translation.tr("Documentation"); onClicked: Qt.openUrlExternally(SystemInfo.documentationUrl) }
            GButton { buttonIcon: "support"; buttonText: Translation.tr("Help & Support"); onClicked: Qt.openUrlExternally(SystemInfo.supportUrl) }
            GButton { buttonIcon: "bug_report"; buttonText: Translation.tr("Report a Bug"); onClicked: Qt.openUrlExternally(SystemInfo.bugReportUrl) }
            GButton { buttonIcon: "policy"; materialIconFill: false; buttonText: Translation.tr("Privacy Policy"); onClicked: Qt.openUrlExternally(SystemInfo.privacyPolicyUrl) }
        }
    }

    GSection {
        icon: "folder_managed"
        title: Translation.tr("Dotfiles")

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            IconImage {
                implicitSize: 80
                source: Quickshell.iconPath("illogical-impulse")
            }
            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                GText { text: Translation.tr("illogical-impulse"); font.pixelSize: Appearance.font.pixelSize.title }
                GText {
                    text: "https://github.com/end-4/dots-hyprland"
                    font.pixelSize: Appearance.font.pixelSize.normal
                    textFormat: Text.MarkdownText
                    onLinkActivated: link => Qt.openUrlExternally(link)
                    CW.PointingHandLinkHover {}
                }
            }
        }

        Flow {
            Layout.fillWidth: true
            spacing: 6

            GButton { buttonIcon: "auto_stories"; buttonText: Translation.tr("Documentation"); onClicked: Qt.openUrlExternally("https://end-4.github.io/dots-hyprland-wiki/en/ii-qs/02usage/") }
            GButton { buttonIcon: "adjust"; materialIconFill: false; buttonText: Translation.tr("Issues"); onClicked: Qt.openUrlExternally("https://github.com/end-4/dots-hyprland/issues") }
            GButton { buttonIcon: "forum"; buttonText: Translation.tr("Discussions"); onClicked: Qt.openUrlExternally("https://github.com/end-4/dots-hyprland/discussions") }
            GButton { buttonIcon: "favorite"; buttonText: Translation.tr("Donate"); primary: true; onClicked: Qt.openUrlExternally("https://github.com/sponsors/end-4") }
        }
    }

    GSection {
        icon: "info"
        title: Translation.tr("ii Settings — Pro")
        GText {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: Translation.tr("A from-scratch, glass-styled reskin of illogical-impulse's settings app, wired to the same live config so every change here applies to your running shell.")
            color: Appearance.colors.colOnLayer2
        }
    }
}
