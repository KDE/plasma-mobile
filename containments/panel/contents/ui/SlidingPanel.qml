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
import org.kde.plasma.mobilecomponents 0.2
import org.kde.plasma.private.mobileshell 2.0

FullScreenPanel {
    id: window

    property int offset: 0
    property int peekHeight

    color: "transparent"
    property alias contents: contentArea.data

    width: Screen.width
    height: Screen.height

    property alias fixedArea: fixedArea
    function open() {
        window.visible = true;
        openAnim.running = true;
    }
    function close() {
        closeAnim.running = true;
    }
    function updateState() {
        if (offset < peekHeight / 2) {
            close();
        } else if (offset < peekHeight) {
            open();
        }
    }

    onVisibleChanged: {
        if (visible) {
            window.width = Screen.width;
            window.height = Screen.height;
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
        to: window.peekHeight
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6 * Math.min(1, offset/contentArea.height))
    }

    PlasmaCore.ColorScope {
        id: slidingArea
        anchors.fill: parent
        y: Math.min(0, -height + window.offset)
        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

        Rectangle {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: contentArea.height - mainFlickable.contentY
            color: PlasmaCore.ColorScope.backgroundColor
        }

        Flickable {
            id: mainFlickable
            anchors.fill: parent
            Binding {
                target: mainFlickable
                property: "contentY"
                value: -window.offset + contentArea.height
                when: !mainFlickable.moving && !mainFlickable.dragging && !mainFlickable.flicking
            }
            //no loop as those 2 values compute to exactly the same
            onContentYChanged: window.offset = -contentY + contentArea.height
            contentWidth: window.width
            contentHeight: window.height*2
            bottomMargin: window.height
            onMovementEnded: window.updateState();
            onFlickEnded: window.updateState();
            Item {
                width: window.width
                height: window.height*2
                Item {
                    id: contentArea
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    height: children[0].implicitHeight
                }
                Rectangle {
                    height: units.gridUnit
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: contentArea.bottom
                    }
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: Qt.rgba(0, 0, 0, 0.6)
                        }
                        GradientStop {
                            position: 0.5
                            color: Qt.rgba(0, 0, 0, 0.2)
                        }
                        GradientStop {
                            position: 1.0
                            color: "transparent"
                        }
                    }
                }
                MouseArea {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: contentArea.bottom
                    }
                    height: window.height
                    onClicked: window.close();
                }
            }
        }
        Item {
            id: fixedArea
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: childrenRect.height
        }
    }
}
