/*   vim:set foldenable foldmethod=marker:
 *
 *   Copyright (C) 2012 Ivan Cukic <ivan.cukic(at)kde.org>
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

import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents

QML.Item {
    id: main

    /* property declarations --------------------------{{{ */
    property alias location: labelLocation.text

    property int minimumWidth: buttonChange.width * 3
    property int minimumHeight: buttonChange.height
    /* }}} */

    /* signal declarations ----------------------------{{{ */
    signal requestChange
    /* }}} */

    /* JavaScript functions ---------------------------{{{ */
    /* }}} */

    /* object properties ------------------------------{{{ */
    /* }}} */

    /* child objects ----------------------------------{{{ */
    PlasmaComponents.Label {
        id: labelLocation

        anchors {
            top: parent.top
            left: parent.left
            right: buttonChange.left
        }

        PlasmaComponents.Label {
            visible: labelLocation.text == ""
            opacity: 0.5
            text:    "Unknown"

            anchors.fill: parent
        }

        QML.MouseArea {
            anchors.fill: parent
            onClicked: main.requestChange()
        }
    }

    PlasmaComponents.Button {
        id: buttonChange
        text: "Change"
        width: parent.width / 3

        anchors {
            top: parent.top
            right: parent.right
        }

        onClicked: main.requestChange()
    }
    /* }}} */

    /* states -----------------------------------------{{{ */
    /* }}} */

    /* transitions ------------------------------------{{{ */
    /* }}} */
}

