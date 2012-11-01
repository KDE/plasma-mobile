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

import QtQuick 1.1
import org.kde.kdewebkit 0.1
import org.kde.plasma.components 0.1 as PlasmaComponents
import "LinkPopup.js" as LinkPopupHelper
import org.kde.qtextracomponents 0.1

MouseEventListener {
    id: flickable
    width: parent.width

    anchors.top: headerSpace.bottom
    anchors.bottom: parent.top
    anchors.left: parent.left
    anchors.right: parent.right

    property alias title: webView.title
    property alias icon: webView.icon
    property alias progress: webView.progress
    property alias url: webView.url
    property alias rssFeeds: webView.rssFeeds
    property alias back: webView.back
    property alias stop: webView.stop
    property alias reload: webView.reload
    property alias forward: webView.forward
    property bool interactiveSuspended: false
    property bool interactive: (webView.contentsSize.height > webView.height || webView.contentsSize.width > webView.width) && !interactiveSuspended

    signal newWindowRequested(string url)

    property real horizontalVelocity
    property real verticalVelocity
    onPressed: {
        if (!interactive) {
            return
        }
        scrollAnim.running = false
        speedSampleTimer.running = true
    }

    onReleased: {
        if (!interactive) {
            movingHorizontally = false
            movingVertically = false
            return
        }
        speedSampleTimer.running = false

        if (!movingHorizontally && !movingVertically) {
            return
        }

        if (webView.contentsSize.width > webView.width) {
            scrollAnimX.to = Math.min(Math.max(0, contentX + horizontalVelocity*4), webView.contentsSize.width - flickable.width)
        } else {
            scrollAnimX.to = contentX
        }
        if (webView.contentsSize.height > webView.height) {
            scrollAnimY.to = Math.min(Math.max(0, contentY + verticalVelocity*4), webView.contentsSize.height - flickable.height)
        } else {
            scrollAnimY.to = contentY
        }

        scrollAnim.running = true
    }
    property bool movingHorizontally: false
    property bool movingVertically: false
    property alias contentX: webView.contentX
    property alias contentY: webView.contentY
    property int lastContentY: 0
    property int lastContentX: 0
    property alias overShootX: webView.overShootX
    property alias overShootY: webView.overShootY
    property int contentWidth: webView.contentsSize.width
    property int contentHeight: webView.contentsSize.height
    property bool atXBeginning: contentX <= 0
    property bool atXEnd: contentX >= contentWidth - webView.width
    property bool atYBeginning: contentY <= 0
    property bool atYEnd: contentY >= contentHeight - webView.height
    property QtObject visibleArea: QtObject {
        property real yPosition: flickable.contentY / contentHeight
        property real xPosition: flickable.contentX / contentWidth
        property real heightRatio: webView.height / contentHeight
        property real widthRatio: webView.width / contentWidth
    }

    onContentXChanged: {
        movingHorizontally = true
        movingTimer.restart()
    }
    onContentYChanged: {
        movingVertically = true
        movingTimer.restart()
    }
    Timer {
        id: movingTimer
        interval: 500
        onTriggered: {
            flickable.movingHorizontally = false
            flickable.movingVertically = false
        }
    }

    Timer {
        id: speedSampleTimer
        repeat: true
        interval: 250
        onRunningChanged: {
            if (running) {
                flickable.lastContentY = flickable.contentY
                horizontalVelocity = verticalVelocity = 0
            } else {
                horizontalVelocity = flickable.contentX - flickable.lastContentX
                flickable.lastContentX = flickable.contentX
                verticalVelocity = flickable.contentY - flickable.lastContentY
                flickable.lastContentY = flickable.contentY
            }
        }
        onTriggered: {
            horizontalVelocity = flickable.contentX - flickable.lastContentX
            flickable.lastContentX = flickable.contentX
            verticalVelocity = flickable.contentY - flickable.lastContentY
            flickable.lastContentY = flickable.contentY
        }
    }

    SequentialAnimation {
        id: scrollAnim
        ParallelAnimation {
            NumberAnimation {
                id: scrollAnimX
                target: flickable
                property: "contentX"
                easing.type: Easing.OutQuad
                duration: 500
            }
            NumberAnimation {
                id: scrollAnimY
                target: flickable
                property: "contentY"
                easing.type: Easing.OutQuad
                duration: 500
            }
        }
        ScriptAction {
            script: {
                movingHorizontally = false
                movingVertically = false
            }
        }
    }
    //pressDelay: 200

    onWidthChanged : {
        // Expand (but not above 1:1) if otherwise would be smaller that available width.
        if (width > webView.width*webView.contentsScale && webView.contentsScale < 1.0)
            webView.contentsScale = width / webView.width;
    }


    PinchArea {
        id: pinchArea
        width:webView.width
        height: webView.height
        property real startScale
        property real startY
        property real startX
        onPinchStarted: {
            startScale = webView.contentsScale
            webView.renderingEnabled = false
            flickable.smooth = false
            startY = pinch.center.y
            startX = pinch.center.x
        }
        onPinchUpdated: {
            webView.contentsScale = startScale * pinch.scale

            flickable.contentY += pinch.previousCenter.y - pinch.center.y + startY * (pinch.scale - pinch.previousScale)

            flickable.contentX += pinch.previousCenter.x - pinch.center.x + startX * (pinch.scale - pinch.previousScale)
        }
        onPinchFinished: {
            webView.renderingEnabled = true
            flickable.smooth = true
        }

        WebView {
            id: webView
            objectName: "webViewImplementation"
            transformOrigin: Item.TopLeft
            //settings.pluginsEnabled: true
            settings {
                localStorageDatabaseEnabled: true
                offlineStorageDatabaseEnabled: true
                offlineWebApplicationCacheEnabled: true
            }


            pressGrabTime: flickable.interactive ? 400 : 0

            x: 0

            y: Math.max(-headerSpace.height, -flickable.contentY)
            width: flickable.width
            height: flickable.height + headerSpace.height + Math.min(0, flickable.contentHeight - flickable.contentY - flickable.height)


            flickingEnabled: !flickable.interactive

            //FIXME: glorious hack just to obtain a signal of the url of the new requested page
            // Should be replaced with signal from KDeclarativeWebView
            newWindowComponent: Component {
                Item {
                    id: newPageComponent

                    WebView {
                        id: newWindow
                        onUrlChanged: {
                            if (url != "") {
                                flickable.newWindowRequested(url)

                                var newObject = Qt.createQmlObject('import QtQuick 1.0; Item {}', webView);
                                newPageComponent.parent = newObject
                                newObject.destroy()
                            }
                        }
                    }
                }
            }

            newWindowParent: webView

            function fixUrl(url)
            {
                if (url == "") return url
                if (url[0] == "/") return "file://"+url
                if (url.indexOf(":")<0) {
                    if (url.indexOf(".")<0 || url.indexOf(" ")>=0) {
                        // Fall back to a search engine; hard-code Wikipedia
                        return "http://en.wikipedia.org/w/index.php?search="+url
                    } else {
                        return "http://"+url
                    }
                }
                return url
            }

            url: fixUrl(webBrowser.urlString)
            smooth: false // We don't want smooth scaling, since we only scale during (fast) transitions
            focus: true
            clip: false

            onAlert: {
                console.log(message);
                alertDialog.text = message;
                alertDialog.open();
            }

            function doZoom(zoom,centerX,centerY)
            {
                if (centerX) {
                    var sc = zoom*contentsScale;
                    scaleAnim.to = sc;
                    flickVX.from = flickable.contentX
                    flickVX.to = Math.max(0,Math.min(centerX-flickable.width/2,webView.width*sc-flickable.width))
                    finalX.value = flickVX.to
                    flickVY.from = flickable.contentY
                    flickVY.to = Math.max(0,Math.min(centerY-flickable.height/2,webView.height*sc-flickable.height))
                    finalY.value = flickVY.to
                    quickZoom.start()
                }
            }

            function handleLinkPressed(linkUrl, linkRect)
            {
                print("link pressed: " + linkUrl + " | " + linkRect.x + " " + linkRect.y + " " + linkRect.width + " " + linkRect.height);
    //            flickable.interactiveSuspended = true;
    //             highlightRect.x = linkRect.x;
    //             highlightRect.y = linkRect.y;
    //             highlightRect.width = linkRect.width;
    //             highlightRect.height = linkRect.height;
            }

            function handleLinkPressAndHold(linkUrl, linkRect)
            {
    //            print("... and hold: " + linkUrl + " | " + linkRect.x + " " + linkRect.y + " " + linkRect.width + " " + linkRect.height);
                linkPopupLoader.source = "LinkPopup.qml";
                if (linkPopupLoader.status == Loader.Ready) {
                    flickable.interactiveSuspended = true;
                    highlightRect.x = linkRect.x;
                    highlightRect.y = linkRect.y;
                    highlightRect.width = linkRect.width;
                    highlightRect.height = linkRect.height;

                    var linkPopup = linkPopupLoader.item;
                    linkPopup.url = linkUrl
                    linkPopup.linkRect.x = linkRect.x
                    linkPopup.linkRect.y = linkRect.y
                    linkPopup.linkRect.width = linkRect.width
                    linkPopup.linkRect.height = linkRect.height
                    linkPopup.state  = "expanded";
                    //print(" type: " + typeof(linkRect));
                }
            }

            Rectangle {
                id: highlightRect
                color: theme.highlightColor
                opacity: 0.2
                visible: (linkPopupLoader.source != "" && linkPopupLoader.item.state == "expanded")
            }

            Loader { id: linkPopupLoader }

            Keys.onLeftPressed: webView.contentsScale -= 0.1
            Keys.onRightPressed: webView.contentsScale += 0.1

            preferredWidth: flickable.width
            preferredHeight: flickable.height
            contentsScale: 1

            onUrlChanged: {
                // got to topleft
                if (url != null) {
                    header.editUrl = url.toString();
                }
                //settings.pluginsEnabled = true;
                print(" XXX Plugins on? " + settings.pluginsEnabled);
            }
            onTitleChanged: {
                //print("title changed in flickable " + title);
                webBrowser.titleChanged();
            }
            onDoubleClick: {
                preferredWidth = flickable.width - 50;
                if (!heuristicZoom(clickX,clickY,2.0)) {
                    var zf = flickable.width / contentsSize.width
                    if (zf >= contentsScale)
                        zf = 2.0*contentsScale // zoom in (else zooming out)
                    doZoom(zf,clickX*zf,clickY*zf)
                }
            }

            Item {
                x: 1 + webView.overShootX
                y: 1 + webView.overShootY
                width: parent.width - 2
                height: parent.height - 2

                Image {
                    source: "image://appbackgrounds/shadow-left"
                    fillMode: Image.TileVertically
                    anchors {
                        top: parent.top
                        right: parent.left
                        rightMargin: -1
                        bottom: parent.bottom
                        topMargin: 1
                        bottomMargin: 1
                    }
                }
                Image {
                    source: "image://appbackgrounds/shadow-top"
                    fillMode: Image.TileHorizontally
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottomMargin: -1
                        bottom: parent.top
                        leftMargin: 1
                        rightMargin: 1
                    }
                }
                Image {
                    source: "image://appbackgrounds/shadow-right"
                    fillMode: Image.TileVertically
                    anchors {
                        top: parent.top
                        left: parent.right
                        leftMargin: -1
                        bottom: parent.bottom
                        topMargin: 1
                        bottomMargin: 1
                    }
                }
                Image {
                    source: "image://appbackgrounds/shadow-bottom"
                    fillMode: Image.TileHorizontally
                    anchors {
                        left: parent.left
                        right: parent.right
                        topMargin: -1
                        top: parent.bottom
                        leftMargin: 1
                        rightMargin: 1
                    }
                }
                Image {
                    source: "image://appbackgrounds/shadow-topleft"
                    anchors {
                        right: parent.left
                        bottomMargin: -1
                        rightMargin: -1
                        bottom: parent.top
                    }
                }
                Image {
                    source: "image://appbackgrounds/shadow-topright"
                    anchors {
                        left: parent.right
                        bottomMargin: -1
                        leftMargin: -1
                        bottom: parent.top
                    }
                }
                Image {
                    source: "image://appbackgrounds/shadow-bottomleft"
                    anchors {
                        right: parent.left
                        topMargin: -1
                        rightMargin: -1
                        top: parent.bottom
                    }
                }
                Image {
                    source: "image://appbackgrounds/shadow-bottomright"
                    anchors {
                        left: parent.right
                        topMargin: -1
                        leftMargin: -1
                        top: parent.bottom
                    }
                }
            }

            SequentialAnimation {
                id: quickZoom

                PropertyAction {
                    target: webView
                    property: "renderingEnabled"
                    value: false
                }
                PropertyAction {
                    target: flickable
                    property: "smooth"
                    value: false
                }
                ParallelAnimation {
                    NumberAnimation {
                        id: scaleAnim
                        target: webView
                        property: "contentsScale"
                        // the to property is set before calling
                        easing.type: Easing.Linear
                        duration: 200
                    }
                    NumberAnimation {
                        id: flickVX
                        target: flickable
                        property: "contentX"
                        easing.type: Easing.Linear
                        duration: 200
                        from: 0 // set before calling
                        to: 0 // set before calling
                    }
                    NumberAnimation {
                        id: flickVY
                        target: flickable
                        property: "contentY"
                        easing.type: Easing.Linear
                        duration: 200
                        from: 0 // set before calling
                        to: 0 // set before calling
                    }
                }

                // Have to set the contentXY, since the above 2
                // size changes may have started a correction if
                // contentsScale < 1.0.
                PropertyAction {
                    id: finalX
                    target: flickable
                    property: "contentX"
                    value: 0 // set before calling
                }
                PropertyAction {
                    id: finalY
                    target: flickable
                    property: "contentY"
                    value: 0 // set before calling
                }
                PropertyAction {
                    target: webView
                    property: "renderingEnabled"
                    value: true
                }
                PropertyAction {
                    target: flickable
                    property: "smooth"
                    value: true
                }
            }
            onZoomTo: doZoom(zoom,centerX,centerY)
            onClick: {
                //print("fickable click");
                //if (linkPopupLoader.status == Loader.Ready) linkPopupLoader.item.state = "collapsed";
            }
            onLinkPressed: handleLinkPressed(linkUrl, linkRect)
            onLinkPressAndHold: handleLinkPressAndHold(linkUrl, linkRect)
        }
    }

    PlasmaComponents.CommonDialog {
        id: alertDialog
        titleText: i18n("JavaScript Alert")
        buttonTexts: [i18n("Close")]
        onButtonClicked: close()

        property alias text: alertLabel.text

        content: PlasmaComponents.Label {
            anchors.margins: 12
            id: alertLabel
        }
    }

    Component.onCompleted: {
        back.enabled = false
        forward.enabled = false
        reload.enabled = false
        stop.enabled = false
    }
}
