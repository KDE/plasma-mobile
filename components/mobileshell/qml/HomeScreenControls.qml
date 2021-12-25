/*
 *  SPDX-FileCopyrightText: 2020 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Window 2.2

pragma Singleton

QtObject {
    id: delegate

    signal openHomeScreen()
    signal resetHomeScreenPosition()
    signal snapHomeScreenPosition()
    signal requestRelativeScroll(point pos)
    
    property var taskSwitcher
    property QtObject homeScreenWindow
    property bool homeScreenVisible: true
    property bool taskSwitcherVisible: false
}
