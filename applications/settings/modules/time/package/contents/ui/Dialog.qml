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

PlasmaCore.FrameSvgItem {
    id: dialog
    objectName: "timeZonePicker"

    signal filterChanged(string filter)

    height: 300; width: 400
    imagePath: "dialogs/background"
    state: "closed"

    PlasmaCore.Svg {
        id: iconsSvg
        imagePath: "widgets/configuration-icons"
    }

    Loader {
        id: timeZonePicker
        height: parent.height -40; width: parent.width -40
        anchors.centerIn: parent
    }

    SvgButton {
        width: 48; height: width
        targetItem: dialog
        anchors { top: parent.top; right: parent.right; margins: 4; }
    }
    states: [
        State {
            name: "open";
            PropertyChanges { target: dialog; opacity: 1.0; scale: 1.0; }
        },
        State {
            name: "closed";
            PropertyChanges { target: dialog; opacity: 0; scale: 0.8; }
        }
    ]
    transitions: [
        Transition {
            from: "closed"; to: "open"
            MobileComponents.AppearAnimation { targetItem: dialog }
        },
        Transition {
            from: "open"; to: "closed"
            MobileComponents.DisappearAnimation { targetItem: dialog }
        }
    ]

    onStateChanged: {
        if (state == "open") {
            print("Loading timezones ...");
            timeZonePicker.source = "TimeZonePicker.qml";
        }
    }
}