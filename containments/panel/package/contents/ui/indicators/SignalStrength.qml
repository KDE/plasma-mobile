/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1

import MeeGo.QOfono 0.2

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    width: strengthIcon.height + strengthLabel.width
    Layout.minimumWidth: strengthIcon.height + strengthLabel.width

    OfonoManager {
        id: ofonoManager
    }

    OfonoNetworkRegistration {
        id: netreg
        Component.onCompleted: {
            netreg.scan()
        }

        modemPath: ofonoManager.modems.length ? ofonoManager.modems[0] : ""
    }

    OfonoSimManager {
        id: simManager
        modemPath: ofonoManager.modems.length ? ofonoManager.modems[0] : ""
    }

    PlasmaCore.IconItem {
        id: strengthIcon
        colorGroup: PlasmaCore.ColorScope.colorGroup
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: height
        height: parent.height

        source: netreg.strength == 100 ? "network-mobile-100"
                : netreg.strength >= 80 ? "network-mobile-80"
                : netreg.strength >= 60 ? "network-mobile-60"
                : netreg.strength >= 40 ? "network-mobile-40"
                : netreg.strength >= 20 ? "network-mobile-20"
                : "network-mobile-0"
    }

    PlasmaComponents.Label {
        id: label
        anchors.left: strengthIcon.right
        anchors.verticalCenter: parent.verticalCenter

        text: simManager.pinRequired !== OfonoSimManager.NoPin ? i18n("Sim locked") : netreg.name
        color: PlasmaCore.ColorScope.textColor
        font.pixelSize: parent.height / 2
    }
}
