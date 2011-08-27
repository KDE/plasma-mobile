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
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.qtextracomponents 0.1

Item {
    id: container
    objectName: "urlInput"

    property string filteredUrl: ""
    property alias image: bg.source
    property alias url: urlText.text

    signal urlEntered(string url)
    signal urlChanged

    width: parent.height
    height: urlText.height

    BorderImage {
        id: bg; rotation: 180
        x: 8; width: parent.width - 16; height: 30;
        anchors.verticalCenter: parent.verticalCenter
        border { left: 10; top: 10; right: 10; bottom: 10 }
    }

    PlasmaWidgets.LineEdit {
        id: urlText
        //horizontalAlignment: TextEdit.AlignLeft
        font.pixelSize: 14;

        onTextChanged: {
            container.urlChanged();
            print("XXX text changed" + text);
            if (text == "http://community.kde.org/Plasma/Active") {
                //completionPopup.visible = true;
                completionPopup.state = "expanded"
            } else {
                //completionPopup.visible = false;
                completionPopup.state = "collapsed"
            }
        }

        onReturnPressed: {
            container.urlEntered(urlText.text)
            webView.focus = true
        }

        Keys.onEscapePressed: {
            urlText.text = webView.url
            webView.focus = true
        }

        Keys.onEnterPressed: {
            container.urlEntered(urlText.text)
            webView.focus = true
        }

        Keys.onReturnPressed: {
            container.urlEntered(urlText.text)
            webView.focus = true
        }

        /*
        onFocusInEvent: {
            print("Print focus: " + focus);
        }
        */
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: 8
            rightMargin: 8
        }
    }

    CompletionPopup {
        id: completionPopup
        height: 200
        state: "collapsed"
        anchors.top: urlText.bottom
        anchors.left: urlText.left
        anchors.right: urlText.right
    }

    QIconItem {
        id: clearButton
        icon: QIcon("edit-clear-locationbar-rtl")
        MouseArea {
            anchors.fill: parent
            onClicked: {
                urlText.text = ""
            }
        }
        width: 48
        height: 48
        opacity: urlText.text == "" ?0: 1
        anchors {
            right: urlText.right
            rightMargin: -8
            verticalCenter: urlText.verticalCenter
            verticalCenterOffset: -2
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
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

}
