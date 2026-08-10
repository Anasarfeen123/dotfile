import qs.modules.common
import qs.modules.common.functions
import qs.services
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root
    property bool barOpen: true
    property bool crosshairOpen: false
    property bool sidebarLeftOpen: false
    property bool sidebarRightOpen: false
    property bool mediaControlsOpen: false
    property bool notifCenterOpen: false
    property bool utilityMenuOpen: false
    property bool osdBrightnessOpen: false
    property bool osdVolumeOpen: false
    property bool oskOpen: false
    property bool overlayOpen: false
    property bool overviewOpen: false
    property bool regionSelectorOpen: false
    property bool searchOpen: false
    property bool screenLocked: false
    property bool screenLockContainsCharacters: false
    property bool screenUnlockFailed: false
    property bool screenTranslatorOpen: false
    property bool sessionOpen: false
    property bool superDown: false
    property bool superReleaseMightTrigger: true
    property bool wallpaperSelectorOpen: false
    property bool workspaceShowNumbers: false
    property bool batterySaverEnabled: false
    property bool batterySaverUserDisabled: false
    property var batterySaverBrightness: ({})
    property var batterySaverAnimationDurations: ({})
    readonly property bool batterySaverAutoEligible: Battery.available && !Battery.isPluggedIn && Battery.percentage <= 0.4

    function setBatterySaverAnimations(disabled) {
        const animationNames = ["elementMove", "elementMoveSmall", "elementMoveEnter", "elementMoveExit", "elementMoveFast", "elementResize", "clickBounce", "scroll", "menuDecel"];
        if (disabled) {
            batterySaverAnimationDurations = ({})
            for (const name of animationNames) {
                const animation = Appearance.animation[name];
                if (animation) {
                    batterySaverAnimationDurations[name] = animation.duration;
                    animation.duration = 0;
                }
            }
        } else {
            for (const name of Object.keys(batterySaverAnimationDurations)) {
                const animation = Appearance.animation[name];
                if (animation)
                    animation.duration = batterySaverAnimationDurations[name];
            }
            batterySaverAnimationDurations = ({})
        }
    }

    function setBatterySaver(enabled, manual = false) {
        if (manual)
            batterySaverUserDisabled = !enabled;

        if (enabled === batterySaverEnabled)
            return;

        if (enabled) {
            ColorUtils.forceOpaqueSurfaces = true;
            root.setBatterySaverAnimations(true);
            batterySaverBrightness = ({})
            for (const monitor of Brightness.monitors) {
                if (!monitor.ready) continue;
                batterySaverBrightness[monitor.screen.name] = monitor.brightness;
                monitor.setBrightness(Math.min(monitor.brightness, 0.55));
            }

            root.sidebarLeftOpen = false;
            root.sidebarRightOpen = false;
            root.mediaControlsOpen = false;
            root.overlayOpen = false;
            root.overviewOpen = false;
            root.notifCenterOpen = false;
            batterySaverEnabled = true;
        } else {
            ColorUtils.forceOpaqueSurfaces = false;
            root.setBatterySaverAnimations(false);
            batterySaverEnabled = false;
            for (const monitor of Brightness.monitors) {
                const saved = batterySaverBrightness[monitor.screen.name];
                if (saved !== undefined)
                    monitor.setBrightness(saved);
            }
            batterySaverBrightness = ({})
        }

        // This Hyprland setup uses the Lua parser; `keyword` is rejected by
        // the non-legacy parser, while eval updates the live config cleanly.
        Quickshell.execDetached(["hyprctl", "eval", `hl.config({decoration={blur={enabled=${enabled ? "false" : "true"}}},animations={enabled=${enabled ? "false" : "true"}}})`]);
    }

    function enforceBatterySaverBrightness() {
        if (!batterySaverEnabled) return;
        for (const monitor of Brightness.monitors) {
            if (monitor.ready && monitor.brightness > 0.55)
                monitor.setBrightness(0.55);
        }
    }

    function toggleBatterySaver() {
        setBatterySaver(!batterySaverEnabled, true);
    }

    function syncAutomaticBatterySaver() {
        if (batterySaverAutoEligible) {
            if (!batterySaverUserDisabled)
                setBatterySaver(true);
        } else {
            batterySaverUserDisabled = false;
            if (batterySaverEnabled)
                setBatterySaver(false);
        }
    }

    Connections {
        target: Battery
        function onPercentageChanged() { root.syncAutomaticBatterySaver() }
        function onIsPluggedInChanged() { root.syncAutomaticBatterySaver() }
        function onAvailableChanged() { root.syncAutomaticBatterySaver() }
    }

    Connections {
        target: Brightness
        function onBrightnessChanged() { root.enforceBatterySaverBrightness() }
    }

    IpcHandler {
        target: "batterySaver"

        function toggle(): void { root.toggleBatterySaver() }
        function enable(): void { root.setBatterySaver(true, true) }
        function disable(): void { root.setBatterySaver(false, true) }
        function status(): string { return root.batterySaverEnabled ? "on" : "off" }
    }

    Component.onCompleted: root.syncAutomaticBatterySaver()

    onSidebarRightOpenChanged: {
        if (GlobalStates.sidebarRightOpen) {
            Notifications.timeoutAll();
            Notifications.markAllRead();
        }
    }

    GlobalShortcut {
        name: "workspaceNumber"
        description: "Hold to show workspace numbers, release to show icons"

        onPressed: {
            root.superDown = true
        }
        onReleased: {
            root.superDown = false
        }
    }

    GlobalShortcut {
        name: "batterySaverToggle"
        description: "Toggle battery saver"

        onPressed: root.toggleBatterySaver()
    }
}
