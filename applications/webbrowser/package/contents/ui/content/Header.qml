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
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1
import org.kde.plasma.components 0.1 as PlasmaComponents

PlasmaComponents.ToolBar {
    id: header

   // height: contents.height// + margins.bottom + 8
    property alias editUrl: urlInput.url
    property bool urlChanged: false


    PlasmaCore.Svg {
        id: toolbarIconsSvg
        imagePath: activeWebBrowserPackage.filePath("images", "toolbar-icons.svgz")
    }

    x: 0

    property int oldContentY: 0
    Connections {
        target: webView

        onProgressChanged: {
            if (webView.progress < 1.0) {
                header.y = 0;
            }
        }
        onContentYChanged: {
            if (webView.progress < 1.0) {
                header.y = 0;
            } else {
                header.y = Math.min(0, Math.max(header.y - (webView.contentY - oldContentY), - header.height))
            }
            oldContentY = webView.contentY
        }
    }
    tools: Column {
        id: contents
        width: parent.width

        Item {
            id: title
            width: parent.width; height: 20
            Text {
                anchors.centerIn: parent
                text: webView.title; font.pixelSize: 14; font.bold: true
                color: theme.textColor
                opacity: 0.7
                styleColor: theme.backgroundColor
                style: Text.Sunken
            }
        }

        Item {
            id: buttonRow
            width: parent.width
            height: leftButtonsRow.height

            Row {
                id: leftButtonsRow
                spacing: 8
                anchors {
                    left: parent.left
                    leftMargin: 8
                    verticalCenter: parent.verticalCenter
                }

                PlasmaComponents.ToolButton {
                    id: backButton
                    iconSource: "go-previous"
                    onClicked: webView.back.trigger()
                    width: theme.largeIconSize
                    height: width
                    flat: false
                    enabled: webView.back.enabled
                }
                PlasmaComponents.ToolButton {
                    id: nextButton
                    iconSource: "go-next"
                    onClicked: webView.forward.trigger()
                    width: theme.largeIconSize
                    height: width
                    flat: false
                    enabled: webView.forward.enabled
                }
            }

            UrlInput {
                id: urlInput
                anchors { 
                    left: leftButtonsRow.right
                    right: rightButtonsRow.left
                    verticalCenter: parent.verticalCenter
                }
                onUrlChanged: header.urlChanged = true
            }

            Row {
                id: rightButtonsRow
                spacing: 8
                anchors {
                    right: parent.right
                    rightMargin: 8
                    verticalCenter: parent.verticalCenter
                }

                PlasmaComponents.ToolButton {
                    id: reloadButton
                    iconSource: "view-refresh"
                    onClicked: webView.reload.trigger()
                    width: theme.largeIconSize
                    height: width
                    flat: false
                    visible: !stopButton.visible && (webView.url != "")
                }
                PlasmaComponents.ToolButton {
                    id: stopButton
                    iconSource: "process-stop"
                    onClicked: webView.stop.trigger()
                    width: theme.largeIconSize
                    height: width
                    flat: false
                    enabled: webView.stop.enabled
                    visible: !webView.reload.enabled
                }

                QIconItem {
                    id: goButton
                    icon: QIcon("go-jump-locationbar")
                    visible: true
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            urlInput.urlEntered(urlInput.url)
                            webBrowser.focus = true
                            header.urlChanged = false
                        }
                    }
                    width: theme.mediumIconSize
                    height: theme.mediumIconSize
                    opacity: header.urlChanged?1:0.3
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }
    }
}
