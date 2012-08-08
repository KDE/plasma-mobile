/*
 *   Copyright 2012 Marco Martin <mart@kde.org>
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

import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Item {
    id: root
    property int minimumWidth: row.implicitWidth
    property int minimumHeight: theme.smallMediumIconSize

    property variant dateTime

    PlasmaCore.DataSource {
        id: clockSource
        engine: "time"
        interval: 30000
        connectedSources: ["Local"]
        onDataChanged: dateTime = new Date(data["Local"]["DateTime"])
    }

    PlasmaCore.DataSource {
        id: alarmsSource
        engine: "org.kde.alarms"
        interval: 0
        //connectedSources: sources
    }

    PlasmaCore.Svg {
        id: configIconsSvg
        imagePath: "widgets/configuration-icons"
    }


    Row {
        id: row
        anchors.centerIn: parent
        height: parent.height
        MobileComponents.TextEffects {
            id: clockText
            effect: MobileComponents.TextEffects.TexturedText
            pixelSize: root.height
            anchors.verticalCenter: parent.verticalCenter
            text: dateTime.getHours() + ":" + dateTime.getMinutes()
        }
        PlasmaCore.SvgItem {
            id: alarmIcon
            svg: PlasmaCore.Svg {imagePath: "icons/korgac"}
            elementId: "korgac"
            height: parent.height
            width: height
            visible: alarmsSource.sources.length > 0
        }
    }
}
