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
//import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
//import org.kde.plasma.extras 2.0 as PlasmaExtras


Item {
    id: errorHandler

    property string errorCode: ""

    property bool navigationShown: errorCode != "" || webBrowser.url == "" || true

    property int expandedHeight: units.gridUnit * 2.5
    property int buttonSize: units.gridUnit * 2

    Behavior on height { NumberAnimation { duration: units.longDuration; easing.type: Easing.InOutQuad} }

    Rectangle { anchors.fill: parent; color: theme.backgroundColor; }

    RowLayout {
        id: layout
        anchors.fill: parent
        visible: navigationShown

        spacing: units.smallSpacing / 2

        PlasmaComponents.ToolButton {
            id: backButton

            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            visible: currentWebView.canGoBack
            iconSource: "go-previous"
        }

        PlasmaComponents.ToolButton {
            id: forwardButton

            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            visible: currentWebView.canGoForward
            iconSource: "go-next"
        }

        PlasmaComponents.ToolButton {
            id: reloadButton

            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            iconSource: currentWebView.loading ? "process-stop" : "view-refresh"
        }

        PlasmaComponents.TextField {
            id: urlInput

            Layout.fillWidth: true

            text: currentWebView.url

            Keys.onReturnPressed: load(text)
        }

        Item {
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            visible: currentWebView.loading

            PlasmaComponents.BusyIndicator {
                width: buttonSize / 2
                height: width
                anchors.centerIn: parent
                running: currentWebView.loading
            }
        }
    }
    states: [
        State {
            name: "shown"
            when: navigationShown
            PropertyChanges { target: errorHandler; height: expandedHeight}
        },
        State {
            name: "hidden"
            when: !navigationShown
            PropertyChanges { target: errorHandler; height: 0}
        }
    ]

}
