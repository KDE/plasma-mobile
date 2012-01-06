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
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.active.settings 0.1 as ActiveSettings

Flickable {
    id: configTestModule
    objectName: "configTestModule"
    interactive: true
    contentWidth: 800; contentHeight: 1000

    ActiveSettings.ConfigGroup {
        id: configGroup
        file: "active-settings-configtestrc"
        group: "fakeValues"
    }

    ListView {
        id: configList
        currentIndex: -1
        height: 200
        width: parent.width-200
        clip: true
        spacing: 4
        anchors {
            //verticalCenter: parent.verticalCenter
            top: parent.top
            topMargin: spacing*2
            bottom: parent.bottom
            leftMargin: 100
            rightMargin: 100
        }
        model: configGroup.keyList
        delegate: configDelegate

        //Rectangle { anchors.fill: configList; color: "white"; opacity: 0.1; }
    }
    Component {
        id: configDelegate
        Item {
            height: 24
            width: configList.width
            Text { text: "<b>" + modelData + "</b>:   "; anchors.right: parent.horizontalCenter }
            Text { text: configGroup.readEntry(modelData, "default value"); anchors.left: parent.horizontalCenter }
        }
    }
}
