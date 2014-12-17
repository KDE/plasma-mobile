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

import org.kde.plasma.core 2.0 as PlasmaCore


Item {
    id: webBrowser
    objectName: "webBrowser"

    //property Item currentWebView: tabs.currentIndex < tabs.count ? tabs.getTab(tabs.currentIndex).item : null
    property Item currentWebView: tabs.currentIndex < tabs.count ? tabs.currentItem : null

    onCurrentWebViewChanged: {
        print("Current WebView is now : " + tabs.currentIndex);
    }
    property int borderWidth: Math.round(units.gridUnit / 18);
    property var borderColor: theme.highlightColor;

    function load(url) {
        print("Loading url: " + url);
        currentWebView.url = url;
        //tabs.newTab(url)
    }

    width: 1080 / 2
    height: (1920 / 2) - 96

    function addHistoryEntry() {
        print("Adding history");
        var request = new Object;// FIXME
        request.url = currentWebView.url;
        request.title = currentWebView.title;
        request.icon = currentWebView.icon;
        browserManager.addToHistory(request);

    }

    Item {
        id: tabContainer
        anchors {
            top: navigation.bottom
            //top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        ListWebView {
            id: tabs
            //y: units.gridUnit * 5
            anchors.fill: parent
        }
    }

    ErrorHandler {
        id: errorHandler

        //errorCode: currentWebView.errorCode ? currentWebView.errorCode : ""
        //errorString: currentWebView.errorString ? currentWebView.errorString : ""
        errorString: currentWebView.errorString
        errorCode: currentWebView.errorCode

        anchors {
            top: navigation.bottom
            left: parent.left
            right: parent.right
        }
    }

    ContentView {
        id: contentView
        //opacity: state == "hidden"
        anchors.fill: tabContainer
        //z: webEngineView.z + 999
    }

    Item {
        id: progressItem

        height: Math.round(units.gridUnit / 4)

        anchors {
            top: tabContainer.top
            left: tabContainer.left
            right: tabContainer.right
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

    MouseArea {
        id: optionsDismisser
        visible: options.state != "hidden"
        onClicked: options.state = "hidden"
        anchors.fill: parent
    }

    Options {
        id: options

        anchors {
            top: navigation.bottom
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
