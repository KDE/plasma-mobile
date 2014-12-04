/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *   Copyright 2012 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.active.settings 2.0 as ActiveSettings

Item {
    id: powermanagementModule
    objectName: "powermanagementModule"

    width: 800; height: 500

    ActiveSettings.ConfigGroup {
        id: screensaverConfig
        file: "kscreensaverrc"
        group: "ScreenSaver"
    }

    ActiveSettings.ConfigGroup {
        id: batteryConfig
        file: "powermanagementprofilesrc"
        group: "Battery"
        ActiveSettings.ConfigGroup {
            id: batteryDpmsConfig
            group: "DPMSControl"
        }
        ActiveSettings.ConfigGroup {
            id: batterySuspendConfig
            group: "SuspendSession"
        }
        ActiveSettings.ConfigGroup {
            id: batteryBrightnessConfig
            group: "BrightnessControl"
        }
    }

    ActiveSettings.ConfigGroup {
        id: acConfig
        file: "powermanagementprofilesrc"
        group: "AC"
        ActiveSettings.ConfigGroup {
            id: acDpmsConfig
            group: "DPMSControl"
        }
        ActiveSettings.ConfigGroup {
            id: acSuspendConfig
            group: "SuspendSession"
        }
        ActiveSettings.ConfigGroup {
            id: acBrightnessConfig
            group: "BrightnessControl"
        }
    }

    ActiveSettings.ConfigGroup {
        id: lowBatteryConfig
        file: "powermanagementprofilesrc"
        group: "LowBattery"
        ActiveSettings.ConfigGroup {
            id: lowBatteryDpmsConfig
            group: "DPMSControl"
        }
        ActiveSettings.ConfigGroup {
            id: lowBatterySuspendConfig
            group: "SuspendSession"
        }
        ActiveSettings.ConfigGroup {
            id: lowBatteryBrightnessConfig
            group: "BrightnessControl"
        }
    }

    property QtObject pmSource: PlasmaCore.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["PowerDevil"]
    }

    Column {
        id: mainItem
        anchors.fill: parent
        spacing: units.gridUnit / 2

        PlasmaExtras.Heading {
            text: i18n("Brightness")
            level: 3
        }
        Row {
            spacing: units.gridUnit
            PlasmaComponents.Label {
                width: screensaverEnabledSwitch.width
                text: i18n("0%")
            }
            property int brightness: pmSource.data["PowerDevil"]["Screen Brightness"]
            onBrightnessChanged: brightnessSlider.value = brightness/100

            PlasmaComponents.Slider {
                id: brightnessSlider
                width: mainItem.width * 0.6
                onValueChanged: {
                    acBrightnessConfig.writeEntry("value", Math.round(value*100))
                    batteryBrightnessConfig.writeEntry("value", Math.round(value*100))
                    lowBatteryBrightnessConfig.writeEntry("value", Math.round(value*100))

                    var service = pmSource.serviceForSource("PowerDevil");
                    var operation = service.operationDescription("setBrightness");

                    operation.brightness = Math.round(value*100);
                    service.startOperationCall(operation);
                }
            }
            PlasmaComponents.Label {
                text: i18n("100%")
            }
        }


        PlasmaExtras.Heading {
            text: i18n("Lock screen and Sleep")
            level: 3
        }
        Row {
            spacing: units.gridUnit
            PlasmaComponents.Switch {
                id: screensaverEnabledSwitch
                onCheckedChanged: screensaverConfig.writeEntry("Enabled", checked ? "true" : "false")
                Component.onCompleted: checked = screensaverConfig.readEntry("Enabled") == "true"
            }
            PlasmaComponents.Slider {
                id: screensaverTimeSlider
                enabled: screensaverEnabledSwitch.checked
                minimumValue: 1
                maximumValue: 60
                width: mainItem.width * 0.6
                onValueChanged: {
                    if (screensaverEnabledSwitch.checked) {
                        screensaverConfig.writeEntry("Timeout", Math.round(value)*60)
                    }
                }
                Component.onCompleted: value = screensaverConfig.readEntry("Timeout")/60
            }
            PlasmaComponents.Label {
                enabled: screensaverEnabledSwitch.checked
                opacity: enabled ? 1 : 0.6
                text: i18np("%1 minute", "%1 minutes", screensaverTimeSlider.value)
            }
        }

        PlasmaExtras.Heading {
            text: i18n("Turn off the screen")
            level: 3
        }
        Row {
            spacing: units.gridUnit
            PlasmaComponents.Switch {
                id: dpmsSwitch
                onCheckedChanged: {
                    if (checked) {
                        batteryDpmsConfig.writeEntry("idleTime", Math.round(dpmsTimeSlider.value)*60)
                        lowBatteryDpmsConfig.writeEntry("idleTime", Math.round(dpmsTimeSlider.value)*60)
                        acDpmsConfig.writeEntry("idleTime", Math.round(dpmsTimeSlider.value)*60)
                    } else {
                        batteryDpmsConfig.deleteEntry("idleTime")
                        lowBatteryDpmsConfig.deleteEntry("idleTime")
                        acDpmsConfig.deleteEntry("idleTime")
                    }
                }
                Component.onCompleted: checked = batteryDpmsConfig.readEntry("idleTime") > 0
            }
            PlasmaComponents.Slider {
                id: dpmsTimeSlider
                enabled: dpmsSwitch.checked
                width: mainItem.width * 0.6
                minimumValue: 1
                maximumValue: 60
                onValueChanged: {
                    if (dpmsSwitch.checked) {
                        batteryDpmsConfig.writeEntry("idleTime", Math.round(value)*60)
                        lowBatteryDpmsConfig.writeEntry("idleTime", Math.round(value)*60)
                        acDpmsConfig.writeEntry("idleTime", Math.round(value)*60)
                    }
                }
                Component.onCompleted: value = batteryDpmsConfig.readEntry("idleTime")/60
            }
            PlasmaComponents.Label {
                enabled: dpmsTimeSlider.checked
                opacity: enabled ? 1 : 0.6
                text: i18np("%1 minute", "%1 minutes", dpmsTimeSlider.value)
            }
        }


        /*
         * This is disabled for now:
         * the sleep action is done by the lockscreen
        PlasmaExtras.Heading {
            text: i18n("Sleep")
            level: 3
        }
        Row {
            spacing: units.gridUnit
            PlasmaComponents.Switch {
                id: suspendSwitch
                onCheckedChanged: {
                    if (checked) {
                        batterySuspendConfig.writeEntry("idleTime", Math.round(suspendTimeSlider.value)*60*1000)
                        lowBatterySuspendConfig.writeEntry("idleTime", Math.round(suspendTimeSlider.value)*60*1000)
                        acSuspendConfig.writeEntry("idleTime", Math.round(suspendTimeSlider.value)*60*1000)
                    } else {
                        batterySuspendConfig.deleteEntry("idleTime")
                        lowBatterySuspendConfig.deleteEntry("idleTime")
                        acSuspendConfig.deleteEntry("idleTime")
                    }
                }
                Component.onCompleted: checked = batterySuspendConfig.readEntry("idleTime") > 0
            }
            PlasmaComponents.Slider {
                id: suspendTimeSlider
                enabled: suspendSwitch.checked
                minimumValue: 1
                maximumValue: 60
                onValueChanged: {
                    if (suspendSwitch.checked) {
                        batterySuspendConfig.writeEntry("idleTime", Math.round(value)*60*1000)
                        lowBatterySuspendConfig.writeEntry("idleTime", Math.round(value)*60*1000)
                        acSuspendConfig.writeEntry("idleTime", Math.round(value)*60*1000)
                    }
                }
                Component.onCompleted: value = batterySuspendConfig.readEntry("idleTime")/60/1000
            }
            PlasmaComponents.Label {
                enabled: suspendTimeSlider.checked
                opacity: enabled ? 1 : 0.6
                text: i18np("%1 minute", "%1 minutes", suspendTimeSlider.value)
            }
        }*/
    }

}
