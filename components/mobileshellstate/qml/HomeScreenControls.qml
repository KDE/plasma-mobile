// SPDX-FileCopyrightText: 2020 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Window 2.2

pragma Singleton

/**
 * Provides access to the homescreen plasmoid containment within the shell.
 */
QtObject {
    id: root

    signal openHomeScreen()
    signal resetHomeScreenPosition()
    signal requestRelativeScroll(point pos)
    
    signal openAppLaunchAnimation(string splashIcon, string title, real x, real y, real sourceIconSize)
    signal closeAppLaunchAnimation()
    
    property var taskSwitcher
    property QtObject homeScreenWindow
    property bool taskSwitcherVisible: false
}
