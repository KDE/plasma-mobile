/*
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *   SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtGraphicalEffects 1.12

import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 3.0 as PlasmaComponents3

import org.kde.notificationmanager 1.0 as NotificationManager

/**
 * Embeddable notification list widget optimized for mobile and touch.
 * Used on the lockscreen and action drawer.
 */
Item {
    id: root
    
    property var historyModel: []
    property var notificationSettings: NotificationManager.Settings {}
    
    readonly property bool hasNotifications: list.count > 0
    
    function clearHistory() {
        historyModel.clear(NotificationManager.Notifications.ClearExpired);
    }

    function openNotificationSettings() {
        MobileShell.ShellUtil.executeCommand("plasma-open-settings kcm_notifications");
    }

    PlasmaCore.DataSource {
        id: timeDataSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60000 // 1 min
        intervalAlignment: PlasmaCore.Types.AlignToMinute
    }
    
    ListView {
        id: list
        model: historyModel
        currentIndex: -1
        
        boundsBehavior: Flickable.StopAtBounds
        spacing: Kirigami.Units.largeSpacing
        
        anchors.fill: parent

        // TODO keyboard focus
        highlightMoveDuration: 0
        highlightResizeDuration: 0
        highlight: Item {} 
        
        section {
            property: "isInGroup"
            criteria: ViewSection.FullString
        }

        PlasmaExtras.PlaceholderMessage {
            anchors.centerIn: parent
            width: parent.width - (PlasmaCore.Units.largeSpacing * 4)

            text: i18n("Notification service not available")
            visible: list.count === 0 && !NotificationManager.Server.valid

            PlasmaComponents3.Label {
                // Checking valid to avoid creating ServerInfo object if everything is alright
                readonly property NotificationManager.ServerInfo currentOwner: !NotificationManager.Server.valid ? NotificationManager.Server.currentOwner : null
                // PlasmaExtras.PlaceholderMessage is internally a ColumnLayout, so we can use Layout.whatever properties here
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: currentOwner ? i18nc("Vendor and product name", "Notifications are currently provided by '%1 %2'", currentOwner.vendor, currentOwner.name) : ""
                visible: currentOwner && currentOwner.vendor && currentOwner.name
            }
        }
        
        add: Transition {
            SequentialAnimation {
                PropertyAction { property: "opacity"; value: 0 }
                PauseAnimation { duration: PlasmaCore.Units.longDuration }
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: PlasmaCore.Units.longDuration }
                    NumberAnimation { property: "height"; from: 0; duration: PlasmaCore.Units.longDuration }
                }
            }
        }
        addDisplaced: Transition {
            NumberAnimation { properties: "y"; duration:  PlasmaCore.Units.longDuration }
        }
        removeDisplaced: Transition {
            SequentialAnimation {
                PauseAnimation { duration: PlasmaCore.Units.longDuration }
                NumberAnimation { properties: "y"; duration:  PlasmaCore.Units.longDuration }
            }
        }

        function isRowExpanded(row) {
            var idx = historyModel.index(row, 0);
            return historyModel.data(idx, NotificationManager.Notifications.IsGroupExpandedRole);
        }

        function setGroupExpanded(row, expanded) {
            var rowIdx = historyModel.index(row, 0);
            var persistentRowIdx = historyModel.makePersistentModelIndex(rowIdx);
            var persistentGroupIdx = historyModel.makePersistentModelIndex(historyModel.groupIndex(rowIdx));

            historyModel.setData(rowIdx, expanded, NotificationManager.Notifications.IsGroupExpandedRole);

            // If the current item went away when the group collapsed, scroll to the group heading
            if (!persistentRowIdx || !persistentRowIdx.valid) {
                if (persistentGroupIdx && persistentGroupIdx.valid) {
                    list.positionViewAtIndex(persistentGroupIdx.row, ListView.Contain);
                    // When closed via keyboard, also set a sane current index
                    if (list.currentIndex > -1) {
                        list.currentIndex = persistentGroupIdx.row;
                    }
                }
            }
        }
        
        delegate: Loader {
            id: delegateLoader
            width: list.width
            sourceComponent: model.isGroup ? groupDelegate : notificationDelegate
            
            required property var model
            required property int index
            
            Component {
                id: groupDelegate
                NotificationGroupHeader {
                    applicationName: model.applicationName
                    applicationIconSource: model.applicationIconName
                    originName: model.originName || ""
                    timeSource: timeDataSource
                }
            }
            
            Component {
                id: notificationDelegate
                ColumnLayout {
                    spacing: PlasmaCore.Units.smallSpacing
                    
                    NotificationItem {
                        Layout.fillWidth: true
                        
                        model: delegateLoader.model
                        modelIndex: delegateLoader.index
                        notificationsModel: historyModel
                        timeSource: timeDataSource
                    }
                    
                    PlasmaComponents3.ToolButton {
                        icon.name: model.isGroupExpanded ? "arrow-up" : "arrow-down"
                        text: model.isGroupExpanded ? i18n("Show Fewer")
                                                    : i18nc("Expand to show n more notifications",
                                                            "Show %1 More", (model.groupChildrenCount - model.expandedGroupChildrenCount))
                        visible: (model.groupChildrenCount > model.expandedGroupChildrenCount || model.isGroupExpanded)
                            && delegateLoader.ListView.nextSection !== delegateLoader.ListView.section
                        onClicked: list.setGroupExpanded(model.index, !model.isGroupExpanded)
                        height: visible ? implicitHeight : 0
                    }
                }
            }
        }
    }
}
