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

Item {
    id: root
    width: 500
    height: 500

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

    PlasmaExtras.PageRow {
        id: pageRow
        anchors.fill: parent
        initialPage: AlarmList {
            id: alarmList
        }
    }
}
