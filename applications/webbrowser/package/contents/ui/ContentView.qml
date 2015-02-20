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
//import QtWebEngine 1.0
//import QtQuick.Controls 1.0
//import QtQuick.Controls.Styles 1.0
import QtQuick.Layouts 1.0
//import QtQuick.Window 2.1
//import QtQuick.Controls.Private 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras


Rectangle {
    id: contentView

    //state: "hidden"
    state: "hidden"

    property string title: ""

    color: theme.backgroundColor
    Rectangle {
        color: "white"
        opacity: 0.6
        anchors.fill: parent
    }

    opacity: state == "hidden" ? 0.0 : 1.0
    Behavior on opacity {
        NumberAnimation {
            duration: units.longDuration/2;
            easing.type: Easing.InOutQuad
        }
    }
    MouseArea {
        // block intput from arriving in the webview
        anchors.fill: parent
        visible: contentView.state != "hidden"
        onPressed: {
            mouse.accepted = true;
            print("Blocked Mouse.");
        }
    }

    Loader {
        id: contentViewLoader

        anchors {
            top: heading.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: units.gridUnit / 2
        }
    }

    PlasmaExtras.Heading {
        id: heading

        level: 2

        text: contentView.title
        anchors {
            right: closeButton.left
            top: parent.top
            left: parent.left
            margins: units.gridUnit / 2
        }
        MouseArea {
            anchors.fill: parent
            onClicked: contentView.state = "hidden"
        }
    }

    PlasmaCore.IconItem {
        id: closeButton

        width: units.gridUnit
        height: width
        source: "dialog-close"

        anchors {
            right: parent.right
            top: parent.top
            margins: units.gridUnit
        }
        MouseArea {
            anchors.fill: parent
            onClicked: contentView.state = "hidden"
        }
    }

    states: [
        State {
            name: "hidden"
            //PropertyChanges { target: currentWebView; visible: true}
        },
        State {
            name: "history"
            PropertyChanges { target: contentView; title: i18n("History")}
            PropertyChanges { target: contentViewLoader; source: "History.qml"}

        },
        State {
            name: "bookmarks"
            PropertyChanges { target: contentViewLoader; source: "Bookmarks.qml"}
            PropertyChanges { target: contentView; title: i18n("Bookmarks")}
        },
        State {
            name: "tabs"
            PropertyChanges { target: contentView; title: i18n("Tabs")}
            PropertyChanges { target: contentViewLoader; source: "Tabs.qml"}
            //PropertyChanges { target: currentWebView; visible: false}
        },
        State {
            name: "settings"
            PropertyChanges { target: contentView; title: i18n("Settings")}
            PropertyChanges { target: contentViewLoader; source: "Settings.qml"}
        }
    ]

}
