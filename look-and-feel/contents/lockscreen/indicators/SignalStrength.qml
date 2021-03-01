/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1

import MeeGo.QOfono 0.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents


Item {

    width: strengthIcon.height + strengthLabel.width
    Layout.minimumWidth: strengthIcon.height + strengthLabel.width
    OfonoManager {
        id: ofonoManager
        onAvailableChanged: {
           console.log("Ofono is " + available)
        }
        onModemAdded: {
            console.log("modem added " + modem)
        }
        onModemRemoved: console.log("modem removed")
    }

    OfonoNetworkRegistration {
        id: netreg
        Component.onCompleted: {
            netreg.scan()
            updateStrengthIcon()
        }

        onNetworkOperatorsChanged : {
            console.log("operators :"+netreg.currentOperator["Name"].toString())
        }
        modemPath: ofonoManager.modems.length ? ofonoManager.modems[0] : ""
        function updateStrengthIcon() {
            if (netreg.strength >= 100) {
                strengthIcon.source = "network-mobile-100";
            } else if (netreg.strength >= 80) {
                strengthIcon.source = "network-mobile-80";
            } else if (netreg.strength >= 60) {
                strengthIcon.source = "network-mobile-60";
            } else if (netreg.strength >= 40) {
                strengthIcon.source = "network-mobile-40";
            } else if (netreg.strength >= 20) {
                strengthIcon.source = "network-mobile-20";
            } else {
                strengthIcon.source = "network-mobile-0";
            }
        }

        onStrengthChanged: {
            console.log("Strength changed to " + netreg.strength)
            updateStrengthIcon()
        }
    }



    PlasmaCore.IconItem {
        id: strengthIcon
        colorGroup: PlasmaCore.ColorScope.colorGroup
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        width: height
        height: parent.height
    }
    PlasmaComponents.Label {
        id: strengthLabel
        anchors {
            left: strengthIcon.right
            verticalCenter: parent.verticalCenter
        }
        text: netreg.strength + "% " + netreg.name
        color: PlasmaCore.ColorScope.textColor
        font.pixelSize: parent.height / 2
    }
}
