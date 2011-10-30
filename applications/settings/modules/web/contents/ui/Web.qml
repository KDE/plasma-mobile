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
import org.kde.active.settings 0.1 as ActiveSettings

Item {
    id: webModule
    objectName: "webModule"

    width: 800; height: 500
    //color: theme.backgroundColor

    PlasmaCore.Theme {
        id: theme
    }

    Column {
        id: titleCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 12
        Text {
            color: theme.textColor
            text: "<h3>" + moduleTitle + "</h3>"
            opacity: 1
        }
        Text {
            id: descriptionLabel
            color: theme.textColor
            text: moduleDescription
            opacity: .4
        }
    }
    ListView {
        id: configList
        currentIndex: -1
        //height: 500
        width: parent.width
        clip: true
        spacing: 8
        anchors {
            //verticalCenter: parent.verticalCenter
            top: titleCol.bottom
            topMargin: spacing
            bottom: parent.bottom
        }
        model: configModel

        delegate: configDelegate

        Rectangle { anchors.fill: parent; color: "green"; opacity: 0.3; }
    }
    Component {
        id: configDelegate
        Item {
            id: tzDelegateContainer
            height: 24
            width: timeZonesList.width

            Text {
                id: tzLabel
                anchors.fill: parent
                text: display
                //text: modelData.name
                color: theme.textColor
            }
        }
    }

    ActiveSettings.ConfigModel {
        id: configModel
        configFile: "active-webbrowserrc"
    }

    Component.onCompleted: {
        print("Web.qml done loading.");
    }
}
