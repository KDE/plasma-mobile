// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts

Item {
    id: welcome
    width: 200
    height: 300
    state: "StartPage"

    PlasmaCore.Theme {
        id: theme
    }

    StartPage {
        id: startPage
        anchors.fill: parent
    }

    ActivitiesPage {
        id: activitiesPage
        anchors.fill: parent
    }

    MouseArea {
        anchors.fill: parent
        onClicked: nextPage()
    }

    states: [
        State {
            name: "StartPage"
            PropertyChanges { target: startPage; opacity: 1.0}
            PropertyChanges { target: activitiesPage; opacity: 0.0}
        },
        State {
            name: "ActivitiesPage"
            PropertyChanges { target: startPage; opacity: 0.0}
            PropertyChanges { target: activitiesPage; opacity: 1.0}
        }
    ]

    transitions: [
        Transition {
            from: "*"; to: "StartPage"
            PropertyAnimation { properties: "opacity"; easing.type: Easing.InOutQuint; duration: 500 }
        },
        Transition {
            from: "*"; to: "ActivitiesPage"
            PropertyAnimation { properties: "opacity"; easing.type: Easing.InOutQuint; duration: 500 }
        }
    ]

    function nextPage() {
        print("next page ...");
        if (welcome.state == "StartPage") {
            welcome.state = "ActivitiesPage";
        } else {
            welcome.state = "StartPage";
        }
    }

}
