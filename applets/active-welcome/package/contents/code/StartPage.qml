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
import org.kde.qtextracomponents 0.1
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts

Item {
    width: 400
    height: 300

    Column {
        anchors.fill: parent
        Text {
            width: parent.width
            id: title
            text: i18n("<h1>Discover Plasma Active</h1>")
            color: theme.textColor
            style: Text.Sunken
            styleColor: theme.backgroundColor
        }

        Text {
            id: description
            width: parent.width
            wrapMode: Text.WordWrap
            text: i18n("<p>Plasma Active allows you to browse and interact with the web. Stay in contact with your friends, read the latest news, enjoy your music and movies.</p><p>Get the best out of your device with <i>Plasma Active</i>, download and install many popular and new apps. Stay in control of your data and shape your user experience.</p>")
            color: theme.textColor
            style: Text.Sunken
            styleColor: theme.backgroundColor
        }

        QIconItem {
            width: 128
            height: 128
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            icon: QIcon("start-here")
            opacity: 0.1

        }
    }
}
