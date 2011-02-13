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

QML.Text {
    id: main

/* includes and defines ---------------------------{{{ */
    property Defines defines: Defines {}
/* }}} */

    /* property declarations --------------------------{{{ */
    property alias gradient: background.gradient
    property alias color: background.color

    /* }}} */

    /* signal declarations ----------------------------{{{ */
    /* }}} */

    /* JavaScript functions ---------------------------{{{ */
    /* }}} */

    /* object properties ------------------------------{{{ */
    /* }}} */

    /* child objects ----------------------------------{{{ */

    QML.Rectangle {
        id: background

        anchors {
            fill: parent
            rightMargin:   - defines.smallPadding
            leftMargin:    - defines.smallPadding
            topMargin:     - defines.smallPadding
            bottomMargin:  - defines.smallPadding
        }

        gradient: defines.tooltipBackground
        radius: defines.radius
        smooth: true
        z: -1
    }
    /* }}} */

    /* states -----------------------------------------{{{ */
    /* }}} */

    /* transitions ------------------------------------{{{ */
    QML.Behavior on opacity {
        QML.PropertyAnimation {
            easing.type: QML.Easing.OutCubic
            duration: 200
        }
    }
    /* }}} */
}

