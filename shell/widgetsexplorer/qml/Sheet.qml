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

    width: parent ? parent.width : 800
    height: parent ? parent.height : 480


    property alias title: titleLabel.text
    property alias content: contentItem.children
    property int status: PlasmaComponents.DialogStatus.Closed

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
        var next = parent;
        while (next && next.parent) {
            next = next.parent
        }

        parent = next

        sheet.state = ""
    }

    function close()
    {
        sheet.state = "closed"
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
            height: titleLabel.height + margins.top + margins.bottom
            PlasmaComponents.Label {
                id: titleLabel
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                font.pointSize: theme.defaultFont.pointSize * 1.3
                font.weight: Font.Bold
                style: Text.Raised
                styleColor: Qt.rgba(1,1,1,0.8)
                height: paintedHeight
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    topMargin: parent.margins.top
                    leftMargin: height + 2
                    rightMargin: height + 2
                }
            }
        }
        Item {
            id: contentItem
            anchors {
                top: titleFrame.bottom
                bottom: buttonsRow.top
                left: parent.left
                right: parent.right
                leftMargin: sheet.margins.left
                rightMargin: sheet.margins.right
                topMargin: theme.defaultFont.mSize.height*0.6
                bottomMargin: theme.defaultFont.mSize.height*0.6
            }
        }

        Row {
            id: buttonsRow
            spacing: 8
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                //the bottom margin is disabled but we want it anyways
                bottomMargin: theme.defaultFont.mSize.height*0.6
            }

            PlasmaComponents.Button {
                id: acceptButton
                text: i18n("Add items")
                onClicked: accept()
            }

            PlasmaComponents.Button {
                id: rejectButton
                text: i18n("Cancel")
                onClicked: reject()
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
