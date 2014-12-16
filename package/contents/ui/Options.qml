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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras


PlasmaCore.FrameSvgItem {
    id: options

    imagePath: "widgets/background"

    state: "hidden"
    //state: "bookmarks"

    property string title: ""

    property int expandedHeight: units.gridUnit * 14
    property int expandedWidth: units.gridUnit * 20

    Behavior on height { NumberAnimation { duration: units.longDuration/2; easing.type: Easing.InOutQuad} }
    Behavior on opacity { NumberAnimation { duration: units.longDuration/2; easing.type: Easing.InOutQuad} }
    Behavior on x { NumberAnimation { duration: units.longDuration/2; easing.type: Easing.InOutQuad} }

    //height: expandedHeight
    height: childrenRect.height + options.margins.top + options.margins.bottom + units.gridUnit
    width: childrenRect.width + options.margins.left + options.margins.right + units.gridUnit/2

    //width: expandedWidth
    anchors.rightMargin: -options.margins.right
    //Rectangle { anchors.fill: parent; color: theme.backgroundColor; }

    ColumnLayout {

        visible: parent.height > 0
        spacing: units.gridUnit
        x: units.gridUnit
        y: units.gridUnit
        anchors {
            //fill: parent
            margins: units.gridUnit / 2
        }
        MouseArea {
            anchors.fill: parent
        }

        OptionsOverview {
            Layout.fillWidth: true;
        }
        Loader {
            id: loader
            Layout.fillHeight: true
            Layout.fillWidth: true
            //Rectangle { anchors.fill: parent; color: "black"; opacity: 0.1; }
        }
    }
//     NumberAnimation on state {
//         //loops: Animation.Infinite
//         from: state == "hidden" ? 0 : 1.0
//         to: state == "hidden" ? 1.0 : 0.0
//     }
    states: [
        State {
            name: "hidden"
            PropertyChanges { target: options; opacity: 0.0}
            PropertyChanges { target: options; x: webBrowser.width}
        },
        State {
            name: "overview"
            PropertyChanges { target: options; title: ""}
            //PropertyChanges { target: options; height: units.gridUnit * 3}
            PropertyChanges { target: options; opacity: 1.0}
            PropertyChanges { target: options; x: webBrowser.width - expandedWidth + options.margins.right + units.gridUnit * 2}

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
