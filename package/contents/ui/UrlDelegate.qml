/***************************************************************************
 *                                                                         *
 *   Copyright 2014-2015 Sebastian Kügler <sebas@kde.org>                  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 *                                                                         *
 ***************************************************************************/

import QtQuick 2.3
//import QtQuick.Controls 1.0

//import QtWebEngine 1.0

import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras


MouseArea {
    id: urlDelegate

    height: units.gridUnit * 3
    width: parent.width

    //Rectangle { anchors.fill: parent; color: "white"; opacity: 0.5; }

    onClicked: {
        load(url)
//         tabs.newTab(url)
//         contentView.state = "hidden"
    }

    signal removed

    onPressed: highlight.opacity = 1
    onReleased: highlight.opacity = 0

    PlasmaComponents.Highlight {
        id: highlight
        opacity: 0
        anchors.fill: parent

    }

    PlasmaCore.IconItem {
        id: urlIcon

        width: height

        anchors {
            left: parent.left
            top: parent.top
            topMargin: units.gridUnit / 2
            bottomMargin: units.gridUnit / 2
            bottom: parent.bottom
            margins: units.smallSpacing
        }
        source: icon

    }

    Image {
        anchors.fill: urlIcon
        source: preview == undefined ? "" : preview
    }

    PlasmaComponents.Label {
        id: urlTitle
        text: title
        anchors {
            left: urlIcon.right
            leftMargin: units.largeSpacing / 2
            right: parent.right
            bottom: parent.verticalCenter
            top: urlIcon.top
            //margins: units.smallSpacing
        }
    }

    PlasmaComponents.Label {
        id: urlUrl
        text: url
        opacity: 0.6
        font.pointSize: theme.smallestFont.pointSize
        anchors {
            left: urlIcon.right
            leftMargin: units.largeSpacing / 2
            right: removeIcon.left
            top: urlIcon.verticalCenter
            bottom: parent.bottom
            //margins: units.smallSpacing
        }
    }

    PlasmaCore.IconItem {
        id: removeIcon

        width: height
        source: "list-remove"
        //visible: bookmarked

        anchors {
            right: parent.right
            top: parent.top
            topMargin: units.gridUnit
            bottomMargin: units.gridUnit
            bottom: parent.bottom
            margins: units.smallSpacing
        }
        MouseArea {
            anchors.fill: parent
            onClicked: urlDelegate.removed();
        }
    }


}
