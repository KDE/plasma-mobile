/*
 * SPDX-FileCopyrightText: 2021-2022 Devin Lin <espidev@gmail.com>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

Loader {
    active: true
    asynchronous: true
    height: PlasmaCore.Units.gridUnit * 1.25
    
    sourceComponent: MobileShell.StatusBar {
        id: statusBar
        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
        backgroundColor: "transparent"
        
        showSecondRow: false
        showDropShadow: true
        showTime: false
        disableSystemTray: true // HACK: prevent SIGABRT
    }
}
