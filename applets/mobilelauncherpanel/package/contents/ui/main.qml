/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore

Flow {
    id: shortcuts;
    spacing: 45;
    state: width>400?"expanded":"compact"

    Component.onCompleted: {
        plasmoid.drawWallpaper = false

        plasmoid.containmentType = "CustomContainment"
    }

    PlasmaCore.Theme {
        id: theme
    }
    

    Item {
        id: spacer1
        width: internet.width/2;
        height: internet.height;
        visible:false
    }

    Icon {
        id: internet
        icon: "internet"
    }
    Icon {
        icon: "im"
    }

    Item {
        id: spacer2
        width: internet.width/2;
        height: internet.height;
        visible:false
    }

    Icon {
        icon: "phone"
    }
    Icon {
        icon: "social"
    }
    Icon {
        icon: "games"
    }

    states: [
        State {
            name: "expanded";
            PropertyChanges {
                target: shortcuts
                //FIXME: hardcoded values
                width: 750
            }
            PropertyChanges {
                target: spacer1
                visible: false
            }
            PropertyChanges {
                target: spacer2
                visible: false
            }
        },
        State {
            name: "compact";
            PropertyChanges {
                target: shortcuts
                width: 475
            }
            PropertyChanges {
                target: spacer1
                visible: true
            }
            PropertyChanges {
                target: spacer2
                visible: true
            }
        }
    ]
}
