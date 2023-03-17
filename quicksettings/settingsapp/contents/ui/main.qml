// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

QS.QuickSetting {
    text: i18n("Settings")
    status: i18n("Tap to open")
    icon: "configure"
    enabled: false
    settingsCommand: "plasma-open-settings"
}
