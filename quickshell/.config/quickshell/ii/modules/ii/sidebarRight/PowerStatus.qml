import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

StyledGlassSurface {
    id: root
    fillOpacity: 0.38
    visible: Battery.available

    implicitHeight: content.implicitHeight + 24
    implicitWidth: 200

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        RowLayout { // Title
            Layout.fillWidth: true
            spacing: 8

            MaterialSymbol {
                text: "battery_charging_full"
                iconSize: 18
                color: Battery.isCharging ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer1
            }
            StyledText {
                Layout.fillWidth: true
                text: Translation.tr("Power")
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
                color: Appearance.colors.colOnLayer1
            }
            StyledText {
                text: {
                    if (Battery.isCharging) return Translation.tr("Charging");
                    if (Battery.isPluggedIn) return Translation.tr("Plugged in");
                    return Translation.tr("On battery");
                }
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Battery.isCharging ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
            }
        }

        RowLayout { // Percentage + big bar
            spacing: 10

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: `${Math.round(Battery.percentage * 100)}%`
                font.pixelSize: Appearance.font.pixelSize.huge
                font.weight: Font.DemiBold
                color: Appearance.colors.colOnLayer1
            }
            StyledProgressBar {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                value: Battery.percentage
                valueBarWidth: content.width
                valueBarHeight: 10
                highlightColor: Battery.isLow ? Appearance.colors.colError : Appearance.colors.colPrimary
                trackColor: ColorUtils.applyAlpha(Appearance.colors.colLayer2Base, 0.5)
            }
        }

        StyledText { // Time estimate
            Layout.fillWidth: true
            text: {
                const mins = Battery.isCharging ? Battery.timeToFull : Battery.timeToEmpty;
                if (isNaN(mins) || mins < 0) return "";
                const h = Math.floor(mins / 60);
                const m = Math.round(mins % 60);
                return Battery.isCharging
                    ? Translation.tr("Full in %1h %2m").arg(h).arg(m)
                    : Translation.tr("%1h %2m remaining").arg(h).arg(m);
            }
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colSubtext
        }
    }
}
