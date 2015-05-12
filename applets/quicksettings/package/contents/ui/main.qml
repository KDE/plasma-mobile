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
import org.kde.plasma.plasmoid 2.0


Item {
    id: root

    function toggleAirplane() {
        print("toggle airplane mode")
    }

    Plasmoid.preferredRepresentation: plasmoid.fullRepresentation

    ListModel {
        id: settingsModel

        ListElement {
            text: "Settings"
            icon: "configure"
            enabled: false
            settingsCommand: "active-settings"
            toggleFunction: ""
            delegate: ""
        }
        ListElement {
            text: "Mobile network"
            icon: "network-mobile-80"
            enabled: true
            settingsCommand: ""
        }
        ListElement {
            text: "Airplane mode"
            icon: "flightmode-on"
            enabled: false
            settingsCommand: ""
            toggleFunction: "toggleAirplane"
        }
        ListElement {
            text: "Bluetooth"
            icon: "preferences-system-bluetooth"
            enabled: false
            settingsCommand: ""
        }
        ListElement {
            text: "Wireless"
            icon: "network-wireless-on"
            enabled: true
            settingsCommand: "active-settings -m org.kde.satellite.settings.wifi"
        }
        ListElement {
            text: "Alarms"
            icon: "korgac"
            enabled: false
            settingsCommand: ""
        }
        ListElement {
            text: "Notifications"
            icon: "preferences-desktop-notification"
            enabled: true
            settingsCommand: ""
        }
        ListElement {
            text: "Brightness"
            icon: "video-display-brightness"
            enabled: false
            settingsCommand: "active-settings -m org.kde.active.settings.powermanagement"
            delegate: "BrightnessDelegate"
        }
        ListElement {
            text: "Flashlight"
            icon: "package_games_puzzle"
            enabled: false
            settingsCommand: ""
        }
        ListElement {
            text: "Location"
            icon: "plasmaapplet-location"
            enabled: false
            settingsCommand: ""
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
    }
}
