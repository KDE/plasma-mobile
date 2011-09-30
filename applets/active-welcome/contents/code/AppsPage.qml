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
 *   GNU General Public License for more details
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
    height: 500

    Column {
        anchors.fill: parent
        anchors.topMargin: 20
        spacing: 10

        Text {
            width: parent.width - 40
            anchors.horizontalCenter: parent.horizontalCenter
            id: title
            text: i18n("<h1>Peek & Launch</h1>")
            color: theme.textColor
            style: Text.Sunken
            styleColor: theme.backgroundColor
        }

        Text {
            id: description
            width: parent.width - 40
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            text: i18n("<p>Swipe down the top panel to peek at your running apps. Slide it down further to reveal the app launcher.</p> \
            <p>Your running apps are organized into Activities to keep your working area clean.</p><p>Enjoy high-quality apps such as Kontact Touch, Calligra Active (Beta) and Bangarang on your device.")
            color: theme.textColor
            //style: Text.Sunken
            styleColor: theme.backgroundColor
        }
        /*
        Image {
            id: exampleImage
            scale: 0.4
            source: plasmoid.file("images", "example_image.png")
            anchors.top: description.top
            anchors.right: description.right
        }
        */
    }
}
