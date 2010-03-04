/***************************************************************************
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
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

import Qt 4.6

Row {
    id: shortcuts;
    spacing: 45;

    anchors.horizontalCenter: parent.horizontalCenter;
    anchors.bottom: parent.bottom;

    Item {
        objectName: "2";
        signal clicked;

        width: internet.width;
        height: internet.height;

        Image {
            id: internet;
            source: "images/internet.png";
        }
        MouseArea {
            anchors.fill: internet;
            onClicked: {
                parent.clicked();
                timer.restart();
            }
        }
    }

    Item {
        objectName: "3";
        signal clicked;

        width: instantmessaging.width;
        height: instantmessaging.height;

        Image {
            id: instantmessaging;
            source: "images/im.png";
        }
        MouseArea {
            anchors.fill: instantmessaging;
            onClicked: {
                parent.clicked();
                timer.restart();
            }
        }
    }

    Item {
        objectName: "4";
        signal clicked;

        width: phone.width;
        height: phone.height;

        Image {
            id: phone;
            source: "images/phone.png";
        }
        MouseArea {
            anchors.fill: phone;
            onClicked: {
                parent.clicked();
                timer.restart();
            }
        }
    }

    Item {
        objectName: "5";
        signal clicked;

        width: social.width;
        height: social.height;

        Image {
            id: social;
            source: "images/social.png";
        }
        MouseArea {
            anchors.fill: social;
            onClicked: {
                parent.clicked();
                timer.restart();
            }
        }
    }

    Item {
        objectName: "6";
        signal clicked;

        width: games.width;
        height: games.height;

        Image {
            id: games;
            source: "images/games.png";
        }
        MouseArea {
            objectName: "mousearea";
            anchors.fill: games;
            onClicked: {
                parent.clicked();
                timer.restart();
            }
        }
    }
}
