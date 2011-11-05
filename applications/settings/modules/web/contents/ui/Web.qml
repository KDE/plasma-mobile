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
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.active.settings 0.1 as ActiveSettings

Item {
    id: webModule
    objectName: "webModule"

    width: 800; height: 500

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
    Item {
        id: configInput
        width: 400
        height: 32
        //property alias file
        anchors { top: titleCol.bottom; left: parent.left; right: parent.right; topMargin: height }
        PlasmaComponents.TextField {
            width: parent.width/3
            anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
            id: fileField
            text: "active-webbrowserrc"
        }
        PlasmaComponents.TextField {
            width: parent.width/3
            anchors { top: parent.top; bottom: parent.bottom; left: fileField.right }
            id: groupField
            text: "history"
        }
        PlasmaComponents.Button {
            id: loadButton
            width: groupField.height*3
            height: groupField.height
            text: "Load"
            anchors { top: parent.top; bottom: parent.bottom; left: groupField.right;}

            onClicked: {
                console.log("Loading File: " + fileField.text + " Group: " + groupField.text);
                configModel.group = groupField.text
                configModel.file = fileField.text
            }

            Keys.onTabPressed: bt2.forceActiveFocus();
        }
        PlasmaComponents.Button {
            id: loadButton2
            width: groupField.height*3
            height: groupField.height
            text: "kwin"
            anchors { top: parent.top; bottom: parent.bottom; left: loadButton.right; right: parent.right }

            onClicked: {
                console.log("Loading File: kwinrc Group: Windows");
                configModel.group = "Windows"
                configModel.file = "kwinrc"
            }

            Keys.onTabPressed: bt2.forceActiveFocus();
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
            top: configInput.bottom
            topMargin: spacing*2
            bottom: parent.bottom
        }
        model: configModel
        delegate: configDelegate

        Rectangle { anchors.fill: configList; color: "white"; opacity: 0.1; }
    }
    Component {
        id: configDelegate
        Item {
            height: 24
            width: configList.width
            Text { text: "<b>" + configKey + "</b>:   "; anchors.right: parent.horizontalCenter }
            Text { text: configValue; anchors.left: parent.horizontalCenter }
        }
    }

    ActiveSettings.ConfigModel {
        id: configModel
        file: "kdeglobals"
        group: "General"
    }

    Component.onCompleted: {
        print("Web.qml done loading.");
    }
}
