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

import QtQuick 1.0 as QML

QML.Rectangle {
    id: itemBackground

/* includes and defines ---------------------------{{{ */
    property Defines defines: Defines {}
    property int buttonOffset: 32

    QML.QtObject {
        id: enumMode
        property int normalMode: 0
        property int forwardMode: 1
        property int deleteMode: 2
    }
/* }}} */


/* property declarations --------------------------{{{ */
    property string author: "Ivan"
    property alias text: textItemMessage.text

    property int _mode: enumMode.normalMode
/* }}} */


/* signal declarations ----------------------------{{{ */
    signal forwardInvoked
    signal deleteInvoked
/* }}} */


/* JavaScript functions ---------------------------{{{ */
    QML.Behavior on x {
        QML.PropertyAnimation {
            easing.type: QML.Easing.OutCubic
            duration: 500
        }
    }

    onXChanged: {
        if (x > width / 3) {
            _mode = enumMode.forwardMode;
            // buttonForward.gradient = defines.buttonBackgroundPressed;
            // buttonForward.border.width = defines.borderWidth;
            // buttonForward.border.color = defines.buttonBorderColor;
            tooltipForward.opacity = 1;

        } else if (- x > width / 3) {
            _mode = enumMode.deleteMode;
            // buttonDelete.gradient = defines.buttonBackgroundDangerPressed;
            // buttonDelete.border.width = defines.borderWidth;
            // buttonDelete.border.color = defines.buttonBorderDangerColor;
            tooltipDelete.opacity = 1;

        } else {
            _mode = enumMode.normalMode;
            // buttonForward.gradient = null;
            // buttonDelete.gradient = null;
            // buttonForward.border.width = 0;
            // buttonDelete.border.width = 0;
            tooltipForward.opacity = 0.5;
            tooltipDelete.opacity  = 0.5;

        }
    }
/* }}} */


/* object properties ------------------------------{{{ */
    height: textItemMessage.height + 2 * defines.padding

    gradient: messageAuthor == "" ?
                  defines.listItemBackgroundHighlighted
                : defines.listItemBackground
/* }}} */


/* child objects ----------------------------------{{{ */
    QML.Text {
        id: textItemMessage
        y: defines.padding

        anchors {
            left: parent.left
            right: parent.right

            leftMargin: defines.padding + buttonOffset
            rightMargin: defines.padding + buttonOffset
        }

        text: "Hello world!"
        width: parent.width
        color: "white"
        wrapMode: QML.Text.WordWrap
        horizontalAlignment: messageAuthor == "" ? QML.Text.AlignLeft : QML.Text.AlignRight
    }

    QML.Rectangle {
        id: buttonDelete

        width: buttonOffset

        color: "#00000000"
        visible: itemMouseArea.drag.active || itemMouseArea.pressed

        opacity: Math.max(
                    0.5,
                    - 4 * itemBackground.x / itemBackground.width
                )

        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        x: - parent.x

        QML.Image {
            anchors.centerIn: parent
            source: "images/icons/22x22/delete.png"
        }

        Tooltip {
            id: tooltipDelete

            text: "Delete"
            gradient: defines.buttonBackgroundDangerNormal
            opacity: 0.5

            anchors {
                left: parent.left
                bottom: parent.top
            }
        }
    }

    QML.Rectangle {
        id: buttonForward

        width: buttonOffset

        color: "#00000000"
        visible: itemMouseArea.drag.active || itemMouseArea.pressed

        opacity: Math.max(
                    0.5,
                    4 * itemBackground.x / itemBackground.width
                )

        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        x: parent.width - parent.x - width

        QML.Image {
            anchors.centerIn: parent
            source: "images/icons/22x22/forward.png"
        }

        Tooltip {
            id: tooltipForward

            text: "Forward"
            gradient: defines.buttonBackgroundNormal
            opacity: 0.5

            anchors {
                right: parent.right
                bottom: parent.top
            }
        }
    }

    QML.MouseArea {
        id: itemMouseArea

        property bool pressed: false

        drag.axis: QML.Drag.XAxis
        drag.target: itemBackground
        drag.minimumX: - width / 2
        drag.maximumX:   width / 2

        anchors {
            fill: textItemMessage

            leftMargin:  buttonDelete.visible  ? 0 : - buttonOffset
            rightMargin: buttonForward.visible ? 0 : - buttonOffset
        }

        onReleased: {
            itemBackground.x = 0;

            switch (_mode) {
                case enumMode.deleteMode:
                    console.log("delete invoked");
                    deleteInvoked()
                    break;

                case enumMode.forwardMode:
                    console.log("forward invoked");
                    forwardInvoked()
                    break;
            }

            pressed = false;
        }

        onPressed: {
            pressed = true;
        }
    }
/* }}} */
}
