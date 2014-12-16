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

    property int borderWidth: Math.round(units.gridUnit / 18);
    property var borderColor: theme.highlightColor;

    function load(url) {
        //print("Loading url: " + url);
        currentWebView.url = url;
    }

    width: 1080 / 2
    height: (1920 / 2) - 96

//     BrowserManager {
//         id: browserManager
//     }
//
    WebEngineView {
        id: webEngineView

        focus: true

//         url: "http://lwn.net"
        url: "http://localhost"
        property string errorCode: ""
        property string errorString: ""

        property var pageInfo


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
            print("   icon: " + webEngineView.icon)
            print("  title: " + webEngineView.title)

            /* Handle
             *  - WebEngineView::LoadStartedStatus,
             *  - WebEngineView::LoadStoppedStatus,
             *  - WebEngineView::LoadSucceededStatus and
             *  - WebEngineView::LoadFailedStatus
             */
            var ec = "";
            var es = "";
            //print("Load: " + loadRequest.errorCode + " " + loadRequest.errorString);
            if (loadRequest.status == WebEngineView.LoadSucceededStatus) {
                // record history, set current page info
                //contentView.state = "hidden"
                pageInfo.url = webEngineView.url;
                pageInfo.title = webEngineView.title;
                pageInfo.icon = webEngineView.icon;

            }
            if (loadRequest.status == WebEngineView.LoadFailedStatus) {
                print("Load failed: " + loadRequest.errorCode + " " + loadRequest.errorString);
                ec = loadRequest.errorCode;
                es = loadRequest.errorString;
            }
            errorCode = ec;
            errorString = es;
        }

        onLoadProgressChanged: {
            if (loadProgress > 50) {
                contentView.state = "hidden";
            }
        }

        //print("Progress: " + loadProgress);

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

    ContentView {
        id: contentView
        //opacity: state == "hidden"
        anchors.fill: webEngineView
        //z: webEngineView.z + 999
    }

    Item {
        id: progressItem

        height: Math.round(units.gridUnit / 4)

        anchors {
            top: webEngineView.top
            left: webEngineView.left
            right: webEngineView.right
        }

        opacity: currentWebView.loading ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: units.longDuration; easing.type: Easing.InOutQuad; } }

        Rectangle {
            color: theme.highlightColor

            width: Math.round((currentWebView.loadProgress / 100) * parent.width)
            /*
            Connections {
                target: currentWebView
                onLoadProgressChanged: {
                    var w = Math.round((currentWebView.loadProgress / 100) * parent.width);
                    print("Progress " + currentWebView.loadProgress + " width: " + w);
                }
            }
            */
            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
            }
        }

    }

    ErrorHandler {
        id: errorHandler

        errorCode: currentWebView.errorCode
        errorString: currentWebView.errorString

        anchors {
            top: navigation.bottom
            left: parent.left
            right: parent.right
        }
    }

    MouseArea {
        id: optionsDismisser
        visible: options.state != "hidden"
        onClicked: options.state = "hidden"
        anchors.fill: parent
    }

    Options {
        id: options

        //expandedHeight: Math.round(parent.height * 0.7)
        //expandedWidth: Math.min(parent.width - units.gridUnit * 2, units.gridUnit * 20)

        anchors {
            top: navigation.bottom
            //right: parent.right
        }
    }

    Navigation {
        id: navigation

        height: units.gridUnit * 3

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }
    Rectangle {
        height: webBrowser.borderWidth
        color: webBrowser.borderColor
        anchors {
            left: parent.left
            bottom: navigation.bottom
            right: options.left
        }
    }

    //Component.onCompleted: bookmarksManager.reload();
}
