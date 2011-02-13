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


/* child objects ----------------------------------{{{ */
    QML.ListModel {
        id: messageModel

        QML.ListElement {
            messageText: "Hi Martha, wanna go hunt down some Sontarans? Or would you prefer some Daleks? (I'm bored again)"
            messageAuthor: "blahblah"
        }
        QML.ListElement {
            messageText: "I can't today, tomorrow?"
            messageAuthor: ""
        }
        QML.ListElement {
            messageText: "OK, 9AM?"
            messageAuthor: "blahblah"
        }
        QML.ListElement {
            messageText: "Agreed"
            messageAuthor: ""
        }
        QML.ListElement {
            messageText: "Fantastic!"
            messageAuthor: "blahblah"
        }
    }

    QML.Component {
        id: messageDelegate

        MessageItem {
            author: messageAuthor
            text:   messageText

            width: parent.width
        }
    }

    QML.ListView {
        anchors.fill: parent
        model: messageModel
        delegate: messageDelegate
    }
/* }}} */
}
