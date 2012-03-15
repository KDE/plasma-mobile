// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2012 Sebastian Kügler <mart@kde.org>
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
import org.kde.plasma.extras 0.1
import org.kde.active.settings 0.1 as ActiveSettings
import "testhelper.js" as TestHelper


ActiveSettings.ConfigGroup {

    id: levelZero
    anchors.fill: parent
    file: "active-settings-configtestrc"
    group: "LevelZero"

    ActiveSettings.ConfigGroup {
        id: levelOne
        file: levelZero.file
        group: "LevelOne0"
    }


    Title {
        id: nestingHeader
        width: parent.width
        clip: true
        anchors { top: parent.top; topMargin: 24;}
        text: "Nested Config"
    }

    Text {
        id: nestingText
        width: parent.width
        clip: true
        anchors { top: nestingHeader.bottom; topMargin: 24;}
    }

    ListView {
        anchors { top: nestingText.bottom; topMargin: 24; }
        id: groupsList
        currentIndex: -1
        height: 48
        width: parent.width
        clip: true
        orientation: Qt.Horizontal
        spacing: 4
        model: groupList
        delegate: groupDelegate
    }
    Component {
        id: groupDelegate
        PlasmaComponents.Button {
            width: 100
            height: groupsList.height
            checked: levelOne.group == modelData
            text: modelData
            onClicked: levelOne.group = modelData
        }
    }

    ListView {
        anchors { top: groupsList.bottom; topMargin: 24; bottom: parent.bottom; left: parent.left; leftMargin: 40}
        id: configList
        currentIndex: -1
        //height: 200
        width: parent.width
        clip: true
        spacing: 12
        model: levelOne.keyList
        delegate: configDelegate
    }

    Component {
        id: configDelegate
        Item {
            height: txt.height
            width: configList.width - 300
            Text { id: txt; text: "<b>" + modelData + "</b>:   "; anchors.right: parent.horizontalCenter }
            Text { text: levelOne.readEntry(modelData, "default value"); anchors.left: parent.horizontalCenter }
        }
    }

    function testAll() {
        var out = "<b>Groups in " + file + " [" + group + "]:</b> ";
        out += groupList;

        //out += TestHelper.runTest("string", configGroup.readEntry("fakeString").toString(), "Some _fake_ string.");
        return out;
    }

    Component.onCompleted: {
       nestingText.text = testAll();
    }
}
