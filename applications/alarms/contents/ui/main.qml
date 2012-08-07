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
    PlasmaCore.Svg {
        id: separatorSvg
        imagePath: "widgets/line"
    }

    KLocale.Locale {
        id: locale
    }

    //FIXME: should be prettier
    Item {
        y: -alarmList.contentY
        width: alarmListScroll.width
        height: alarmList.contentHeight + theme.defaultFont.mSize.height * 2
        PlasmaCore.SvgItem {
            svg: separatorSvg
            elementId: "vertical-line"
            width: naturalSize.width
            anchors {
                top: parent.top
                bottom: parent.bottom
            }

            x: alarmListScroll.width / 4 - 5
        }
        PlasmaCore.SvgItem {
            svg: separatorSvg
            elementId: "vertical-line"
            width: naturalSize.width
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            x: (alarmListScroll.width / 4) * 2 - 5
        }
        PlasmaCore.SvgItem {
            svg: separatorSvg
            elementId: "vertical-line"
            width: naturalSize.width
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            x: (alarmListScroll.width / 4) * 3 - 5
        }
    }
    PlasmaExtras.ScrollArea {
        id: alarmListScroll
        anchors.fill: parent
        clip: true

        ListView {
            id: alarmList
            model: PlasmaCore.DataModel {
                dataSource: alarmsSource
            }
            header: PlasmaComponents.ListItem {
                sectionDelegate: true
                Row {
                    spacing: 8
                    width: parent.width - theme.mediumIconSize

                    PlasmaComponents.Label {
                        width: parent.width/4
                        text: i18n("Time")
                    }

                    PlasmaComponents.Label {
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width/4
                        text: i18n("Message")
                    }
                    PlasmaComponents.Label {
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width/4
                        text: i18n("Recurrence")
                    }
                    PlasmaComponents.Label {
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width/4
                        text: i18n("Audio")
                    }
                }
            }
            delegate: AlarmDelegate {
                
            }
            footer: PlasmaComponents.ListItem {
                enabled: true
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
            }
        }
    }
}
