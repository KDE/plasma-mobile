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

    //property debug


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

    Item {
        id: progressItem

        height: units.gridUnit / 2
        anchors {
            top: webEngineView.top
            left: webEngineView.left
            right: webEngineView.right
        }

        //opacity: currentWebView.loading ? 1.0 : 0
        Behavior on opacity { NumberAnimation { duration: units.shortDuration; easing.type: Easing.InOutQuad; } }

        Rectangle {
            color: theme.highlightColor

            width: Math.round((currentWebView.loadProgress / 100) * parent.width)
            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
            }
        }

    }

    WebEngineView {
        id: webEngineView

        focus: true

//         url: "http://lwn.net"
        url: "http://localhost"
        property string errorCode: ""
        property string errorString: ""


        anchors {
            top: navigation.bottom
//             top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        onLoadingChanged: { // Doesn't work!?!
            print("Loading: " + loading);
            print("    url: " + loadRequest.url)


            /* Handle
             *  - WebEngineView::LoadStartedStatus,
             *  - WebEngineView::LoadStoppedStatus,
             *  - WebEngineView::LoadSucceededStatus and
             *  - WebEngineView::LoadFailedStatus
             */
            var ec = "";
            var es = "";
            if (loadRequest.status == WebEngineView.LoadSucceededStatus) {

            }
            if (loadRequest.status == WebEngineView.LoadFailedStatus) {
                print("Load failed: " + loadRequest.errorCode);
                ec = loadRequest.errorCode;
                es = loadRequest.errorString;
            }
            errorCode = ec;
            errorString = es;
        }

        //onLoadProgressChanged: print("Progress: " + loadProgress);

        /*
        onLinkHovered: {
            if (hoveredUrl != "") {
                print("Hovered over: " + hoveredUrl + " " + (typeof(hoveredTitle) != "undefined" ? hoveredTitle : "(no title)"));
                //errorHandler.errorCode = "999";
            } else {
                //errorHandler.errorCode = "";
            }
        }
        */
    }

    ErrorHandler {
        id: errorHandler

        errorCode: currentWebView.errorCode
        errorString: currentWebView.errorString

        //width: Math.min(webBrowser.width, units.gridUnit * 40)
        //height: Math.min(webBrowser.height, units.gridUnit * 6)

        anchors {
            top: navigation.bottom
            left: parent.left
            right: parent.right
        }
    }

}
