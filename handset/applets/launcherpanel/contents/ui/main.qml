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
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore

Item {
    id: main
    height: 128
    //FIXME: why bindings don't work there?
    onWidthChanged: {
        shortcuts.width = Math.min(width, 113*5+45*4)
        shortcuts.state = width>500?"expanded":"compact"
    }

    Flow {
        id: shortcuts;
        anchors.centerIn: parent
        //FIXME
        width: 800
        spacing: 45;
        state: "expanded"

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
            command: "konqueror"
        }
        Icon {
            icon: "im"
            command: "kopete"
        }

        Item {
            id: spacer2
            width: internet.width/2;
            height: internet.height;
            visible:false
        }

        Icon {
            icon: "phone"
            command: "linphone"
        }
        Icon {
            icon: "social"
            command: "plasma-windowed twitter"
        }
        Icon {
            icon: "games"
            command: "kpat"
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
}
