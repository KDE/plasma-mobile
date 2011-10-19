// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Rectangle {
    id: settingsRoot
    objectName: "settingsRoot"

    width: 800; height: 500
    color: theme.backgroundColor

    PlasmaCore.Theme {
        id: theme
    }

    MobileComponents.Package {
        id: activeSettings
        name: "org.kde.active.settings"
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 100
        color: "green"
        opacity: 0.2
    }

    Component.onCompleted: {
        print("main.qml done loading.");
    }
}
