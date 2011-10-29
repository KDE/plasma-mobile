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
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.active.settings 0.1
import org.kde.qtextracomponents 0.1

PlasmaCore.FrameSvgItem {
    imagePath: "widgets/frame"
    prefix: "raised"
    //id: settingsRoot
    id: timeZonePicker
    objectName: "timeZonePicker"
    signal filterChanged(string filter)

    //anchors { top: twentyFourItem.bottom; left: parent.left; right: parent.right; topMargin: 32; }
    height: 300
    width: 400

    Text {
        id: timeZoneLabel
        color: theme.textColor
        anchors.right: parent.horizontalCenter
        anchors.top: parent.top
        text: i18n("Timezone:")
        anchors.rightMargin: 12
        //opacity: 1
    }

    Text {
        anchors.left: parent.horizontalCenter
        anchors.verticalCenter: timeZoneLabel.verticalCenter
        text: timeSettings.timeZone
    }

    PlasmaComponents.TextField {
        id: tzFilter
        width: parent.width / 4
        placeholderText: "filter..."
        //Keys.onTabPressed: tf2.forceActiveFocus();
        anchors {
            //verticalCenter: parent.verticalCenter
            top: timeZoneLabel.bottom
            //topMargin: 32;
            //bottom: parent.bottom
        }
        onTextChanged: {
            print("update filter");
            timeSettings.timeZoneFilterChanged(text);
        }
    }

    ListView {
        id: timeZonesList
        //height: 500
        width: parent.width
        clip: true
        spacing: 8
        anchors {
            //verticalCenter: parent.verticalCenter
            top: tzFilter.bottom
            topMargin: spacing
            bottom: parent.bottom
        }

        model: timeSettings.timeZones

        delegate: timeZoneDelegate
    }
    Component {
        id: timeZoneDelegate
        Item {
            id: tzDelegateContainer
            height: 24
            width: timeZonesList.width

            Text {
                id: tzLabel
                anchors.fill: parent
                text: modelData.name
                color: theme.textColor
            }

            MouseArea {
                id: theMouse
                //height: 24
                //width: 200
                anchors.margins: timeZonesList.spacing / -2 +2
                anchors.fill: tzDelegateContainer
                onClicked: {
                    print (" save: " + modelData.name);
                    timeSettings.saveTimeZone(modelData.name);
                    timeZonePicker.visible = false;
                }
            }
            //Rectangle { anchors.fill: theMouse; color: "green"; opacity: 0.2; }
        }
    }
    //Rectangle { anchors.fill: timeZonePicker; color: "green"; opacity: 0.1; }
    //Rectangle { anchors.fill: timeZonesList; color: "blue"; opacity: 0.1; p

    QIconItem {
        width: 24
        height: width
        icon: QIcon("dialog-close")
        anchors { top: parent.top; right: parent.right; margins: 8; }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                timeZonePicker.visible = false;
            }
        }
    }

}