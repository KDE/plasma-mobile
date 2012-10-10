/*
 *   Copyright 2011 Marco Martin <notmart@gmail.com>
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

import QtQuick 1.0
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Item {
    id: root

    width: 800
    height: 480

    property alias title: titleLabel.text
    property alias content: contentItem.children
    property int status: PlasmaComponents.DialogStatus.Closed
    property alias acceptButtonText: acceptButton.text
    property alias rejectButtonText: rejectButton.text
    property alias acceptButton: acceptButton
    property alias rejectButton: rejectButton
    property Item visualParent

    signal accepted
    signal rejected

    function reject()
    {
        close()
        rejected()
    }

    function accept()
    {
        close()
        accepted()
    }

    visible: status != PlasmaComponents.DialogStatus.Closed;

    function open()
    {
        if (visualParent) {
            parent = visualParent
        } else {
            var next = parent;
            while (next && next.parent) {
                next = next.parent
            }

            parent = next
        }

        delayOpenTimer.restart()
    }

    function close()
    {
        sheet.state = "closed"
    }

    Timer {
        id: delayOpenTimer
        running: false
        interval: 0
        onTriggered: sheet.state = ""
    }


    Rectangle {
        id: fader
        property double alpha: 0
        color: Qt.rgba(0.0, 0.0, 0.0, alpha)
        anchors.fill: parent
    }


    MouseArea {
        anchors.fill: parent
        onClicked: reject()
    }

    PlasmaCore.FrameSvgItem {
        id: sheet

        state: "closed"
        imagePath: "dialogs/background"
        enabledBorders: "LeftBorder|TopBorder|RightBorder"

        anchors {
            fill: parent
            leftMargin: 50
            rightMargin: 50
            topMargin: 50
        }
        transform: Translate {
            id: sheetTransform
            y: height
        }

        MouseArea {
            anchors.fill: parent
            //eat mouse events to mot trigger the sheet hide
            onPressed: mouse.accepted = true
            onClicked: {
                sheet.forceActiveFocus()
                focus = false
            }
        }

        PlasmaCore.FrameSvgItem {
            id: titleFrame
            imagePath: "widgets/extender-dragger"
            prefix: "root"

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: parent.margins.left
                rightMargin: parent.margins.right
                topMargin: parent.margins.top
            }

            //FIXME: +5 because of Plasma::Dialog margins
            height: Math.max(titleLabel.paintedHeight, acceptButton.height) + margins.top + margins.bottom

            Item {
                id: titleLayoutHelper

                anchors {
                    right: parent.right
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    leftMargin: parent.margins.left
                    rightMargin: parent.margins.right
                    topMargin: parent.margins.top
                    bottomMargin: parent.margins.bottom
                }

                PlasmaComponents.Button {
                    id: acceptButton
                    onClicked: accept()
                    visible: text !== ""
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }
                }
                PlasmaComponents.Label {
                    id: titleLabel
                    elide: Text.ElideRight
                    height: paintedHeight
                    font.pointSize: theme.defaultFont.pointSize * 1.1
                    font.weight: Font.Bold
                    style: Text.Raised
                    styleColor: Qt.rgba(1,1,1,0.8)
                    anchors {
                        left: acceptButton.visible ? acceptButton.right : parent.left
                        //still depends from acceptButton to make text more centered
                        right: acceptButton.visible ? rejectButton.left : parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                PlasmaComponents.Button {
                    id: rejectButton
                    onClicked: reject()
                    visible: text !== ""
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        Item {
            id: contentItem
            anchors {
                top: titleFrame.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                leftMargin: sheet.margins.left
                rightMargin: sheet.margins.right
                topMargin: theme.defaultFont.mSize.height*0.6
                bottomMargin: theme.defaultFont.mSize.height*0.6
            }
        }



        states: [
            State {
                name: "closed"
                PropertyChanges {
                    target: sheetTransform
                    y: height
                }
                PropertyChanges {
                    target: fader
                    alpha: 0
                }
            },
            State {
                name: ""
                PropertyChanges {
                    target: sheetTransform
                    y: 0
                }
                PropertyChanges {
                    target: fader
                    alpha: 0.6
                }
            }
        ]

        transitions: [
            // Transition between open and closed states.
            Transition {
                from: ""
                to: "closed"
                reversible: false
                SequentialAnimation {
                    ScriptAction {
                        script: root.status = PlasmaComponents.DialogStatus.Closing
                    }
                    PropertyAnimation {
                        properties: "y, alpha"
                        easing.type: Easing.InOutQuad
                        duration: 250
                    }
                    ScriptAction {
                        script: root.status = PlasmaComponents.DialogStatus.Closed
                    }
                }
            },
            Transition {
                from: "closed"
                to: ""
                reversible: false
                SequentialAnimation {
                    ScriptAction {
                        script: root.status = PlasmaComponents.DialogStatus.Opening
                    }
                    PropertyAnimation {
                        properties: "y, alpha"
                        easing.type: Easing.InOutQuad
                        duration: 250
                    }
                    ScriptAction {
                        script: root.status = PlasmaComponents.DialogStatus.Open
                    }
                }
            }
        ]
    }
}
