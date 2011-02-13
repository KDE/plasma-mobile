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
    id: main

/* includes and defines ---------------------------{{{ */
    property Defines defines: Defines {}
/* }}} */


/* object properties ------------------------------{{{ */
    width: 360
    height: 640

    color: "#222"
/* }}} */


/* child objects ----------------------------------{{{ */
    QML.Rectangle {
        id: panelCaption

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        height: defines.captionHeight
        z: 1

        gradient: defines.captionBackground

        Button {
            id: buttonBack

            caption: "Back"
            image: "images/icons/16x16/back.png"

            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
        }

        Button {
            id: buttonOptions

            caption: "Options"
            image: "images/icons/16x16/settings.png"

            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
        }

        QML.Text {
            id: textContactName
            color: "#ffffff"
            text: "Dr John Smith"
            font.bold: true
            verticalAlignment: QML.Text.AlignVCenter
            horizontalAlignment: QML.Text.AlignHCenter
            font.pointSize: 11
            elide: QML.Text.ElideRight

            anchors {
                left: buttonBack.right
                right: buttonOptions.left
                top: parent.top
                bottom: parent.bottom
            }
        }

    }

    QML.Rectangle {
        id: panelMessage

        QML.TextEdit {
            id: textMessage

            text: "TEXT"
            color: "white"

            anchors {
                fill: parent
                leftMargin: 8
                rightMargin: 8
            }
        }

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        height: 96
        z: 1
        color: "#222"

        gradient: defines.textFieldBackground
    }

    MessageList {
        id: listMessages

        anchors {
            top: panelCaption.bottom
            bottom: panelMessage.top
            left: parent.left
            right: parent.right
        }
    }
/* }}} */
}
