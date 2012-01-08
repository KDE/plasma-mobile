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
import org.kde.active.settings 0.1 as ActiveSettings

Flickable {
    anchors.fill: parent
    ActiveSettings.ConfigGroup {
        id: configGroup
        file: "active-settings-configtestrc"
        group: "LevelZero"
    }

    PlasmaComponents.Label {
        id: lbl
        text: "<h1>ConfigGroup Browser</h1>"

    }

    PlasmaComponents.Label {
        id: outputLabel
        height: 100
        anchors { top: lbl.bottom; left: parent.left; right: parent.right; /*bottom: parent.bottom */}
    }

    ConfigGroupItem {
        anchors { top: lbl.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        //height: 400
        file: "active-settings-configtestrc"
        group: "LevelZero"
    }

    Component.onCompleted: {
        //print(showGroup(configGroup));
    }

    function showGroup(grp) {
        var out = "<h3>" + configGroup.group + "</h3>\n";
        for (var i = 0; i < grp.keyList.length; i++){
            print(" no: " + i + grp.keyList[i]);
            var modelData = grp.keyList[i];
            out += "\n<br/>&nbsp;&nbsp;&nbsp;<em>" + modelData + "</em>: " + grp.readEntry(modelData, "default value");

        }
        for (var i = 0; i < grp.groupList.length; i++){
            print(" no: " + i + grp.groupList[i]);
            var modelData = grp.groupList[i];
            out += "\n<br/>&nbsp;&nbsp;&nbsp;<b>" + modelData + "</b>";
            // showGroup();
        }
        return out;
    }

}
