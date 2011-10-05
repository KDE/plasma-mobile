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
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.qtextracomponents 0.1
import org.kde.plasma.mobilecomponents 0.1
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts

Item {
    id: welcome
    property int minimumWidth: 400
    property int minimumHeight: 300
    state: "StartPage"
    clip: true

    PlasmaCore.Theme {
        id: theme
    }

    Item {
        //anchors.fill: parent
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        id: contentArea
        clip: true
    }

    IconButton {
        id: previousIcon
        icon: QIcon("go-previous")
        onClicked: previousPage();

        anchors.left: parent.left
        anchors.bottom: parent.bottom
    }

    IconButton {
        id: nextIcon
        icon: QIcon("go-next")
        onClicked: nextPage();

        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    StartPage {
        id: startPage
        width: contentArea.width
        anchors.fill: contentArea
    }

    ActivitiesPage {
        id: activitiesPage
        width: contentArea.width
    }

    AppsPage {
        id: appsPage
        width: contentArea.width
    }

    states: [
        State {
            name: "StartPage"
            PropertyChanges { target: previousIcon; opacity: 0.0}
            PropertyChanges { target: startPage; opacity: 1.0}
            PropertyChanges { target: activitiesPage; opacity: 0.0}
            PropertyChanges { target: appsPage; opacity: 0.0}
            PropertyChanges { target: startPage; x: contentArea.x; y: contentArea.y }
            PropertyChanges { target: activitiesPage; x: (contentArea.x + activitiesPage.width); y: contentArea.y }
            PropertyChanges { target: appsPage; x: (contentArea.x + appsPage.width); y: contentArea.y }
        },
        State {
            name: "ActivitiesPage"
            PropertyChanges { target: startPage; opacity: 0.0}
            PropertyChanges { target: appsPage; opacity: 0.0}
            PropertyChanges { target: activitiesPage; opacity: 1.0}
            PropertyChanges { target: activitiesPage; x: contentArea.x; y: contentArea.y }
            PropertyChanges { target: startPage; x: (contentArea.x - activitiesPage.width); y: contentArea.y }
            PropertyChanges { target: appsPage; x: (contentArea.x + appsPage.width); y: contentArea.y }
        },
        State {
            name: "AppsPage"
            PropertyChanges { target: nextIcon; opacity: 0.0}
            PropertyChanges { target: startPage; opacity: 0.0}
            PropertyChanges { target: activitiesPage; opacity: 0.0}
            PropertyChanges { target: appsPage; opacity: 1.0}
            PropertyChanges { target: appsPage; x: contentArea.x; y: contentArea.y }
            PropertyChanges { target: startPage; x: (contentArea.x - startPage.width); y: contentArea.y }
            PropertyChanges { target: activitiesPage; x: (contentArea.x - activitiesPage.width); y: contentArea.y }
        }
    ]

    transitions: [
        Transition {
            from: "*"; to: "StartPage"
            NumberAnimation { properties: "x,y"; easing.type: Easing.InOutQuint; duration: 500 }
            NumberAnimation { properties: "opacity"; easing.type: Easing.InOutQuint; duration: 300 }
        },
        Transition {
            from: "*"; to: "ActivitiesPage"
            NumberAnimation { properties: "x,y"; easing.type: Easing.InOutQuint; duration: 500 }
            NumberAnimation { properties: "opacity"; easing.type: Easing.InOutQuint; duration: 300 }
        },
        Transition {
            from: "*"; to: "AppsPage"
            NumberAnimation { properties: "x,y"; easing.type: Easing.InOutQuint; duration: 500 }
            NumberAnimation { properties: "opacity"; easing.type: Easing.InOutQuint; duration: 300 }
        }
    ]

    function previousPage() {
        if (welcome.state == "ActivitiesPage") {
            welcome.state = "StartPage";
        } else if (welcome.state == "AppsPage") {
            welcome.state = "ActivitiesPage";
        }
    }

    function nextPage() {
        if (welcome.state == "StartPage") {
            welcome.state = "ActivitiesPage";
        } else if (welcome.state == "ActivitiesPage") {
            welcome.state = "AppsPage";
        }
    }

}
