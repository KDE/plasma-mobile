// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <mart@kde.org>
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
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.active.settings 0.1 as ActiveSettings
import "testhelper.js" as TestHelper


Flickable {
    id: configTestModule
    objectName: "configTestModule"
    interactive: true
    //anchors.fill: parent
    contentWidth: 800; contentHeight: 1000

    ActiveSettings.ConfigGroup {
        id: configGroup
        file: "active-settings-configtestrc"
        group: "fakeValues"
    }


    Text {
        id: nestingHeader
        width: parent.width
        clip: true
        anchors { top: parent.top; topMargin: 8;}
        text: "<h3>Nested Config</h3>"
    }

    Text {
        id: nestingText
        width: parent.width
        clip: true
        anchors { top: nestingHeader.bottom; topMargin: 8;}
    }

    function testAll() {
        var out = "";

        out += TestHelper.runTest("string", configGroup.readEntry("fakeString").toString(), "Some _fake_ string.");
        return out + "</p>";
    }

    Component.onCompleted: {
       nestingText.text = testAll();
    }
}
