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

PlasmaComponents.Page {
    id: root
    clip: true

    Component.onCompleted: {
        var component = Qt.createComponent(plasmoid.file("ui", "PanelBackground.qml"))
        if (component) {
            component.createObject(root)
        }
    }

    PlasmaExtras.ScrollArea {
        id: alarmListScroll
        anchors.fill: parent

        ListView {
            id: alarmList
            model: PlasmaCore.DataModel {
                dataSource: alarmsSource
            }
            header: PlasmaComponents.ListItem {
                id: headerItem
                sectionDelegate: true

                Row {
                    visible: alarmsSource.sources.length > 0
                    spacing: 8
                    width: headerItem.width - theme.mediumIconSize - spacing*3

                    PlasmaComponents.Label {
                        width: parent.width/4
                        text: i18n("Time")
                        elide: Text.ElideRight
                    }

                    PlasmaComponents.Label {
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width/4
                        text: i18n("Message")
                        elide: Text.ElideRight
                    }
                    PlasmaComponents.Label {
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width/4
                        text: i18n("Repeat")
                        elide: Text.ElideRight
                    }
                    PlasmaComponents.Label {
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width/4
                        text: i18n("Audio")
                        elide: Text.ElideRight
                    }
                }

                PlasmaComponents.Label {
                    visible: alarmsSource.sources.length == 0
                    anchors.centerIn: parent
                    text: i18n("No alarms yet")
                }
            }
            delegate: AlarmDelegate {
                
            }
            footer: PlasmaComponents.ListItem {
                enabled: true
                checked: pageRow.currentPage.alarmId <= 0
                Item {
                    width: parent.width
                    height: theme.defaultFont.mSize.height * 3

                    Row {
                        anchors.centerIn: parent
                        QIconItem {
                            anchors.verticalCenter: parent.verticalCenter
                            icon: "list-add"
                            width: theme.mediumIconSize
                            height: width
                        }
                        PlasmaComponents.Label {
                            anchors.verticalCenter: parent.verticalCenter
                            text: i18n("New Alarm")
                        }
                    }
                }
                onClicked: editAlarm(-1)
            }
        }
    }
}
