/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
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

import QtQuick 2.4
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.dialer 1.0

Item {

    function secondsToTimeString(seconds) {
        var h = Math.floor(seconds / 3600);
        var m = Math.floor((seconds - (h * 3600)) / 60);
        var s = seconds - h * 3600 - m * 60;
        if(h < 10) h = '0' + h;
        if(m < 10) m = '0' + m;
        if(s < 10) s = '0' + s;
        return '' + h + ':' + m + ':' + s;
    }

    PlasmaComponents.Label {
        anchors.centerIn: parent
        text: i18n("No recent calls")
        visible: view.count == 0
    }

    ColumnLayout {
        anchors.fill: parent
        visible: view.count > 0
        PlasmaComponents.ToolBar {
            Layout.fillWidth: true
            tools: RowLayout {
                id: toolBarLayout
                PlasmaComponents.TabBar {
                    tabPosition: Qt.TopEdge
                    PlasmaComponents.TabButton {
                        iconSource: "call-start"
                        text: i18n("All")
                        onCheckedChanged: {
                            if (checked) {
                                filterModel.setFilterFixedString("")
                            }
                        }
                    }
                    PlasmaComponents.TabButton {
                        iconSource: "list-remove"
                        text: i18n("Missed")
                        onCheckedChanged: {
                            if (checked) {
                                filterModel.setFilterFixedString("0")
                            }
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
                PlasmaComponents.Button {
                    text: i18n("Clear")
                    onClicked: historyModel.clear()
                }
            }
        }
        PlasmaExtras.ScrollArea {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ListView {
                id: view
                model: CallHistorySortFilterModel {
                    id: filterModel
                    sourceModel: historyModel
                    filterRole: CallHistoryModel.CallTypeRole
                    sortRole: CallHistoryModel.TimeRole
                    Component.onCompleted: sort(0, Qt.DescendingOrder)
                }
                section {
                    property: "date"
                    delegate: PlasmaComponents.ListItem {
                        id: sectionItem
                        sectionDelegate: true
                        PlasmaComponents.Label {
                            text: Qt.formatDate(section, Qt.locale().dateFormat(Locale.LongFormat));
                        }
                    }
                }
                delegate: HistoryDelegate {}
            }
        }
    }
}
