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

    ActiveSettings.ConfigModel {
        id: historyConfig
        file: "active-webbrowserrc"
        group: "history"
    }

    ActiveSettings.ConfigModel {
        id: adblockConfig
        file: "active-webbrowserrc"
        group: "adblock"
    }


    Item {
        id: startPageItem
        anchors { top: titleCol.bottom; left: parent.left; right: parent.right; topMargin: 32; }

        Text {
            color: theme.textColor
            anchors { right: parent.horizontalCenter; verticalCenter: parent.verticalCenter; rightMargin: 12; }
            text: i18n("Start page:")
        }

        PlasmaComponents.TextField {
            id: startPageText
            text: "http://plasma-active.org"
            anchors { left: parent.horizontalCenter; verticalCenter: parent.verticalCenter; }
            anchors.right: saveStartPage.left
            Keys.onReturnPressed: historyConfig.writeEntry("startPage", startPageText.text);
        }
        PlasmaComponents.Button {
            id: saveStartPage
            height: startPageText.height
            iconSource: "dialog-ok-apply"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            onClicked: historyConfig.writeEntry("startPage", startPageText.text);
        }

    }

    Item {
        id: adblockItem
        anchors { top: startPageItem.bottom; left: parent.left; right: parent.right; topMargin: 48; }

        Text {
            color: theme.textColor
            anchors { right: parent.horizontalCenter; verticalCenter: parent.verticalCenter; rightMargin: 12; }
            text: i18n("Block ads:")
        }

        PlasmaComponents.Switch {
            checked: true
            anchors { left: parent.horizontalCenter; verticalCenter: parent.verticalCenter; }
            onClicked: adblockConfig.writeEntry("adBlockEnabled", checked);
        }

    }

    PlasmaComponents.Button {
        text: i18n("Clear history")
        anchors { left: parent.horizontalCenter; top: adblockItem.bottom; topMargin: 32; }
        onClicked: historyConfig.writeEntry("history", []);
    }

    Component.onCompleted: {
        print("Web.qml done loading.");
    }
}
