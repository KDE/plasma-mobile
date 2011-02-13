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

QML.Item {
    id: main

/* includes and defines ---------------------------{{{ */
    property Defines defines: Defines {}
/* }}} */


/* property declarations --------------------------{{{ */
    property alias caption: textTitle.text
    property alias image: imageIcon.source
/* }}} */


/* object properties ------------------------------{{{ */
    width: textTitle.width + 2 * defines.bigPadding
           + imageIcon.width + (imageIcon.width > 0 ? defines.padding : 0)
    height: defines.captionHeight
/* }}} */


/* child objects ----------------------------------{{{ */
    QML.Rectangle {
        id: background

        anchors {
            fill: parent
            margins: defines.smallPadding
        }

        gradient: defines.buttonBackgroundNormal
        radius: defines.radius
        smooth: true
    }

    QML.Image {
        id: imageIcon
        source: "images/icons/22x22/back.png"

        x: defines.bigPadding
        y: (parent.height - height) / 2
    }

    QML.Text {
        id: textTitle

        text: "Button"

        x: defines.bigPadding
           + imageIcon.width + (imageIcon.width > 0 ? defines.padding : 0)
        y: (parent.height - height) / 2

        verticalAlignment: QML.Text.AlignVCenter
        horizontalAlignment: QML.Text.AlignHCenter
    }

    QML.MouseArea {
        anchors.fill: parent

        onClicked: console.log("clicked")

        onPressed: {
            background.gradient = defines.buttonBackgroundPressed;
            background.border.width = defines.borderWidth;
            background.border.color = defines.buttonBorderColor
        }

        onReleased: {
            background.gradient = defines.buttonBackgroundNormal;
            background.border.width = 0
        }
    }
/* }}} */

}
