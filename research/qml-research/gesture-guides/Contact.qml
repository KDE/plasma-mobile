/*   vim:set foldenable foldmethod=marker:
 *
 *   Copyright (C) 2011 Ivan Cukic <ivan.cukic(at)kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import Qt 4.7 as QML

QML.Item {
    id: main

/* includes and defines ---------------------------{{{ */
    property Defines defines: Defines {}
    property int actionsSize: 32

    property alias avatar: imageContact.source
    property alias name: title.text
/* }}} */


    /* property declarations --------------------------{{{ */
    /* }}} */


    /* signal declarations ----------------------------{{{ */
    /* }}} */


    /* JavaScript functions ---------------------------{{{ */
    onWidthChanged: height = width

    /* }}} */

    /* object properties ------------------------------{{{ */
    /* }}} */

    /* child objects ----------------------------------{{{ */
    QML.Rectangle {
        id: background

        // color: "#555"
        gradient: defines.tooltipBackground
        visible: itemMouseArea.drag.active || itemMouseArea.pressed
        radius: defines.radius
        smooth: true

        anchors {
            fill: parent

            leftMargin:    - actionsSize
            rightMargin:   - actionsSize
            topMargin:     - actionsSize
            bottomMargin:  - actionsSize
        }

        QML.Image {
            id: imageCall

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }

            source: "images/icons/22x22/call.png"
        }

        QML.Image {
            id: imageSms

            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }

            source: "images/icons/22x22/sms.png"
        }

        QML.Image {
            id: imageInfo

            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
            }

            source: "images/icons/22x22/info.png"
        }

        QML.Image {
            id: imageMore

            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }

            source: "images/icons/22x22/more.png"
        }

        QML.Rectangle {
            anchors {
                left: imageMore.right
                right: imageInfo.left
                top: imageCall.bottom
                bottom: imageSms.top
            }

            gradient: defines.windowBackground
            radius: defines.radius
            smooth: true
        }
    }

    QML.Image {
        id: imageContact

        source: "images/contact.png"
        fillMode: QML.Image.PreserveAspectCrop

        x: 0
        y: 0
        width: parent.width
        height: parent.height

        QML.Behavior on x {
            QML.PropertyAnimation {
                easing.type: QML.Easing.OutCubic
                duration: 500
            }
        }

        QML.Behavior on y {
            QML.PropertyAnimation {
                easing.type: QML.Easing.OutCubic
                duration: 500
            }
        }

        QML.Rectangle {
            id: titleBackground

            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            height: 20
            color: "black"
            opacity: 0.5
        }

        QML.Rectangle {
            id: imageContactBorder

            anchors.fill: parent
            color: "#00000000"
            border {
                width: 4
                color: "#333"
            }
        }

        QML.Text {
            id: title

            anchors.fill: titleBackground

            color: "white"
            text: "Name"

            verticalAlignment: QML.Text.AlignVCenter
            horizontalAlignment: QML.Text.AlignHCenter
        }
    }

    QML.MouseArea {
        id: itemMouseArea

        property bool pressed: false

        anchors.fill: parent

        drag.axis: QML.Drag.XandYAxis
        drag.target: imageContact
        drag.minimumX: - actionsSize
        drag.maximumX:   actionsSize
        drag.minimumY: - actionsSize
        drag.maximumY:   actionsSize

        onPressed: {
            pressed = true;
            main.z = 1;
        }

        onReleased: {
            pressed = false;
            imageContact.x = 0;
            imageContact.y = 0;
            main.z = 0;
        }
    }
    /* }}} */


    /* states -----------------------------------------{{{ */
    /* }}} */


    /* transitions ------------------------------------{{{ */
    /* }}} */
}

