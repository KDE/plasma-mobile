/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */


import QtQuick 2.12
import QtQuick.Layouts 1.15

import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

import org.kde.kirigami as Kirigami

RowLayout {
    id: clockText

    required property int fontPixelSize
    required property P5Support.DataSource source

    PlasmaComponents.Label {
        id: clock

        property bool is24HourTime: MobileShell.ShellUtil.isSystem24HourFormat

        text: Qt.formatTime(source.data.Local.DateTime, is24HourTime ? "h:mm" : "h:mm ap")
        color: Kirigami.Theme.textColor
        verticalAlignment: Qt.AlignVCenter
        font.pixelSize: fontPixelSize
     }

    PlasmaComponents.Label {
        id: date
        visible: ShellSettings.Settings.dateInStatusBar && !root.showSecondRow

        text: Qt.formatDate(source.data.Local.DateTime, "ddd. MMMM d")
        color: Kirigami.Theme.textColor
        verticalAlignment: Qt.AlignVCenter
        font.pixelSize: fontPixelSize
    }
}
