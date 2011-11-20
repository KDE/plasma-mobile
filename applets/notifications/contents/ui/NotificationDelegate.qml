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
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.qtextracomponents 0.1

PlasmaComponents.ListItem {
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
        Item {
            width: parent.width
            height: appNameLabel.height
            QIconItem {
                id: appIconItem
                icon: QIcon(appIcon)
                width: theme.mediumIconSize
                height: theme.mediumIconSize
            }

            PlasmaComponents.Label {
                id: appNameLabel
                text: appName
                font.bold: true
                height: paintedHeight
                anchors {
                    left: appIconItem.right
                    right: parent.right
                }
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
            PlasmaCore.SvgItem {
                svg: configIconsSvg
                elementId: "close"
                width: theme.mediumIconSize
                height: theme.mediumIconSize
                anchors {
                    top: parent.top
                    right: parent.right
                    rightMargin: 12
                }
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    onClicked: {
                        notificationsModel.remove(index)
                    }
                }
            }
        }

        PlasmaComponents.Label {
            text: body
            color: theme.textColor
            anchors {
                left: parent.left
                right:parent.right
                leftMargin: theme.mediumIconSize+6
                rightMargin: theme.mediumIconSize+6
            }
            wrapMode: Text.Wrap
        }
    }
}
