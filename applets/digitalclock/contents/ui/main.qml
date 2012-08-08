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
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.locale 0.1 as KLocale
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Item {
    id: root
    property int minimumWidth: row.implicitWidth + 4
    property int minimumHeight: theme.smallMediumIconSize

    property Item dialog
    property variant dateTime

    function twoDigitString(number)
    {
        return number < 10 ? "0"+number : number
    }

    KLocale.Locale {
        id: locale
    }

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
        connectedSources: sources
        onNewData: {
            //ringing?
            if (data.active) {
                if (!dialog) {
                    dialog = dialogComponent.createObject(root)
                }
                dialog.alarmData = data
                dialog.open()
            }
        }
    }

    Component {
        id: dialogComponent
        PlasmaComponents.CommonDialog {
            id: dialog
            property variant alarmData
            titleText: i18n("Alarm")
            content: Column {
                width: theme.defaultFont.mSize.width * 30
                PlasmaComponents.Label {
                    text: dialog.alarmData["message"]
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                PlasmaComponents.Label {
                    text: i18n("Alarm for %1", locale.formatDateTime(dialog.alarmData["dateTime"]))
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            buttonTexts: [i18n("Dismiss"), i18n("Snooze")]

            function performAlarmAction(operationName, id) {
                var service = alarmsSource.serviceForSource("")
                var operation = service.operationDescription(operationName)

                operation["Id"] = id
                if (operationName == "defer") {
                    operation["Minutes"] = 5
                }

                service.startOperationCall(operation)
            }
            onButtonClicked: {
                if (index == 0) {
                    performAlarmAction("dismiss", dialog.alarmData["id"])
                } else if (index == 1) {
                    performAlarmAction("defer", dialog.alarmData["id"])
                }
            }
            onClickedOutside: performAlarmAction("defer", dialog.alarmData["id"])
        }
    }

    PlasmaCore.Svg {
        id: configIconsSvg
        imagePath: "widgets/configuration-icons"
    }


    Row {
        id: row
        anchors.centerIn: parent
        height: parent.height - 8
        MobileComponents.TextEffects {
            id: clockText
            effect: MobileComponents.TextEffects.TexturedText
            pixelSize: parent.height
            anchors.verticalCenter: parent.verticalCenter
            text: twoDigitString(dateTime.getHours()) + ":" + twoDigitString(dateTime.getMinutes())
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
