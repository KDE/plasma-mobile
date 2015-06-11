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
import QtQuick.Window 2.2
import org.kde.plasma.core 2.0 as PlasmaCore

Window {
    id: window
    flags: Qt.WindowDoesNotAcceptFocus

    property int offset: 0
    property int overShoot: units.gridUnit * 2

    color: "transparent"
    property alias contents: contentArea.data

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
        y: 0
        width: window.width
        height: window.height - y
        clip: true
        state: "closed"
        drag.filterChildren: true

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
            var factor = (mouse.y - oldMouseY > 0) ? (1 - Math.max(0, (slidingArea.y + overShoot) / overShoot)) : 1

            window.offset = window.offset + (mouse.y - oldMouseY) * factor;
            oldMouseY = mouse.y;
        }
        onReleased: {
            if (Math.abs(window.offset - mouseArea.startOffset) < units.gridUnit &&
                  slidingArea.y + slidingArea.height < mouse.y) {
                mouseArea.state = "closed";
            } else {
                window.updateState();
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.6-Math.abs(slidingArea.y/slidingArea.height))
        }
        PlasmaCore.ColorScope {
            id: slidingArea
            width: parent.width
            height: parent.height/1.5
            y: Math.min(0, -height + window.offset)
            colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
            Rectangle {
                anchors.fill: parent

                Item {
                    id: contentArea
                    anchors {
                        fill: parent
                        topMargin: overShoot
                    }
                }
                color: PlasmaCore.ColorScope.backgroundColor

                Rectangle {
                    height: units.gridUnit
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.bottom
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
            }
        }
        //FIXME: this empty mousearea is a workaround on https://bugreports.qt.io/browse/QTBUG-46545
        MouseArea {
            z: -1
            anchors.fill: parent
            onClicked: {
                mouseArea.state = "closed";
                window.visible = false;
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
                    offset: slidingArea.height - overShoot
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
                        easing.type: Easing.InOutQuad
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
