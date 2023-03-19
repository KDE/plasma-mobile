// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

// NOTE: This is a singleton in the mobileshell library, so we need to be careful to
// make this load as fast as possible (since it may be loaded in other processes ex. lockscreen).

pragma Singleton

QtObject {
    readonly property real topPanelHeight: PlasmaCore.Units.gridUnit + PlasmaCore.Units.smallSpacing
    readonly property real bottomPanelHeight: ShellSettings.Settings.navigationPanelEnabled ? PlasmaCore.Units.gridUnit * 2 : 0
}
