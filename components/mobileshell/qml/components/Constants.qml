// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

// NOTE: This is a singleton in the mobileshell library, so we need to be careful to
// make this load as fast as possible (since it may be loaded in other processes ex. lockscreen).

pragma Singleton

QtObject {
    readonly property real topPanelHeight: Kirigami.Units.gridUnit + Kirigami.Units.smallSpacing
    readonly property real navigationPanelThickness: ShellSettings.Settings.navigationPanelEnabled ? Kirigami.Units.gridUnit * 2 : 0

    function navigationPanelOnSide(screenWidth: real, screenHeight: real): bool {
        // TODO: we have this disabled for now, we might consider just removing this feature entirely due to it causing several issues:
        //       (the feature being the navigation panel being moved to the right when the screen height is small)
        //       => the keyboard dimensions are incorrect
        //       => shell seems to crash randomly (attempted hotfixes with just delay timers, but not great and also doesn't work now)
        return false; // screenWidth > screenHeight && screenHeight < 500;
    }
}
