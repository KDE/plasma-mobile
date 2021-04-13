/*
 *  SPDX-FileCopyrightText: 2020 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Window 2.2

pragma Singleton

QtObject {
    id: delegate

    signal resetHomeScreenPosition()
    signal snapHomeScreenPosition()
    signal requestRelativeScroll(point pos)
    property Item homeScreen
    property QtObject homeScreenWindow
    property bool homeScreenVisible: true
    property bool taskSwitcherVisible: false
}
