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
import QtQuick.Window 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Window {
    id: window
    flags: Qt.WindowDoesNotAcceptFocus

    property int offset: 0

    color: "transparent"

    function updateState() {
        var delta = offset - mouseArea.startOffset;
        if (delta > units.gridUnit * 8) {
            mouseArea.state = "open";
        } else if (delta < -units.gridUnit * 8) {
            mouseArea.state = "closed";
        } else {
            mouseArea.state = mouseArea.startState;
        }
        mouseArea.startState = mouseArea.state;
    }

    onVisibleChanged: {
        if (visible) {
            mouseArea.state = "draggingFromClosed";
            mouseArea.startOffset = units.gridUnit * 4;
        }
    }

    MouseArea {
        id: mouseArea
        y: units.iconSizes.small
        width: window.width
        height: window.height - y
        clip: true
        state: "closed"

        property int oldMouseY: 0
        property int startOffset: units.iconSizes.large;
        property string startState: "closed"
        onPressed: {
            startState = state;
            startOffset = window.offset;
            oldMouseY = mouse.y;
            state = "draggingFromOpen";
            window.offset = startOffset;
        }
        onPositionChanged: {
            window.offset = window.offset + (mouse.y - oldMouseY);
            oldMouseY = mouse.y;
        }
        onReleased: window.updateState()

        Rectangle {
            id: slidingArea
            width: parent.width
            height: parent.height
            y: Math.min(0, -height + window.offset)

            color: Qt.rgba(0, 0, 0, 0.7)
            Rectangle {
                width: parent.width / 4
                height: units.gridUnit/2
                color: "yellow"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: units.gridUnit/2
                }
            }
        }

        states: [
            State {
                name: "closed"
                PropertyChanges {
                    target: window
                    offset: 0
                }
            },
            State {
                name: "open"
                PropertyChanges {
                    target: window
                    offset: slidingArea.height
                }
            },
            State {
                name: "draggingFromOpen"
            },
            State {
                name: "draggingFromClosed"
                PropertyChanges {
                    target: window
                    offset: units.gridUnit * 4
                }
            }
        ]

        transitions: [
            Transition {
                to: "draggingFromOpen"
            },
            Transition {
                SequentialAnimation {
                    PropertyAnimation {
                        target: window
                        duration: units.longDuration
                        easing: Easing.InOutQuad
                        properties: "offset"
                    }
                    ScriptAction {
                        script: {
                            if (mouseArea.state == "closed") {
                                window.visible = false;
                            }
                        }
                    }
                }
            }
        ]
    }
}
