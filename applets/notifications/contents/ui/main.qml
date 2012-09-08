/***************************************************************************
 *   Copyright 2011 Davide Bettio <davide.bettio@kdemail.net>              *
 *   Copyright 2011 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Library General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU Library General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.qtextracomponents 0.1
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.locale 0.1 as KLocale

Item {
    id: notificationsApplet
    state: "default"
    width: 32
    height: 32
    property int minimumWidth: mainScrollArea.implicitWidth
    property int minimumHeight: mainScrollArea.implicitHeight

    property real globalProgress: 0
    //notifications + jobs
    property int totalCount: notifications.count + jobs.count
    onTotalCountChanged: {
        if (totalCount > 0) {
            state = "new-notifications"
        } else {
            state = "default"
            plasmoid.hidePopup()
        }
    }

    property Item notificationIcon

    Component.onCompleted: {
        //plasmoid.popupIcon = QIcon("preferences-desktop-notification")
        plasmoid.aspectRatioMode = "ConstrainedSquare"
        plasmoid.status = PassiveStatus
        plasmoid.passivePopup = true
        allApplications = new Object
    }

    KLocale.Locale {
        id: locale
    }

    PlasmaCore.Svg {
        id: configIconsSvg
        imagePath: "widgets/configuration-icons"
    }

    property Component compactRepresentation: Component {
        NotificationIcon {
            id: notificationIcon
            Component.onCompleted: notificationsApplet.notificationIcon = notificationIcon
        }
    }


    PlasmaExtras.ScrollArea {
        id: mainScrollArea
        anchors.fill: parent
        implicitWidth: 400
        implicitHeight: Math.max(250, Math.min(450, contentsColumn.height))

        Flickable {
            id: popupFlickable
            anchors.fill:parent

            contentWidth: width
            contentHeight: contentsColumn.height
            clip: true

            Column {
                id: contentsColumn
                width: popupFlickable.width

                //TODO: load those on demand based on configuration
                Jobs {
                    id: jobs
                }
                Notifications {
                    id: notifications
                }
            }
        }
    }
}
