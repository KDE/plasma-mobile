import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1

import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.0 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.dialer 1.0

Kirigami.Page {

    title: i18n("History")

    function secondsToTimeString(seconds) {
        var h = Math.floor(seconds / 3600);
        var m = Math.floor((seconds - (h * 3600)) / 60);
        var s = seconds - h * 3600 - m * 60;
        if(h < 10) h = '0' + h;
        if(m < 10) m = '0' + m;
        if(s < 10) s = '0' + s;
        return '' + h + ':' + m + ':' + s;
    }

    Label {
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
