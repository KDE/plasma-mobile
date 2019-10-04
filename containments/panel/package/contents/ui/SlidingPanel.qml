/*
 *   Copyright 2014 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell

NanoShell.FullScreenOverlay {
    id: window

    property int offset: 0
    property int openThreshold
    property bool userInteracting: false
    readonly property bool wideScreen: width > units.gridUnit * 45
    readonly property int drawerWidth: wideScreen ? units.gridUnit * 25 : width
    readonly property int drawerHeight: contentArea.height + headerHeight
    property int drawerX: 0

    color: Qt.rgba(0, 0, 0, 0.6 * Math.min(1, offset/drawerHeight))
    property alias contentItem: contentArea.contentItem
    property int headerHeight

    width: Screen.width
    height: Screen.height
    

    function open() {
        window.showFullScreen();
        open.running = true;
    }
    function close() {
        closeAnim.running = true;
    }
    function updateState() {
        print("SUKUNNU"+offset + " "+openThreshold)
        if (offset < openThreshold) {
            close();
        } else {
            openAnim.running = true;
        }
    }
    Timer {
        id: updateStateTimer
        interval: 0
        onTriggered: updateState()
    }
    onActiveChanged: {
        if (!active) {
            close();
        }
    }
    onVisibleChanged: {
        if (visible) {
            window.width = Screen.width;
            window.height = Screen.height;
            window.requestActivate();
        }
    }
    SequentialAnimation {
        id: closeAnim
        PropertyAnimation {
            target: window
            duration: units.longDuration
            easing.type: Easing.InOutQuad
            properties: "offset"
            from: window.offset
            to: 0
        }
        ScriptAction {
            script: {
                window.visible = false;
            }
        }
    }
    PropertyAnimation {
        id: openAnim
        target: window
        duration: units.longDuration
        easing.type: Easing.InOutQuad
        properties: "offset"
        from: window.offset
        to: drawerHeight
    }

    PlasmaCore.ColorScope {
        anchors.fill: parent

        Flickable {
            id: mainFlickable
            anchors.fill: parent
            Binding {
                target: mainFlickable
                property: "contentY"
                value: -window.offset + drawerHeight
                when: !mainFlickable.moving && !mainFlickable.dragging && !mainFlickable.flicking
            }
            //no loop as those 2 values compute to exactly the same
            onContentYChanged: {
                window.offset = -contentY + drawerHeight
              /*  if (contentY > drawerHeight) {
                    contentY = d;
                }*/
            }
            contentWidth: window.width
            contentHeight: window.height*2
            bottomMargin: window.height
            onMovementStarted: window.userInteracting = true;
            onFlickStarted: window.userInteracting = true;
            onMovementEnded: {
                window.userInteracting = false;
                window.updateState();
            }
            onFlickEnded: {
                window.userInteracting = true;
                window.updateState();
            }
            MouseArea {
                id: dismissArea
                width: parent.width
                height: mainFlickable.contentHeight
                onClicked: window.close();
                PlasmaComponents.Control {
                    id: contentArea
                    y: headerHeight
                    x: drawerX
                    width: drawerWidth
                }
            }
        }
    }
}
