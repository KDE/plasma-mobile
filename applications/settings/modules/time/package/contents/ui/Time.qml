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
//import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.components 0.1 as PlasmaComponents
//import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.active.settings 0.1

Item {
    id: timeModule
    objectName: "timeModule"

    TimeSettings {
        id: timeSettings
    }

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
            //opacity: 1
        }
        Text {
            color: theme.textColor
            font.pixelSize: 32
            style: Text.Sunken
            anchors.horizontalCenter: parent.horizontalCenter
            text: timeSettings.currentTime
        }
    }

    Item {
        id: twentyFourItem
        anchors { top: titleCol.bottom; left: parent.left; right: parent.right; topMargin: 32; }

        Text {
            color: theme.textColor
            anchors.right: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: i18n("Use 24-hour clock:")
            anchors.rightMargin: 12
            //opacity: 1
        }

        PlasmaComponents.Switch {
            checked: timeSettings.twentyFour
            anchors.left: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            onClicked : {
                timeSettings.twentyFour = checked
                print(timeSettings.timeZone);
            }
        }

    }

    Text {
        id: timeZoneLabel
        color: theme.textColor
        anchors.right: parent.horizontalCenter
        anchors.top: twentyFourItem.bottom
        anchors.topMargin: 24
        text: i18n("Timezone:")
        anchors.rightMargin: 12
        //opacity: 1
    }

    Text {
        anchors.left: parent.horizontalCenter
        anchors.verticalCenter: timeZoneLabel.verticalCenter
        text: timeSettings.timeZone

        MouseArea {
            anchors.fill: parent
            onClicked: {
                timeZonePicker.visible = !timeZonePicker.visible;
            }
        }
    }

    TimeZonePicker {
        id: timeZonePicker
        height: parent.height * 0.9
        width: parent.width * 0.8
        anchors.centerIn: parent
        visible: false

    }

    Component.onCompleted: {
        print("Time.qml done loading.");
        //print("settingsObject.name" + timeSettings.name);
    }
}
