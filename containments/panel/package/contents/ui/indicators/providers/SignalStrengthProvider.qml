/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
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

QtObject {
    property string icon: netreg.strength == 100 ? "network-mobile-100"
                        : netreg.strength >= 80 ? "network-mobile-80"
                        : netreg.strength >= 60 ? "network-mobile-60"
                        : netreg.strength >= 40 ? "network-mobile-40"
                        : netreg.strength >= 20 ? "network-mobile-20"
                        : "network-mobile-0"
    
    property string label: simManager.pinRequired !== OfonoSimManager.NoPin ? i18n("Sim locked") : netreg.name

    property OfonoManager ofonoManager: OfonoManager {}

    property OfonoNetworkRegistration netreg: OfonoNetworkRegistration {
        Component.onCompleted: {
            netreg.scan()
        }

        modemPath: ofonoManager.modems.length ? ofonoManager.modems[0] : ""
    }

    property OfonoSimManager simManager: OfonoSimManager {
        modemPath: ofonoManager.modems.length ? ofonoManager.modems[0] : ""
    }
}

