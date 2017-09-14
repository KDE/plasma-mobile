/*
 *   Copyright 2015 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents


Item {
    id: root

    function toggleAirplane() {
        print("toggle airplane mode")
    }

    function addPlasmoid(icon, text, id) {
        settingsModel.append({"icon": icon, "text": text, "plasmoidId": id, "enabled": false})
    }

    signal plasmoidTriggered(var id)
    Layout.minimumHeight: flow.implicitHeight + units.largeSpacing*2

    property int screenBrightness
    readonly property int maximumScreenBrightness: pmSource.data["PowerDevil"] ? pmSource.data["PowerDevil"]["Maximum Screen Brightness"] || 0 : 0
    onScreenBrightnessChanged: {
        var service = pmSource.serviceForSource("PowerDevil");
        var operation = service.operationDescription("setBrightness");
        operation.brightness = screenBrightness;
        operation.silent = true
        service.startOperationCall(operation);
    }

    PlasmaCore.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["PowerDevil"]
        onSourceAdded: {
            if (source === "PowerDevil") {
                disconnectSource(source);
                connectSource(source);
            }
        }

        onDataChanged: {
            root.screenBrightness = pmSource.data["PowerDevil"]["Screen Brightness"];
        }
    }

    ListModel {
        id: settingsModel

        ListElement {
            text: "Settings"
            icon: "configure"
            enabled: false
            settingsCommand: "plasma-settings"
            toggleFunction: ""
            delegate: ""
            plasmoidId: -1
        }
       /* ListElement {
            text: "Mobile network"
            icon: "network-mobile-80"
            enabled: true
            settingsCommand: ""
            plasmoidId: -1
        }
        ListElement {
            text: "Airplane mode"
            icon: "flightmode-on"
            enabled: false
            settingsCommand: ""
            toggleFunction: "toggleAirplane"
            plasmoidId: -1
        }
        ListElement {
            text: "Bluetooth"
            icon: "preferences-system-bluetooth"
            enabled: false
            settingsCommand: ""
            plasmoidId: -1
        }
        ListElement {
            text: "Wireless"
            icon: "network-wireless-on"
            enabled: true
            settingsCommand: "plasmawindowed org.kde.plasma.networkmanagement"
            plasmoidId: -1
        }
        ListElement {
            text: "Alarms"
            icon: "korgac"
            enabled: false
            settingsCommand: "ktimer"
            plasmoidId: -1
        }*/
        ListElement {
            text: "Flashlight"
            icon: "package_games_puzzle"
            enabled: false
            settingsCommand: ""
            plasmoidId: -1
        }
        ListElement {
            text: "Location"
            icon: "plasmaapplet-location"
            enabled: false
            settingsCommand: ""
            plasmoidId: -1
        }
    }

    Flow {
        id: flow
        anchors {
            fill: parent
            margins: units.largeSpacing
        }
        spacing: units.largeSpacing
        Repeater {
            model: settingsModel
            delegate: Loader {
                width: item ? item.implicitWidth : 0
                height: item ? item.implicitHeight : 0
                source: Qt.resolvedUrl((model.delegate ? model.delegate : "Delegate") + ".qml")
            }
        }
        move: Transition {
            NumberAnimation {
                duration: units.shortDuration
                easing.type: Easing.InOutQuad
                properties: "x,y"
            }
        }
        RowLayout {
            width: flow.width
            PlasmaCore.IconItem {
                Layout.preferredWidth: units.iconSizes.small
                Layout.preferredHeight: Layout.preferredWidth
                //TODO: needs brightness
                source: "contrast"
            }
            PlasmaComponents.Slider {
                id: brightnessSlider
                Layout.fillWidth: true
                value: root.screenBrightness
                onValueChanged: {
                    if (pressed) {
                        root.screenBrightness = value
                    }
                }
                minimumValue: maximumValue > 100 ? 1 : 0
                maximumValue: root.maximumScreenBrightness
                stepSize: 1
            }
            PlasmaCore.IconItem {
                Layout.preferredWidth: units.iconSizes.small
                Layout.preferredHeight: Layout.preferredWidth
                //TODO: needs brightness
                source: "contrast"
            }
        }
    }
}
