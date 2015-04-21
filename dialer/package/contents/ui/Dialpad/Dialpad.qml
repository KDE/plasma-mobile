/*
 *   Copyright 2014 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2014 Marco Martin <mart@kde.org>
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

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

GridLayout {
    id: pad
    columns: 3

    property var callback
    property var pressedCallback
    property var releasedCallback

    property int buttonHeight: parent.height / 6

    Layout.fillWidth: true
    Layout.fillHeight: true

    DialerButton { id: one; text: "1" } 
    DialerButton { text: "2" }
    DialerButton { text: "3" }

    DialerButton { text: "4" } 
    DialerButton { text: "5" }
    DialerButton { text: "6" }

    DialerButton { text: "7" } 
    DialerButton { text: "8" }
    DialerButton { text: "9" }

    DialerButton { text: "*"; } 
    DialerButton { text: "0"; sub: "+"; }
    DialerButton { text: "#" }
}

