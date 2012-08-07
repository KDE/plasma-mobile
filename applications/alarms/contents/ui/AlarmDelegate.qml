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
import org.kde.locale 0.1 as KLocale
import org.kde.qtextracomponents 0.1

PlasmaComponents.ListItem {
    id: alarmItem
    opacity: 1-Math.abs(x)/width


    MouseArea {
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
                script: root.removeAlarm(id);
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
        Row {
            spacing: 8
            width: alarmItem.width - closeButton.width

            Column {
                width: parent.width/4
                PlasmaComponents.Label {
                    text: locale.formatDate(date, KLocale.Locale.FancyShortDate)
                }
                PlasmaComponents.Label {
                    text: locale.formatLocaleTime(time)
                }
            }
            PlasmaComponents.Label {
                width: parent.width/4
                text: message
            }
            PlasmaComponents.Label {
                width: parent.width/4
                text: recurs ? i18n("Every day") : i18n("Once")
            }
            PlasmaComponents.Label {
                width: parent.width/4
                text: audioFile ? i18n("Audio") : ""
            }
        }
        PlasmaCore.SvgItem {
            id: closeButton
            svg: configIconsSvg
            elementId: "close"
            width: theme.mediumIconSize
            height: theme.mediumIconSize
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 12
            }
            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                onClicked: {
                    removeAnimation.running = true
                }
            }
        }
    }
}
