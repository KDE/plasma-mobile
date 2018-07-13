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
    rowSpacing: 10
    columnSpacing: 10

    property var callback
    property var pressedCallback
    property var releasedCallback

    DialerButton { id: one; text: "1" }
    DialerButton { text: "2"; sub: "ABC" }
    DialerButton { text: "3"; sub: "DEF" }

    DialerButton { text: "4"; sub: "GHI" }
    DialerButton { text: "5"; sub: "JKL" }
    DialerButton { text: "6"; sub: "MNO" }

    DialerButton { text: "7"; sub: "PQRS" }
    DialerButton { text: "8"; sub: "TUV" }
    DialerButton { text: "9"; sub: "WXYZ" }

    DialerButton { display: "＊"; text: "*"; special: true; }
    DialerButton { text: "0"; subdisplay: "＋"; sub: "+"; }
    DialerButton { display: "＃"; text: "#"; special: true; }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }
    DialerIconButton {
        id: callButton
        Layout.fillWidth: true
        Layout.fillHeight: true

        enabled: status.text.length > 0
        opacity: enabled ? 1 : 0.5
        source: "call-start"
        callback: function() {
            call(status.text);
        }
    }
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }
}
