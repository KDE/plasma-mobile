/*
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *   SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.2
import Qt5Compat.GraphicalEffects

import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 3.0 as PlasmaComponents3

import org.kde.notificationmanager as NotificationManager

/**
 * Embeddable notification list widget optimized for mobile and touch.
 * Used on the lockscreen and action drawer.
 */
Item {
    id: root

    /**
     * If the notification is in the lockscreen.
     */
    property bool inLockScreen: false

    /**
     * The panel background type for all the notifications within the widget.
     */
    property int panelType: MobileShell.PanelBackground.PanelType.Drawer

    /**
     * The notification model for the widget.
     */
    property var historyModel

    /**
     * The type of notification model used for the widget.
     */
    property int historyModelType

    /**
     * The notification model settings for the widget.
     */
    property var notificationSettings

    /**
     * Whether invoking notification actions requires authentiation of some sort.
     *
     * If set to true, any attempted invoking will trigger the unlockRequested() signal.
     * Any consumers can then call the runPendingAction() function if authenticated to proceed
     * executing the notification action.
     */
    property bool actionsRequireUnlock: false

    /**
     * Top padding of the notification list.
     */
    property int topPadding: 0

    /**
     * Bottom padding of the notification list.
     */
    property int bottomPadding: 0

    /**
     * Header component for notification list.
     */
    property var header

    /**
     * Whether to show the header component.
     */
    property bool showHeader: false

    /**
     * Gives access to the notification list view outside of the notification widget.
     */
    property alias listView: list

    /**
     * Whether the widget has notifications.
     */
    readonly property bool hasNotifications: list.count > 0

    readonly property bool doNotDisturbModeEnabled: !isNaN(notificationSettings.notificationsInhibitedUntil)

    enum ModelType {
        NotificationsModel, // used in the logged-in shell
        WatchedNotificationsModel // used on the lockscreen
    }

    /**
     * Signal emitted when authentication is requested for an action.
     * Listeners should call runPendingAction() if authentication is successful.
     *
     * Only emitted if actionsRequireUnlock is enabled.
     */
    signal unlockRequested()

    /**
     * Run pending action that was pending for authentication when unlockRequested() was emitted.
     */
    function runPendingAction() {
        list.pendingNotificationWithAction.runPendingAction();
    }

    /**
     * Clears the history of the notification model.
     */
    function clearHistory() {
        historyModel.clear(NotificationManager.Notifications.ClearExpired);

        if (historyModel.count === 0) {
            backgroundClicked();
        }
    }

    /**
     * Toggles Do Not Disturb mode.
     */
    function toggleDoNotDisturbMode() {
        if (doNotDisturbModeEnabled) {
            notificationSettings.defaults();
        } else {
            var until = new Date();

            until.setFullYear(until.getFullYear() + 1);

            notificationSettings.notificationsInhibitedUntil = until;
        }

        notificationSettings.save();
    }

    /**
     * Open the system notification settings.
     */
    function openNotificationSettings() {
        MobileShell.ShellUtil.executeCommand("plasma-open-settings kcm_notifications");
    }

    P5Support.DataSource {
        id: timeDataSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60000 // 1 min
        intervalAlignment: P5Support.Types.AlignToMinute
    }

    ListView {
        id: list
        model: historyModel

        clip: true

        currentIndex: 0

        property var pendingNotificationWithAction

        readonly property int animationDuration: ShellSettings.Settings.animationsEnabled ? Kirigami.Units.longDuration : 0

        // If a screen overflow occurs, fix height in order to maintain tool buttons in place.
        readonly property bool listOverflowing: listHeight + spacing >= root.height
        readonly property int listHeight: contentItem.childrenRect.height

        bottomMargin: spacing
        height: count === 0 ? (root.topPadding + (showHeader ? root.header.height + listHeight + Kirigami.Units.largeSpacing * 2 : 0)) : (listOverflowing ? root.height : listHeight + bottomMargin)

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        boundsBehavior: Flickable.DragAndOvershootBounds
        spacing: Kirigami.Units.largeSpacing

        // TODO keyboard focus
        highlightMoveDuration: 0
        highlightResizeDuration: 0
        highlight: Item {}

        // media control widget
        // added to the notification list when in landscape mode
        Component {
            id: headerComponent
            Item {
                width: parent.width

                MobileShell.BaseItem {
                    id: headerComponentProxy

                    contentItem: showHeader ? root.header : null
                    y: root.topPadding + Kirigami.Units.largeSpacing

                    width: parent.width - Kirigami.Units.gridUnit * 2
                    anchors.left: parent.left
                    anchors.leftMargin: Kirigami.Units.gridUnit
                }
            }
        }

        // set bottom padding for the notification list
        Component {
            id: footerComponent
            Item {
                width: parent.width
                height: root.bottomPadding
            }
        }

        header: headerComponent

        footer: footerComponent

        section {
            property: "isGroup"
            criteria: ViewSection.FullString
        }

        PlasmaExtras.PlaceholderMessage {
            anchors.centerIn: parent
            width: parent.width - (Kirigami.Units.gridUnit * 4)

            text: i18n("Notification service not available")
            visible: list.count === 0 && !NotificationManager.Server.valid && historyModelType === NotificationsModelType.NotificationsModel

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

        // Run every time an item is visually added to the list, thus when `Show n more` button is clicked as well.
        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: list.animationDuration }
        }
        // Run every time an item is displaced, such as when the order is scrambled due to a group expansion.
        displaced: Transition {
            NumberAnimation { properties: "y"; duration: list.animationDuration }
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

            // Instantly re-align items after group expansion.
            forceLayout();
        }

        delegate: Loader {
            id: delegateLoader

            anchors {
                left: parent ? parent.left : undefined
                leftMargin: Kirigami.Units.gridUnit
                right: parent ? parent.right : undefined
                rightMargin: Kirigami.Units.gridUnit
            }

            height: model.isGroup ? groupDelegate.height : notificationDelegate.height
            sourceComponent: model.isGroup ? groupDelegate : notificationDelegate
            asynchronous: true

            required property var model
            required property int index

            // We have to do this here in order to control the animation before the item is completely removed
            ListView.onRemove: SequentialAnimation {
                PropertyAction { target: delegateLoader; property: "ListView.delayRemove"; value: true }
                NumberAnimation { target: delegateLoader; property: "opacity"; to: 0.0; duration: list.animationDuration }
                PropertyAction { target: delegateLoader; property: "ListView.delayRemove"; value: false }
            }

            // adjust top paddding for media control widget
            Component {
                id: groupDelegate

                Column {
                    spacing: Kirigami.Units.smallSpacing

                    height: headerSpace.height + groupHeader.height

                    Item {
                        id: headerSpace
                        width: parent.width
                        height: index == 0 ? root.topPadding + (showHeader && root.header.visible ? root.header.height + Kirigami.Units.largeSpacing * 2 : 0) : 0
                        visible: index == 0
                    }

                    NotificationGroupHeader {
                        id: groupHeader
                        applicationName: model.applicationName
                        applicationIconSource: model.applicationIconName
                        originName: model.originName || ""
                    }
                }
            }

            Component {
                id: notificationDelegate

                Column {
                    spacing: Kirigami.Units.smallSpacing

                    height: headerSpace.height + notificationItem.height + showMoreLoader.height

                    Item {
                        id: headerSpace
                        width: parent.width
                        height: index == 0 ? root.topPadding + (showHeader && root.header.visible ? root.header.height + Kirigami.Units.largeSpacing * 2 : 0) : 0
                        visible: index == 0
                    }

                    NotificationItem {
                        id: notificationItem
                        width: parent.width
                        height: implicitHeight

                        inLockScreen: root.inLockScreen
                        panelType: root.panelType

                        model: delegateLoader.model
                        modelIndex: delegateLoader.index
                        notificationsModel: root.historyModel
                        notificationsModelType: root.historyModelType
                        timeSource: timeDataSource

                        requestToInvoke: root.actionsRequireUnlock
                        onRunActionRequested: {
                            list.pendingNotificationWithAction = notificationItem;
                            root.unlockRequested();
                        }
                    }

                    // Every item has got an instance of this loader, but it becomes active only for last ones that take place in big enough groups.
                    Loader {
                        id: showMoreLoader

                        height: visible ? implicitHeight : 0
                        opacity: 0.0
                        visible: active

                        asynchronous: true

                        active: {
                            // if we have the WatchedNotificationsModel, we don't have notification grouping support
                            if (typeof model.groupChildrenCount === 'undefined')
                                return false;

                            return (model.groupChildrenCount > model.expandedGroupChildrenCount || model.isGroupExpanded)
                            && delegateLoader.ListView.nextSection != delegateLoader.ListView.section;
                        }

                        // state + transition: animates the item when it becomes visible. Fade off is handled by above ListView.onRemove.
                        states: State {
                            name: "VISIBLE"
                            when: showMoreLoader.status == Loader.Ready
                            PropertyChanges { target: showMoreLoader; opacity: 1.0 }
                        }
                        transitions: Transition {
                            to: "VISIBLE"
                            SequentialAnimation {
                                PauseAnimation { duration: list.animationDuration * 2 }
                                NumberAnimation { properties: "opacity"; duration: list.animationDuration }
                            }
                        }

                        sourceComponent: PlasmaComponents3.ToolButton {
                            icon.name: model.isGroupExpanded ? "arrow-up" : "arrow-down"
                            text: model.isGroupExpanded ? i18n("Show Fewer")
                            : i18nc("Expand to show n more notifications",
                                    "Show %1 More", (model.groupChildrenCount - model.expandedGroupChildrenCount))
                            onClicked: {
                                list.setGroupExpanded(model.index, !model.isGroupExpanded)
                            }
                        }
                    }
                }
            }
        }
    }
}
