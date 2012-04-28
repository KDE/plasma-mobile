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
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.qtextracomponents 0.1

Item {
    id: container
    objectName: "urlInput"

    property string filteredUrl: ""
    property alias image: bg.source
    property alias url: urlText.text
    //property alias urlFocus: urlText.activeFocus
    //property alias completionPopup: webBrowser.completionPopup
    property string urlFilter

    signal urlEntered(string url)
    signal urlChanged
    signal urlFilterChanged()

    width: parent.height
    height: urlText.height

    BorderImage {
        id: bg; rotation: 180
        x: 8; width: parent.width - 16; height: 30;
        anchors.verticalCenter: parent.verticalCenter
        border { left: 10; top: 10; right: 10; bottom: 10 }
    }

    PlasmaComponents.TextField {
        id: urlText
        clearButtonShown: true
        z: 2
        //horizontalAlignment: TextEdit.AlignLeft
        //font.pixelSize: 14;

        function updateState() {
            if (text != webView.url) {
                completionPopup.state = "expanded"
            } else {
                completionPopup.state = "collapsed"
            }

        }

        onTextChanged: {
            container.urlChanged();
            if (text != webView.url) {
                urlFilter = text;
            } else {
                urlFilter = "";
            }
            urlFilterChanged();
        }


        Keys.onEscapePressed: {
            urlText.text = webView.url
            webView.focus = true
        }

        Keys.onEnterPressed: {
            container.urlEntered(urlText.text)
            webView.focus = true
            completionPopup.state = "collapsed"
            urlText.closeSoftwareInputPanel();
        }

        Keys.onReturnPressed: {
            container.urlEntered(urlText.text)
            webView.focus = true
            completionPopup.state = "collapsed"
            urlText.closeSoftwareInputPanel();
        }


        onActiveFocusChanged: {
            if (activeFocus) {
                completionPopup.state = "expanded"
            } else {
                //completionPopup.state = "collapsed"
            }
        }

        anchors {
            left: parent.left
            right: parent.right
            leftMargin: 8
            rightMargin: 8
        }

        Component.onCompleted: {
            focus = true;
        }
    }

    CompletionPopup {
        id: completionPopup
        state: "collapsed"
        property double relativeSize: 1.1
        property int overlap: 40
        x: -overlap
        y: 60
        width: urlText.width + overlap * 2
        height: webBrowser.height * 0.666
    }

    Rectangle {
        anchors.bottom: urlText.bottom
        x: urlText.x + 2
        height: 6
        radius: 4
        color: theme.highlightColor
        width: (bg.width - 20) * webView.progress
        opacity: webView.progress == 1.0 ? 0.0 : 0.7
        smooth: true
        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    }

    onFilteredUrlChanged: {
        // the entered URL has been filtered by KUriFilter, load the result
        loadUrl(filteredUrl);
    }

    Component.onCompleted: {
        if (urlText.text == "") {
            completionPopup.state = "expanded"
            container.urlChanged();
            urlFilter = "";
            urlText.text = "";
            urlFilterChanged();
            //print("Should load history...");
        }
    }

}
