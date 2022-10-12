/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */


import QtQuick 2.12
import QtQuick.Layouts 1.15

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import "indicators" as Indicators

PlasmaComponents.Label {
    id: clock
    
    required property PlasmaCore.DataSource source
    
    property bool is24HourTime: MobileShell.ShellUtil.isSystem24HourFormat
    
    text: Qt.formatTime(source.data.Local.DateTime, is24HourTime ? "h:mm" : "h:mm ap")
    color: PlasmaCore.ColorScope.textColor
    verticalAlignment: Qt.AlignVCenter

    TapHandler {
        onTapped: {
            MobileShell.ShellUtil.launchApp("org.kde.kclock.desktop");
        }
    }
}
