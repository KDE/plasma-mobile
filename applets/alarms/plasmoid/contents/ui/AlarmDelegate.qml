/*
 *   Copyright 2012 Marco Martin <notmart@gmail.com>
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
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.locale 0.1 as KLocale
import org.kde.qtextracomponents 0.1

PlasmaComponents.ListItem {
    id: alarmItem
    opacity: 1-Math.abs(x)/width

    onClicked: editAlarm(id)

    checked: mainArea.pressed || pageRow.currentPage.alarmId == id

    MouseArea {
        id: mainArea
        width: alarmItem.width
        height: childrenRect.height
        drag {
            target: alarmItem
            axis: Drag.XAxis
        }
        onReleased: {
            if (alarmItem.x < -alarmItem.width/2) {
                removeAnimation.exitFromRight = false
                removeAnimation.running = true
            } else if (alarmItem.x > alarmItem.width/2 ) {
                removeAnimation.exitFromRight = true
                removeAnimation.running = true
            } else {
                resetAnimation.running = true
            }
        }
        onClicked: alarmItem.clicked()
        SequentialAnimation {
            id: removeAnimation
            property bool exitFromRight: true
            NumberAnimation {
                target: alarmItem
                properties: "x"
                to: removeAnimation.exitFromRight ? alarmItem.width : -alarmItem.width
                duration: 250
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: alarmItem
                properties: "height"
                to: 0
                duration: 250
                easing.type: Easing.InOutQuad
            }
            ScriptAction {
                script: removeAlarm(id);
            }
        }
        SequentialAnimation {
            id: resetAnimation
            NumberAnimation {
                target: alarmItem
                properties: "x"
                to: 0
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
        Column {
            width: alarmItem.width

            PlasmaExtras.Heading {
                level: 3
                elide: Text.ElideRight
                text: i18nc("Alarm setting,<date> at <time>",
                            "%1 at %2",
                            locale.formatDate(dateTime, KLocale.Locale.FancyShortDate),
                            locale.formatLocaleTime(dateTime))
            }

            Row {
                spacing: theme.defaultFont.mSize.height * .5
                width: alarmItem.width
                PlasmaCore.IconItem {
                    id: audioIcon
                    anchors.verticalCenter: parent.verticalCenter
                    width: theme.iconSizes.small
                    height: width
                    visible: audioFile
                    source: "audio-volume-high"
                }

                PlasmaCore.IconItem {
                    id: messageIcon
                    anchors.verticalCenter: parent.verticalCenter
                    width: theme.iconSizes.small
                    height: width
                    visible: message
                    source: "mail-message"
                }

                PlasmaComponents.Label {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: recurs
                    text: i18n("Repeats every day")
                    elide: Text.ElideRight
                }
            }
        }
    }
}
