// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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
import org.kde.plasma.core 0.1 as PlasmaCore

Item {
    width: 400
    height: 300

    Column {
        anchors.fill: parent
        anchors.topMargin: 20
        spacing: 10
        Text {
            width: parent.width - 40
            anchors.horizontalCenter: parent.horizontalCenter
            id: title
            text: i18n("<h1>Activities</h1>")
            color: theme.textColor
            style: Text.Sunken
            styleColor: theme.backgroundColor
        }

        Text {
            id: description
            width: parent.width - 40
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            text: i18n("<p>Activities help you to organize your device and its contents to reflect you.</p><p>Activities allow you to collect related apps, bookmarks, media, documents and contacts together into themed groups you create. This text you are reading is in such a themed Activity right now! You can switch between Activities by sliding out the Activity switcher from the right hand side of the screen. The switcher also lets you create new activities and remove old ones.</p>\
            <p>Use the buttons at the top left to personalize the current activity and add items to it. You can move items around in an Activity by dragging their titles and resize them by dragging the bottom right-hand corner. Items can also be removed and many support configuration by pressing on the appropriate icon in the item's title bar.</p>")
            color: theme.textColor
            styleColor: theme.backgroundColor
        }
    }
}
