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
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras


Item {
    id: errorHandler

    property string errorCode: ""
    property alias errorString: errorDescription.text

    property int expandedHeight: units.gridUnit * 8

    Behavior on height { NumberAnimation { duration: units.longDuration; easing.type: Easing.InOutQuad} }

    Rectangle { anchors.fill: parent; color: theme.backgroundColor; }

    ColumnLayout {

        visible: parent.height > 0
        spacing: units.gridUnit
        anchors {
            fill: parent
            margins: units.gridUnit
        }
        PlasmaExtras.Heading {
            level: 3
            Layout.fillHeight: false
            text: i18n("Error loading the page")
        }
        PlasmaComponents.Label {
            id: errorDescription
            Layout.fillHeight: false
        }
        Item {
            Layout.fillHeight: true
        }
    }

    PlasmaComponents.Label {
        font.pixelSize: Math.round(parent.height / 3)
        opacity: 0.3
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: units.gridUnit
        }
        text: errorCode
    }

    states: [
        State {
            name: "error"
            when: errorCode != ""
            PropertyChanges { target: errorHandler; height: expandedHeight}
        },
        State {
            name: "normal"
            when: errorCode == ""
            PropertyChanges { target: errorHandler; height: 0}
        }
    ]

}
