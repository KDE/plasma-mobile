/***************************************************************************
 *   Copyright 2010 Lim Yuen Hoe <yuenhoe@hotmail.com>                     *
 *   Copyright 2011 Davide Bettio <bettio@kde.org>                         *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore

Item {
    id: systrayPanel

    Rectangle {
        color: "red"
        anchors.fill:parent
    }

    function addContainment(cont)
    {
        if (cont.pluginName == "org.kde.mobilelauncher") {
            menuContainer.plasmoid = cont
        } else if (cont.pluginName == "org.kde.windowstrip") {
            windowListContainer.plasmoid = cont
        } else if (cont.pluginName == "org.kde.mobilesystemtray") {
            systrayContainer.plasmoid = cont
        }
    }

    SlidingDragButton {
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        width: 32
        height: 32
    }

    Column {
        anchors.fill: parent

        PlasmoidContainer {
            id: menuContainer
            anchors {
                left: parent.left
                right: parent.right
            }
            height: parent.height - 35 - parent.height/4
        }
        PlasmoidContainer {
            id: windowListContainer
            anchors {
                left: parent.left
                right: parent.right
            }
            height: parent.height/4
        }
        PlasmoidContainer {
            id: systrayContainer
            anchors {
                left: parent.left
                right: parent.right
                rightMargin: 32
            }
            height: 35
        }
    }
}
