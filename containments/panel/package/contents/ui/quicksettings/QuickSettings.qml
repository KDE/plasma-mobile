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

    function addPlasmoid(applet, id) {
        settingsModel.append({"icon": applet.icon, "text": applet.title, "plasmoidId": id, "enabled": false, "applet": applet, "settingsCommand": ""})
    }

    signal plasmoidTriggered(var applet, var id)
    Layout.minimumHeight: flow.implicitHeight + units.largeSpacing*2

    //HACK: make the list know about the applet delegate which is a qtobject
    QtObject {
        id: nullApplet
    }
    Component.onCompleted: {
        //NOTE: add all in javascript as the static decl of listelements can't have scripts
        settingsModel.append({
            "text": i18n("Settings"),
            "icon": "configure",
            "enabled": false,
            "settingsCommand": "plasma-settings",
            "toggleFunction": "",
            "delegate": "",
            "plasmoidId": -1,
            "enabled": false,
            "applet": null
        });

        settingsModel.append({
            "text": i18n("Flashlight"),
            "icon": "package_games_puzzle",
            "enabled": false,
            "settingsCommand": "",
            "plasmoidId": -1,
            "applet": null
        });
        settingsModel.append({
            "text": i18n("Location"),
            "icon": "find-location-symbolic",
            "enabled": false,
            "settingsCommand": "",
            "plasmoidId": -1,
            "applet": null
        });
    }

    ListModel {
        id: settingsModel
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
