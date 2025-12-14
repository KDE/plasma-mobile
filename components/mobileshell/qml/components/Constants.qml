// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.state as MobileShellState

// NOTE: This is a singleton in the mobileshell library, so we need to be careful to
// make this load as fast as possible (since it may be loaded in other processes ex. lockscreen).

pragma Singleton

QtObject {
    id: root
    readonly property var panelSettings: MobileShellState.PanelSettingsDBusClient {
        screenName: Screen.name
    }

    readonly property real defaultTopPanelHeight: Math.round(Kirigami.Units.gridUnit * ShellSettings.Settings.statusBarScaleFactor / 2) * 2 + Kirigami.Units.smallSpacing

    readonly property real topPanelHeight: {
        if (root.panelSettings.statusBarHeight <= 0) {
            return defaultTopPanelHeight;
        }
        return root.panelSettings.statusBarHeight;
    }

    readonly property real defaultNavigationPanelThickness: Kirigami.Units.gridUnit * 2
    readonly property real defaultGesturePanelThickness: Kirigami.Units.gridUnit

    readonly property real navigationPanelThickness: {
        if (!ShellSettings.Settings.navigationPanelEnabled) {
            return ShellSettings.Settings.gesturePanelEnabled ? defaultGesturePanelThickness : 0;
        }
        if (root.panelSettings.navigationPanelHeight <= 0) {
            return defaultNavigationPanelThickness;
        }
        return root.panelSettings.navigationPanelHeight;
    }

    function navigationPanelOnSide(screenWidth: real, screenHeight: real): bool {
        // TODO: we have this disabled for now, we might consider just removing this feature entirely due to it causing several issues:
        //       (the feature being the navigation panel being moved to the right when the screen height is small)
        //       => the keyboard dimensions are incorrect
        //       => shell seems to crash randomly (attempted hotfixes with just delay timers, but not great and also doesn't work now)
        return false; // screenWidth > screenHeight && screenHeight < 500;
    }
}
