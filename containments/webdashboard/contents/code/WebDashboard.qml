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
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.extra 0.1 as PlasmaExtra
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.plasma.slccomponents 0.1 as SlcComponents

Item {
    width: 960
    height: 540

    y: 64 // leave space for the top panel

    PlasmaCore.Theme { id: theme }

    PlasmaExtra.ResourceInstance {
        id: resourceInstance
    }

    Column {
        id: mainList
        anchors.fill: parent

        PlasmaComponents.Label {
            id: bookmarksLabel
            text: i18n("Favorites")
            color: theme.textColor
            font.pointSize: 24
            style: Text.Sunken;
            styleColor: theme.backgroundColor
        }

        Bookmarks {
            id: bookmarks
            width: parent.width
        }


        /*
        PlasmaComponents.Label {
            id: openPagesLabel
            text: i18n("Open pages")
            color: theme.textColor
            font.pointSize: 24
            style: Text.Sunken;
            styleColor: theme.backgroundColor
        }

        Bookmarks {
            id: tabs
            width: parent.width
        }
        */
    }

    NewBookmark {
        id: newBookmark
        width: parent.width / 3
        x: parent.width-width
        y: -24
        anchors.bottom: bookmarksLabel.bottom
    }

    SlcComponents.SlcMenu {
        id: contextMenu
    }
}