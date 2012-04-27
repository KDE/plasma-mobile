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

import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.active.settings 0.1 as ActiveSettings

Item {
    id: webModule
    objectName: "webModule"

    width: 800; height: 500

    PlasmaCore.Theme {
        id: theme
    }

    Column {
        id: titleCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        PlasmaExtras.Title {
            text: settingsComponent.name
            opacity: 1
        }
        PlasmaComponents.Label {
            id: descriptionLabel
            text: settingsComponent.description
            opacity: .4
        }
    }

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
    }

    property QtObject pmSource: PlasmaCore.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["PowerDevil"]
    }

    Column {
        anchors.centerIn: parent
        spacing: theme.defaultFont.mSize.height

        /**TODO: this needs the QML battery plasmoid branch merged in workspace
        PlasmaExtras.Heading {
            text: i18n("Brightness")
            level: 2
        }
        Row {
            spacing: theme.defaultFont.mSize.width
            PlasmaComponents.Label {
                width: screensaverEnabledSwitch.width
                text: i18n("0%")
            }
            property int brightness: pmSource.data["PowerDevil"]["Screen Brightness"]
            onBrightnessChanged: brightnessSlider.value = brightness
            
            PlasmaComponents.Slider {
                id: brightnessSlider
                onValueChanged: {
                    var service = pmSource.serviceForSource("PowerDevil");
                    var operation = service.operationDescription("setBrightness");
                    operation.brightness = value;
                    service.startOperationCall(operation);
                }
            }
            PlasmaComponents.Label {
                text: i18n("100%")
            }
        }
        */

        PlasmaExtras.Heading {
            text: i18n("Lock screen")
            level: 2
        }
        Row {
            spacing: theme.defaultFont.mSize.width
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
            level: 2
        }
        Row {
            spacing: theme.defaultFont.mSize.width
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


        PlasmaExtras.Heading {
            text: i18n("Sleep")
            level: 2
        }
        Row {
            spacing: theme.defaultFont.mSize.width
            PlasmaComponents.Switch {
                id: suspendSwitch
                onCheckedChanged: {
                    if (checked) {
                        batterySuspendConfig.writeEntry("idleTime", Math.round(suspendTimeSlider.value)*60)
                        lowBatterySuspendConfig.writeEntry("idleTime", Math.round(suspendTimeSlider.value)*60)
                        acSuspendConfig.writeEntry("idleTime", Math.round(suspendTimeSlider.value)*60)
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
                        batterySuspendConfig.writeEntry("idleTime", Math.round(value)*60)
                        lowBatterySuspendConfig.writeEntry("idleTime", Math.round(value)*60)
                        acSuspendConfig.writeEntry("idleTime", Math.round(value)*60)
                    }
                }
                Component.onCompleted: value = batterySuspendConfig.readEntry("idleTime")/60
            }
            PlasmaComponents.Label {
                enabled: suspendTimeSlider.checked
                opacity: enabled ? 1 : 0.6
                text: i18np("%1 minute", "%1 minutes", suspendTimeSlider.value)
            }
        }
    }

}
