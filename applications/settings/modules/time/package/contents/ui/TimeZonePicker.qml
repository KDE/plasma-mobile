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
import org.kde.active.settings 0.1

Item {
    id: timeZonePicker
    objectName: "timeZonePicker"

    anchors { top: twentyFourItem.bottom; left: parent.left; right: parent.right; topMargin: 32; }
    height: 300

    Text {
        id: timeZoneLabel
        color: theme.textColor
        anchors.right: parent.horizontalCenter
        anchors.top: parent.top
        text: i18n("Timezone:")
        anchors.rightMargin: 12
        //opacity: 1
    }

    Text {
        anchors.left: parent.horizontalCenter
        anchors.verticalCenter: timeZoneLabel.verticalCenter
        text: timeSettings.timeZone
    }

    PlasmaComponents.TextField {
        id: tzFilter
        placeholderText: "filter..."
        //Keys.onTabPressed: tf2.forceActiveFocus();
        anchors {
            //verticalCenter: parent.verticalCenter
            top: timeZoneLabel.bottom
            //topMargin: 32;
            //bottom: parent.bottom
        }
    }

    ListView {
        id: timeZonesList
        //height: 500
        width: parent.width
        clip: true
        anchors {
            //verticalCenter: parent.verticalCenter
            top: tzFilter.bottom
            bottom: parent.bottom
        }
        /*
        model: PlasmaCore.SortFilterModel {
            id: feedListFilter
            //filterRole: "modelData"
            filterRegExp: tzFilter.text
            sourceModel: timeSettings.timeZones
        }
        */
        model: timeSettings.timeZones
        delegate: Text {
            height: 24
            //width: 200
            text: modelData
        }

        Component.onCompleted: {
            //print("timezones: " + model);
        }
    }
    //Rectangle { anchors.fill: timeZonePicker; color: "green"; opacity: 0.1; }
    //Rectangle { anchors.fill: timeZonesList; color: "blue"; opacity: 0.1; }

}