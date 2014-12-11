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

import QtQuick 2.1
import QtWebEngine 1.0
// import QtQuick.Controls 1.0
// import QtQuick.Controls.Styles 1.0
// import QtQuick.Layouts 1.0
import QtQuick.Window 2.1
//import QtQuick.Controls.Private 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
//import org.kde.plasma.components 2.0 as PlasmaComponents
//import org.kde.plasma.extras 2.0 as PlasmaExtras


Item {
    id: webBrowser
    objectName: "webBrowser"

    property Item currentWebView: webEngineView


    function load(url) {
        print("Loading url: " + url);
        currentWebView.url = url;
    }

    width: 1080 / 2
    height: (1920 / 2) - 96

    Navigation {
        id: navigation

        height: units.gridUnit * 3

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    WebEngineView {
        id: webEngineView

        focus: true

//         url: "http://lwn.net"
        url: "http://localhost"


        anchors {
            top: navigation.bottom
//             top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

//         anchors.fill: parent
        onLinkHovered: {
            if (hoveredUrl != "") {
                print("Hovered over: " + hoveredUrl);
                errorHandler.errorCode = "999";
            } else {
                errorHandler.errorCode = "";
            }
        }
    }

    ErrorHandler {
        id: errorHandler

        //errorCode: "999"

        //width: Math.min(webBrowser.width, units.gridUnit * 40)
        //height: Math.min(webBrowser.height, units.gridUnit * 6)

        anchors {
            top: navigation.bottom
            left: parent.left
            right: parent.right
        }
    }

}
