/***************************************************************************
 *                                                                         *
 *   Copyright 2014 Sebastian Kügler <sebas@kde.org>                       *
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
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras


Item {
    id: options

    //state: "hidden"
    state: "bookmarks"

    property string title: ""

    property int expandedHeight: units.gridUnit * 14

    Behavior on height { NumberAnimation { duration: units.longDuration/2; easing.type: Easing.InOutQuad} }

    Rectangle { anchors.fill: parent; color: theme.backgroundColor; }

    ColumnLayout {

        visible: parent.height > 0
        spacing: units.gridUnit
        anchors {
            fill: parent
            margins: units.gridUnit / 2
        }
        OptionsOverview {
            Layout.fillWidth: true;
        }
//         PlasmaExtras.Heading {
//             level: 3
//             Layout.fillHeight: false
//             text: options.title
//             Layout.maximumHeight: options.state == "overview" ? 0 : implicitHeight
//         }
        Loader {
            id: loader
            Layout.fillHeight: true
            Layout.fillWidth: true
            //Rectangle { anchors.fill: parent; color: "black"; opacity: 0.1; }
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges { target: options; height: 0}
        },
        State {
            name: "overview"
            PropertyChanges { target: options; title: ""}
            PropertyChanges { target: options; height: units.gridUnit * 3}

        },
        State {
            name: "bookmarks"
            PropertyChanges { target: loader; source: "Bookmarks.qml"}
            PropertyChanges { target: options; title: i18n("Bookmarks")}
            PropertyChanges { target: options; height: expandedHeight}
        },
        State {
            name: "tabs"
            PropertyChanges { target: options; title: i18n("Tabs")}
            PropertyChanges { target: loader; source: "Tabs.qml"}
            PropertyChanges { target: options; height: expandedHeight}
        },
        State {
            name: "settings"
            PropertyChanges { target: options; title: i18n("Settings")}
            PropertyChanges { target: loader; source: "Settings.qml"}
            PropertyChanges { target: options; height: expandedHeight}
        }
    ]

}
