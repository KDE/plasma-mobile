/****************************************************************************
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the QtDeclarative module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** No Commercial Usage
** This file contains pre-release code and may not be distributed.
** You may use this file in accordance with the terms and conditions
** contained in the Technology Preview License Agreement accompanying
** this package.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Nokia gives you certain additional
** rights.  These rights are described in the Nokia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** If you have questions regarding the use of this file, please contact
** Nokia at qt-info@nokia.com.
**
**
**
**
**
**
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 1.0
import org.kde.kdewebkit 0.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

import "content"

Rectangle {
    id: webBrowser
    objectName: "webBrowser"

    property string urlString : ""
    property alias url: webView.url
    property alias title: webView.title

    width: 800; height: 600
    color: theme.backgroundColor

    PlasmaCore.Theme {
        id: theme
    }

    MobileComponents.Package {
        id: activeWebBrowserPackage
        name: "org.kde.active.webbrowser"
    }

    PlasmaExtras.ResourceInstance {
        id: resourceInstance
        uri: webBrowser.url
        mimetype: "text/x-html"
        title: webView.title
    }

    //FIXME: this will have to be removed
    Timer {
        interval: 100
        running: true
        onTriggered: backConnection.target = application.action("back")
    }
    Connections {
        id: backConnection
        target: application.action("back")
        onTriggered: webView.back.trigger()
    }

    FlickableWebView {
        id: webView
        objectName: "webView"
        url: webBrowser.urlString
        onProgressChanged: header.urlChanged = false
        anchors {
            top: headerSpace.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: -4
        }
    }

    Item { id: headerSpace; width: parent.width; height: header.height }

    Header {
        id: header
        editUrl: webBrowser.urlString
        width: headerSpace.width
        //height: headerSpace.height
    }
/*
    CompletionPopup {
        id: completionPopup
        property double relativeSize: 0.9
        width: (webBrowser.width * relativeSize)
        height: (webBrowser.height * relativeSize)
        x: (webBrowser.width * (1.0-relativeSize) / 2)
        y: (webBrowser.height * (1.0-relativeSize) / 2)
        state: "collapsed"
        //anchors.centerIn: webBrowser.
        //anchors.top: urlText.bottom
        //anchors.left: urlText.left
        //anchors.right: urlText.right

        Component.onCompleted: {
            print( " size :   " + relativeSize);
            print("   width:  " +( webBrowser.width * relativeSize));
            print("   height: " + (webBrowser.height * relativeSize));
            print("   x:    : " + (webBrowser.width * (1.0-relativeSize) / 2));
            print("   y:    : " + (webBrowser.height * (1.0-relativeSize) / 2));
        }
    }
*/

    ScrollBar {
        scrollArea: webView; width: 8
        anchors { right: parent.right; top: header.bottom; bottom: parent.bottom }
    }

    ScrollBar {
        scrollArea: webView; height: 8; orientation: Qt.Horizontal
        anchors { right: parent.right; rightMargin: 8; left: parent.left; bottom: parent.bottom }
    }

    function loadUrl(filteredUrl) {
        webBrowser.urlString = filteredUrl
        webBrowser.focus = true
        header.urlChanged = false
    }

    Component.onCompleted: {
        if (typeof startupArguments[0] != "undefined") {
            urlString = startupArguments[0];
        } else {
            //urlString = "http://plasma.kde.org";
        }
    }
}
