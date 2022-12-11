// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Window 2.15

pragma Singleton

/**
 * Provides access to common functions within the shell. Only available within the plasmashell process.
 */
QtObject {
    id: delegate

    /**
     * Whether the task switcher is open.
     */
    readonly property bool taskSwitcherVisible: HomeScreenControls.taskSwitcherVisible
    
    /**
     * Whether the homescreen is currently visible.
     */
    readonly property bool homeScreenVisible: HomeScreenControls.homeScreenVisible
    
    /**
     * Whether the action drawer is currently open.
     */
    readonly property bool actionDrawerVisible: TopPanelControls.actionDrawerVisible
    
    /**
     * Open the app launch screen with animation parameters.
     */
    function openAppLaunchAnimation(splashIcon: string, title: string, x: real, y: real, sourceIconSize: real) {
        HomeScreenControls.openAppLaunchAnimation(splashIcon, title, x, y, sourceIconSize);
    }
    
    /**
     * Close the app launch screen.
     */
    function closeAppLaunchAnimation() {
        HomeScreenControls.closeAppLaunchAnimation();
    }
    
    /**
     * Open the action drawer.
     */
    function openActionDrawer() {
        TopPanelControls.openActionDrawer();
    }
    
    /**
     * Close the action drawer, if it is open.
     */
    function closeActionDrawer() {
        TopPanelControls.closeActionDrawer();
    }
}
