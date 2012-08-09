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
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as PlasmaComponents
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.locale 0.1 as KLocale
import org.kde.qtextracomponents 0.1

//FIXME: remove this folder as soon PA3 is branched
import "kde-runtime-4.10"

Item {
    id: root
    property int minimumWidth: 200
    property int minimumHeight: 350

    Component.onCompleted: {
        var component = Qt.createComponent(plasmoid.file("ui", "AppBackground.qml"))
        if (component) {
            component.createObject(root)
        }
    }

    function removeAlarm(id)
    {
        var service = alarmsSource.serviceForSource("")
        var operation = service.operationDescription("delete")

        operation["Id"] = id

        service.startOperationCall(operation)
    }

    function editAlarm(id)
    {
        pageRow.pop(alarmList)
        pageRow.push(Qt.createComponent("AlarmEdit.qml"))
        pageRow.currentPage.alarmId = id
    }

    property bool alarmsPresent: alarmsSource.sources.length > 0
    onAlarmsPresentChanged: {
        if (alarmsPresent) {
            plasmoid.status = "ActiveStatus"
        } else {
            plasmoid.status = "PassiveStatus"
        }
    }

    PlasmaCore.DataSource {
        id: alarmsSource
        engine: "org.kde.alarms"
        interval: 0
        connectedSources: sources
    }

    PlasmaCore.Svg {
        id: configIconsSvg
        imagePath: "widgets/configuration-icons"
    }
    PlasmaCore.Svg {
        id: separatorSvg
        imagePath: "widgets/line"
    }

    KLocale.Locale {
        id: locale
    }

    //FIXME: as soon as PA3 is branched, this should become PlasmaExtras.PageRow
    PageRow {
        id: pageRow
        anchors.fill: parent

        columnWidth: (width/2 > theme.defaultFont.mSize.width*30) ? width/2 : width

        initialPage: AlarmList {
            id: alarmList
        }
    }
}
