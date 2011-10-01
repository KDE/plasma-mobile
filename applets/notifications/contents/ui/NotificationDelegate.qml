/*
 *   Copyright 2011 Marco Martin <notmart@gmail.com>
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

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1

ListItem {
    id: notificationItem
    width: popupFlickable.width

    Timer {
        interval: 30*60*1000
        repeat: false
        running: true
        onTriggered: {
            notificationsModel.remove(index)
        }
    }


    Column {
        spacing: 8
        width: popupFlickable.width
        Text {
            text: appName
            font.bold: true
            color: theme.textColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Row {
            spacing: 6
            QIconItem {
                icon: QIcon(appIcon)
                width: 32
                height: 32
            }

            Text {
                text: body
                color: theme.textColor
                width: popupFlickable.width- 24 - 32 - 12
                wrapMode: Text.Wrap
            }
            PlasmaCore.SvgItem {
                svg: configIconsSvg
                elementId: "close"
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    onClicked: {
                        notificationsModel.remove(index)
                    }
                }
            }
        }
    }
}
