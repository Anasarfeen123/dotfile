import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.settingsPro.widgets

GPage {
    forceWidth: true
    resetPaths: ["ai.systemPrompt", "bar.weather", "musicRecognition", "networking.userAgent", "resources.updateInterval", "screenRecord.savePath", "screenSnip.savePath", "search", "updates"]

    GSection {
        icon: "neurology"
        title: Translation.tr("AI")
        GTextArea {
            Layout.fillWidth: true
            placeholderText: Translation.tr("System prompt")
            text: Config.options.ai.systemPrompt
            wrapMode: TextEdit.Wrap
            onTextChanged: Qt.callLater(() => { Config.options.ai.systemPrompt = text })
        }
    }

    GSection {
        icon: "music_cast"
        title: Translation.tr("Music Recognition")
        GSpinRow {
            icon: "timer_off"
            text: Translation.tr("Total duration timeout (s)")
            value: Config.options.musicRecognition.timeout
            from: 10; to: 100; stepSize: 2
            onValueChanged: Config.options.musicRecognition.timeout = value
        }
        GSpinRow {
            icon: "av_timer"
            text: Translation.tr("Polling interval (s)")
            value: Config.options.musicRecognition.interval
            from: 2; to: 10; stepSize: 1
            onValueChanged: Config.options.musicRecognition.interval = value
        }
    }

    GSection {
        icon: "cell_tower"
        title: Translation.tr("Networking")
        GTextArea {
            Layout.fillWidth: true
            placeholderText: Translation.tr("User agent (for services that require it)")
            text: Config.options.networking.userAgent
            wrapMode: TextEdit.Wrap
            onTextChanged: Config.options.networking.userAgent = text
        }
    }

    GSection {
        icon: "memory"
        title: Translation.tr("Resources")
        GSpinRow {
            icon: "av_timer"
            text: Translation.tr("Polling interval (ms)")
            value: Config.options.resources.updateInterval
            from: 100; to: 10000; stepSize: 100
            onValueChanged: Config.options.resources.updateInterval = value
        }
    }

    GSection {
        icon: "file_open"
        title: Translation.tr("Save paths")
        GTextArea {
            Layout.fillWidth: true
            placeholderText: Translation.tr("Video Recording Path")
            text: Config.options.screenRecord.savePath
            wrapMode: TextEdit.Wrap
            onTextChanged: Config.options.screenRecord.savePath = text
        }
        GTextArea {
            Layout.fillWidth: true
            placeholderText: Translation.tr("Screenshot Path (leave empty to just copy)")
            text: Config.options.screenSnip.savePath
            wrapMode: TextEdit.Wrap
            onTextChanged: Config.options.screenSnip.savePath = text
        }
    }

    GSection {
        icon: "search"
        title: Translation.tr("Search")

        GSwitchRow {
            buttonText: Translation.tr("Use Levenshtein distance-based algorithm instead of fuzzy")
            checked: Config.options.search.sloppy
            onCheckedChanged: Config.options.search.sloppy = checked
            GTooltip { text: Translation.tr("Could be better if you make a ton of typos,\nbut results can be weird and might not work with acronyms\n(e.g. \"GIMP\" might not give you the paint program)") }
        }

        GSubsection {
            title: Translation.tr("Prefixes")
            GRow {
                uniform: true
                GTextArea { Layout.fillWidth: true; placeholderText: Translation.tr("Action"); text: Config.options.search.prefix.action; wrapMode: TextEdit.Wrap; onTextChanged: Config.options.search.prefix.action = text }
                GTextArea { Layout.fillWidth: true; placeholderText: Translation.tr("Clipboard"); text: Config.options.search.prefix.clipboard; wrapMode: TextEdit.Wrap; onTextChanged: Config.options.search.prefix.clipboard = text }
                GTextArea { Layout.fillWidth: true; placeholderText: Translation.tr("Emojis"); text: Config.options.search.prefix.emojis; wrapMode: TextEdit.Wrap; onTextChanged: Config.options.search.prefix.emojis = text }
            }
            GRow {
                uniform: true
                GTextArea { Layout.fillWidth: true; placeholderText: Translation.tr("Math"); text: Config.options.search.prefix.math; wrapMode: TextEdit.Wrap; onTextChanged: Config.options.search.prefix.math = text }
                GTextArea { Layout.fillWidth: true; placeholderText: Translation.tr("Shell command"); text: Config.options.search.prefix.shellCommand; wrapMode: TextEdit.Wrap; onTextChanged: Config.options.search.prefix.shellCommand = text }
                GTextArea { Layout.fillWidth: true; placeholderText: Translation.tr("Web search"); text: Config.options.search.prefix.webSearch; wrapMode: TextEdit.Wrap; onTextChanged: Config.options.search.prefix.webSearch = text }
            }
            GRow {
                uniform: true
                GTextArea { Layout.fillWidth: true; placeholderText: Translation.tr("Windows"); text: Config.options.search.prefix.windows; wrapMode: TextEdit.Wrap; onTextChanged: Config.options.search.prefix.windows = text }
                GTextArea { Layout.fillWidth: true; placeholderText: Translation.tr("Weather"); text: Config.options.search.prefix.weather; wrapMode: TextEdit.Wrap; onTextChanged: Config.options.search.prefix.weather = text }
                GTextArea { Layout.fillWidth: true; placeholderText: Translation.tr("File"); text: Config.options.search.prefix.file; wrapMode: TextEdit.Wrap; onTextChanged: Config.options.search.prefix.file = text }
            }
        }
        GSubsection {
            title: Translation.tr("Web search")
            GTextArea {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Base URL")
                text: Config.options.search.engineBaseUrl
                wrapMode: TextEdit.Wrap
                onTextChanged: Config.options.search.engineBaseUrl = text
            }
        }
    }

    GSection {
        icon: "weather_mix"
        title: Translation.tr("Weather")
        GRow {
            GSwitchRow {
                buttonIcon: "assistant_navigation"
                buttonText: Translation.tr("Enable GPS based location")
                checked: Config.options.bar.weather.enableGPS
                onCheckedChanged: Config.options.bar.weather.enableGPS = checked
            }
            GSwitchRow {
                buttonIcon: "thermometer"
                buttonText: Translation.tr("Fahrenheit unit")
                checked: Config.options.bar.weather.useUSCS
                onCheckedChanged: Config.options.bar.weather.useUSCS = checked
                GTooltip { text: Translation.tr("It may take a few seconds to update") }
            }
        }
        GTextArea {
            Layout.fillWidth: true
            placeholderText: Translation.tr("City name")
            text: Config.options.bar.weather.city
            wrapMode: TextEdit.Wrap
            onTextChanged: Config.options.bar.weather.city = text
        }
        GSpinRow {
            icon: "av_timer"
            text: Translation.tr("Polling interval (m)")
            value: Config.options.bar.weather.fetchInterval
            from: 5; to: 50; stepSize: 5
            onValueChanged: Config.options.bar.weather.fetchInterval = value
        }
    }
}
