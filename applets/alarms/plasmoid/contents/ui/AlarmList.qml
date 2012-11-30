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
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.locale 0.1 as KLocale
import org.kde.qtextracomponents 0.1

PlasmaComponents.Page {
    id: root
    clip: true


    property Item panelBackground
    Connections {
        target: plasmoid
        onFormFactorChanged: {
            if (plasmoid.formFactor == plasmoid.Application) {
                root.panelBackground = panelBackgroundComponent.createObject(root)
            } else {
                appBackground.destroy()
            }
        }
    }

    PlasmaExtras.ScrollArea {
        id: alarmListScroll
        anchors.fill: parent

        ListView {
            id: alarmList
            model: PlasmaCore.SortFilterModel {
                sortRole: "dateTime"
                sourceModel: PlasmaCore.DataModel {
                    dataSource: alarmsSource
                }
            }

            header: PlasmaComponents.ListItem {
                id: headerItem
                sectionDelegate: true

                PlasmaExtras.Heading {
                    anchors.horizontalCenter: parent.horizontalCenter
                    level: 1
                    text: (alarmsSource.sources.length == 0) ? i18n("No alarms yet") : i18n("Alarms")
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
