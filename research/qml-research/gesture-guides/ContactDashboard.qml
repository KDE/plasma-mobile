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

QML.Rectangle {
    id: main

/* includes and defines ---------------------------{{{ */
    property Defines defines: Defines {}
/* }}} */

    /* property declarations --------------------------{{{ */
    /* }}} */

    /* signal declarations ----------------------------{{{ */
    /* }}} */

    /* JavaScript functions ---------------------------{{{ */
    /* }}} */

    /* object properties ------------------------------{{{ */
    width: 360
    height: 640
    gradient: defines.windowBackground

    /* }}} */

    /* child objects ----------------------------------{{{ */
    Contact {
        id: contact0
        avatar: "images/contacts/jos.png"
        name: "Jos"

        anchors {
            bottom: parent.verticalCenter
            left: parent.horizontalCenter
        }

        width: 64 * 1.5
    }

    Contact {
        id: contact1
        avatar: "images/contacts/marco.png"
        name: "Marco"

        anchors {
            top: parent.verticalCenter
            right: parent.horizontalCenter
        }

        width: 64 * 1.5
    }

    Contact {
        id: contact2
        avatar: "images/contacts/aseigo.png"
        name: "Aaron"

        anchors {
            bottom: parent.verticalCenter
            right: parent.horizontalCenter
        }

        width: 64
    }

    Contact {
        id: contact3
        avatar: "images/contacts/ivan.png"
        name: "Ivan"

        anchors {
            top: parent.verticalCenter
            left: parent.horizontalCenter
        }

        width: 64
    }

    Contact {
        id: contact4
        avatar: "images/contacts/claudia.png"
        name: "Claudia"

        anchors {
            top: parent.verticalCenter
            left: contact3.right
        }

        width: 64
    }

    Contact {
        id: contact5
        avatar: "images/contacts/chani.png"
        name: "Chani"

        anchors {
            top: contact3.bottom
            left: parent.horizontalCenter
        }

        width: 64
    }

    Contact {
        id: contact6
        avatar: "images/contacts/annma.jpg"
        name: "Annma"

        anchors {
            bottom: parent.verticalCenter
            right: contact2.left
        }

        width: 64
    }

    Contact {
        id: contact7
        avatar: "images/contacts/lydia.png"
        name: "Lydia"

        anchors {
            right: parent.horizontalCenter
            bottom: contact2.top
        }

        width: 64
    }
/*
    Contact {
        id: contact3
        avatar: "images/contacts/ivan.png"
        name: "Ivan"

        anchors {
            top: parent.verticalCenter
            left: parent.horizontalCenter
        }

        width: 64
    }

    Contact {
        id: contact3
        avatar: "images/contacts/ivan.png"
        name: "Ivan"

        anchors {
            top: parent.verticalCenter
            left: parent.horizontalCenter
        }

        width: 64
    }
    */

    /* }}} */

    /* states -----------------------------------------{{{ */
    /* }}} */

    /* transitions ------------------------------------{{{ */
    /* }}} */
}

