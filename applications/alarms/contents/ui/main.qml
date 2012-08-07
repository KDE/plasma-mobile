/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
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
    width: 100
    height: 100

    function removeAlarm(id)
    {
        print("Asked removal of " + id);
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

    KLocale.Locale {
        id: locale
    }

    PlasmaExtras.ScrollArea {
        anchors.fill: parent
        clip: true

        ListView {
            model: PlasmaCore.DataModel {
                dataSource: alarmsSource
            }
            delegate: AlarmDelegate {
                
            }
        }
    }
}
