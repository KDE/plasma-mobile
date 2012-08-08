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
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.locale 0.1 as KLocale
import org.kde.qtextracomponents 0.1

PlasmaComponents.Page {
    id: alarmEditRoot

    property int alarmId: 0
    onAlarmIdChanged: {
        if (alarmId > 0) {
            var dt = new Date(alarmsSource.data["Alarm-"+alarmId].dateTime)

            currentDate = new Date(alarmsSource.data["Alarm-"+alarmId].dateTime)
        } else {
            currentDate = new Date()
        }
    }

    property variant currentDate
    Component.onCompleted: {
        var component = Qt.createComponent(plasmoid.file("ui", "PanelBackground.qml"))
        if (component) {
            component.createObject(alarmEditRoot)
        }

        if (alarmId > 0) {
            currentDate = new Date(alarmsSource.data["Alarm-"+alarmId].date)
        } else {
            currentDate = new Date()
        }
    }

    PlasmaExtras.ScrollArea {
        anchors.fill: parent
        Flickable {
            id: mainFlickable
            contentWidth: contentColumn.width
            contentHeight: contentColumn.height
            clip: true
            Item {
                height: Math.max(childrenRect.height, mainFlickable.height)
                width: Math.max(childrenRect.width, mainFlickable.width)
                Column {
                    id: contentColumn
                    spacing: 8
                    anchors.centerIn: parent

                    DatePicker {
                        id: datePicker
                        anchors.horizontalCenter: parent.horizontalCenter
                        day: currentDate.getDate()
                        month: currentDate.getMonth() + 1
                        year: currentDate.getFullYear()
                    }

                    TimePicker {
                        id: timePicker
                        anchors.horizontalCenter: parent.horizontalCenter
                        hours: currentDate.getHours()
                        minutes: currentDate.getMinutes()
                        seconds: currentDate.getSeconds()
                    }

                    Grid {
                        spacing: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        rows: 3
                        columns: 2

                        PlasmaComponents.Label {
                            anchors {
                                right: messageArea.left
                                rightMargin: 4
                            }
                            text: i18n("Message:")
                        }
                        PlasmaComponents.TextArea {
                            id: messageArea
                            width: alarmEditRoot.width / 2
                            height: theme.defaultFont.mSize.height * 5

                            text: alarmId > 0 ? alarmsSource.data["Alarm-"+alarmId].message : ""
                        }

                        PlasmaComponents.Label {
                            anchors {
                                right: repeatSwitch.left
                                rightMargin: 4
                            }
                            text: i18n("Repeat daily:")
                        }
                        PlasmaComponents.Switch {
                            id: repeatSwitch
                            checked: alarmId > 0 ? alarmsSource.data["Alarm-"+alarmId].recurs : false
                        }

                        PlasmaComponents.Label {
                            anchors {
                                right: audioSwitch.left
                                rightMargin: 4
                            }
                            text: i18n("Audio:")
                        }
                        PlasmaComponents.Switch {
                            id: audioSwitch
                            checked: alarmId > 0 ? alarmsSource.data["Alarm-"+alarmId].audioFile : true
                        }
                    }
                    Row {
                        spacing: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        PlasmaComponents.Button {
                            text: i18n("Save")
                            onClicked: {
                                var service = alarmsSource.serviceForSource("")
                                var operation = service.operationDescription(alarmId > 0 ? "modify" : "add")

                                if (alarmId > 0) {
                                    operation["Id"] = alarmId
                                }
                                operation["Date"] = datePicker.isoDate
                                operation["Time"] = timePicker.timeString
                                operation["Message"] = messageArea.text
                                operation["RecursDaily"] = repeatSwitch.checked
                                if (audioSwitch.checked) {
                                    operation["AudioFile"] = plasmoid.file("data", "ring.ogg")
                                }

                                service.startOperationCall(operation)
                                pageRow.pop(alarmList)
                            }
                        }
                        PlasmaComponents.Button {
                            text: i18n("Cancel")
                            onClicked: {
                                pageRow.pop(alarmList)
                            }
                        }
                    }
                }
            }
        }
    }
}
