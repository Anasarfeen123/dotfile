import QtQuick
import Quickshell

import qs
import qs.modules.common
import qs.modules.ii.background
import qs.modules.ii.bar
import qs.modules.ii.cheatsheet
import qs.modules.ii.dock
import qs.modules.ii.lock
import qs.modules.ii.mediaControls
import qs.modules.ii.notificationPopup
import qs.modules.ii.onScreenDisplay
import qs.modules.ii.onScreenKeyboard
import qs.modules.ii.overview
import qs.modules.ii.polkit
import qs.modules.ii.regionSelector
import qs.modules.ii.screenCorners
import qs.modules.ii.screenTranslator
import qs.modules.ii.sessionScreen
import qs.modules.ii.sidebarLeft
import qs.modules.ii.sidebarRight
import qs.modules.ii.overlay
import qs.modules.ii.verticalBar
import qs.modules.ii.wallpaperSelector

Scope {
    PanelLoader { extraCondition: !Config.options.bar.vertical; component: Bar {} }
    PanelLoader { extraCondition: !Config.options.bar.vertical; component: UtilityMenu {} }
    PanelLoader { extraCondition: !Config.options.bar.vertical; component: NotificationCenterPanel {} }
    PanelLoader { extraCondition: !GlobalStates.batterySaverEnabled; component: Background {} }
    PanelLoader { extraCondition: !GlobalStates.batterySaverEnabled; component: Cheatsheet {} }
    PanelLoader { extraCondition: Config.options.dock.enable && !GlobalStates.batterySaverEnabled; component: Dock {} }
    PanelLoader { component: Lock {} }
    PanelLoader { extraCondition: !GlobalStates.batterySaverEnabled; component: MediaControls {} }
    PanelLoader { extraCondition: !GlobalStates.batterySaverEnabled; component: NotificationPopup {} }
    PanelLoader { extraCondition: !GlobalStates.batterySaverEnabled; component: OnScreenDisplay {} }
    PanelLoader { extraCondition: !GlobalStates.batterySaverEnabled; component: OnScreenKeyboard {} }
    PanelLoader { extraCondition: !GlobalStates.batterySaverEnabled; component: Overlay {} }
    PanelLoader { extraCondition: !GlobalStates.batterySaverEnabled; component: Overview {} }
    PanelLoader { extraCondition: !GlobalStates.batterySaverEnabled; component: Polkit {} }
    PanelLoader { extraCondition: !GlobalStates.batterySaverEnabled; component: RegionSelector {} }
    PanelLoader { extraCondition: !GlobalStates.batterySaverEnabled; component: ScreenCorners {} }
    PanelLoader { extraCondition: !GlobalStates.batterySaverEnabled; component: ScreenTranslator {} }
    PanelLoader { extraCondition: !GlobalStates.batterySaverEnabled; component: SessionScreen {} }
    PanelLoader { extraCondition: !GlobalStates.batterySaverEnabled; component: SidebarLeft {} }
    PanelLoader { component: SidebarRight {} }
    PanelLoader { extraCondition: Config.options.bar.vertical; component: VerticalBar {} }
    PanelLoader { extraCondition: !GlobalStates.batterySaverEnabled; component: WallpaperSelector {} }
}
