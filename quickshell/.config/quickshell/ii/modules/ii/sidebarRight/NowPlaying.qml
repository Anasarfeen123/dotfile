import qs
import qs.services
import qs.modules.common
import qs.modules.common.models
import qs.modules.common.widgets
import qs.modules.common.functions
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

StyledGlassSurface {
    id: root
    fillOpacity: 0.38

    readonly property MprisPlayer player: MprisController.activePlayer
    readonly property bool hasPlayer: player !== null

    property string artUrl: root.player?.trackArtUrl ?? ""
    property string artDownloadLocation: Directories.coverArt
    property string artFileName: Qt.md5(artUrl)
    property string artFilePath: `${artDownloadLocation}/${artFileName}`
    property string displayedArtFilePath: root.downloaded ? Qt.resolvedUrl(artFilePath) : ""
    property bool downloaded: false
    property color artDominantColor: ColorUtils.mix((colorQuantizer?.colors[0] ?? Appearance.colors.colPrimary), Appearance.colors.colPrimaryContainer, 0.8) || Appearance.m3colors.m3secondaryContainer

    visible: hasPlayer
    implicitHeight: 76

    onArtFilePathChanged: root.updateArt()

    Component.onCompleted: root.updateArt()

    function updateArt() {
        if (root.artUrl.length == 0) {
            root.artDominantColor = Appearance.m3colors.m3secondaryContainer
            return;
        }

        coverArtDownloader.targetFile = root.artUrl
        coverArtDownloader.artFilePath = root.artFilePath
        root.downloaded = false
        coverArtDownloader.running = true
    }

    Process { // Cover art downloader
        id: coverArtDownloader
        property string targetFile: root.artUrl
        property string artFilePath: root.artFilePath
        command: [ "bash", "-c", `mkdir -p '${artDownloadLocation}' && ([ -f '${artFilePath}' ] || curl -4 -sSL '${targetFile}' -o '${artFilePath}')` ]
        onExited: (exitCode, exitStatus) => {
            root.downloaded = true
        }
    }

    ColorQuantizer {
        id: colorQuantizer
        source: root.displayedArtFilePath
        depth: 0 // 2^0 = 1 color
        rescaleSize: 1
    }

    property QtObject blendedColors: AdaptedMaterialScheme {
        color: root.artDominantColor
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        Rectangle { // Art
            Layout.preferredWidth: 52
            Layout.preferredHeight: 52
            radius: Appearance.rounding.small
            color: ColorUtils.applyAlpha(blendedColors.colLayer1, 0.5)
            clip: true

            Loader {
                anchors.fill: parent
                active: root.player?.trackArtUrl?.length > 0
                sourceComponent: Item {
                    Rectangle {
                        anchors.fill: parent
                        color: blendedColors.colLayer1
                    }
                    StyledImage {
                        anchors.fill: parent
                        source: root.displayedArtFilePath
                        fillMode: Image.PreserveAspectCrop
                        clip: true
                    }
                }
            }
            MaterialSymbol {
                anchors.centerIn: parent
                visible: !(root.player?.trackArtUrl?.length > 0)
                text: "music_note"
                iconSize: 22
                color: blendedColors.colSubtext
            }
        }

        ColumnLayout { // Title + artist
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            MarqueeText {
                Layout.fillWidth: true
                text: root.player?.trackTitle ?? Translation.tr("Nothing playing")
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
                color: blendedColors.colOnLayer1
            }
            StyledText {
                Layout.fillWidth: true
                text: root.player?.trackArtist ?? ""
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: blendedColors.colSubtext
                elide: Text.ElideRight
            }
        }

        Row { // Controls
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            ToolButton {
                visible: MprisController.canGoPrevious
                implicitWidth: 30
                implicitHeight: 30
                background: Rectangle {
                    radius: Appearance.rounding.full
                    color: ColorUtils.applyAlpha(blendedColors.colLayer1, parent.pressed ? 0.6 : 0.3)
                }
                contentItem: MaterialSymbol {
                    text: "skip_previous"
                    iconSize: 17
                    color: blendedColors.colOnLayer1
                }
                onClicked: MprisController.previous()
            }
            ToolButton {
                visible: MprisController.canTogglePlaying
                implicitWidth: 34
                implicitHeight: 34
                background: Rectangle {
                    radius: Appearance.rounding.full
                    color: blendedColors.colPrimary
                }
                contentItem: MaterialSymbol {
                    text: MprisController.isPlaying ? "pause" : "play_arrow"
                    iconSize: 19
                    color: blendedColors.colOnPrimary
                }
                onClicked: MprisController.togglePlaying()
            }
            ToolButton {
                visible: MprisController.canGoNext
                implicitWidth: 30
                implicitHeight: 30
                background: Rectangle {
                    radius: Appearance.rounding.full
                    color: ColorUtils.applyAlpha(blendedColors.colLayer1, parent.pressed ? 0.6 : 0.3)
                }
                contentItem: MaterialSymbol {
                    text: "skip_next"
                    iconSize: 17
                    color: blendedColors.colOnLayer1
                }
                onClicked: MprisController.next()
            }
        }
    }
}
