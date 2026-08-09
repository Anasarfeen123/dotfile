import QtQuick
import qs.services
import qs.modules.common
import qs.modules.settingsPro.widgets

GPage {
    forceWidth: true
    resetPaths: ["appearance.wallpaperTheming"]

    GSection {
        icon: "colors"
        title: Translation.tr("Color generation")

        GSwitchRow {
            buttonIcon: "hardware"
            buttonText: Translation.tr("Shell & utilities")
            checked: Config.options.appearance.wallpaperTheming.enableAppsAndShell
            onCheckedChanged: Config.options.appearance.wallpaperTheming.enableAppsAndShell = checked
        }
        GSwitchRow {
            buttonIcon: "tv_options_input_settings"
            buttonText: Translation.tr("Qt apps")
            checked: Config.options.appearance.wallpaperTheming.enableQtApps
            onCheckedChanged: Config.options.appearance.wallpaperTheming.enableQtApps = checked
            GTooltip { text: Translation.tr("Shell & utilities theming must also be enabled") }
        }
        GSwitchRow {
            buttonIcon: "terminal"
            buttonText: Translation.tr("Terminal")
            checked: Config.options.appearance.wallpaperTheming.enableTerminal
            onCheckedChanged: Config.options.appearance.wallpaperTheming.enableTerminal = checked
            GTooltip { text: Translation.tr("Shell & utilities theming must also be enabled") }
        }
        GRow {
            uniform: true
            GSwitchRow {
                buttonIcon: "dark_mode"
                buttonText: Translation.tr("Force dark mode in terminal")
                checked: Config.options.appearance.wallpaperTheming.terminalGenerationProps.forceDarkMode
                onCheckedChanged: Config.options.appearance.wallpaperTheming.terminalGenerationProps.forceDarkMode = checked
                GTooltip { text: Translation.tr("Ignored if terminal theming is not enabled") }
            }
        }
        GSpinRow {
            icon: "invert_colors"
            text: Translation.tr("Terminal: Harmony (%)")
            value: Config.options.appearance.wallpaperTheming.terminalGenerationProps.harmony * 100
            from: 0; to: 100; stepSize: 10
            onValueChanged: Config.options.appearance.wallpaperTheming.terminalGenerationProps.harmony = value / 100
        }
        GSpinRow {
            icon: "gradient"
            text: Translation.tr("Terminal: Harmonize threshold")
            value: Config.options.appearance.wallpaperTheming.terminalGenerationProps.harmonizeThreshold
            from: 0; to: 100; stepSize: 10
            onValueChanged: Config.options.appearance.wallpaperTheming.terminalGenerationProps.harmonizeThreshold = value
        }
        GSpinRow {
            icon: "format_color_text"
            text: Translation.tr("Terminal: Foreground boost (%)")
            value: Config.options.appearance.wallpaperTheming.terminalGenerationProps.termFgBoost * 100
            from: 0; to: 100; stepSize: 10
            onValueChanged: Config.options.appearance.wallpaperTheming.terminalGenerationProps.termFgBoost = value / 100
        }
    }
}
