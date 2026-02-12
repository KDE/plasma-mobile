/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Tobias Fella <fella@posteo.de>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

pragma Singleton

import QtQuick 2.1
import org.kde.plasma.networkmanagement.cellular as Cellular

QtObject {
    property Cellular.CellularModemList _modemList: Cellular.CellularModemList {}

    readonly property string icon: "network-mobile-" + Math.floor((_modemList.primaryModem ? _modemList.primaryModem.signalStrength : 0) / 20) * 20

    readonly property string label: {
        if (!_modemList.primaryModem) return "";
        if (_modemList.primaryModem.simLocked) return i18n("SIM Locked");
        return _modemList.primaryModem.operatorName;
    }

    readonly property bool showIndicator: _modemList.modemAvailable
}
