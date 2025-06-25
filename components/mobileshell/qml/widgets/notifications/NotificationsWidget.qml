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
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 3.0 as PlasmaComponents3

import org.kde.notificationmanager as NotificationManager

/**
 * Embeddable notification list widget optimized for mobile and touch.
 * Used on the lockscreen and action drawer.
 */
Item {
    id: root

    property bool inLockscreen: false

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
     * Emitted when the background is clicked (not a notification or other element).
     */
    signal backgroundClicked()

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
            // We just have a global toggle, so set it to a really long time (in this case, a year)
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

    // Implement listening to system "do not disturb" requests
    Connections {
        target: MobileShellState.ShellDBusClient

        function onDoNotDisturbChanged() {
            if (root.doNotDisturbModeEnabled !== MobileShellState.ShellDBusClient.doNotDisturb) {
                root.toggleDoNotDisturbMode();
            }
        }
    }

    P5Support.DataSource {
        id: timeDataSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60000 // 1 min
        intervalAlignment: P5Support.Types.AlignToMinute
    }

    // implement background clicking signal
    MouseArea {
        anchors.fill: parent
        onClicked: backgroundClicked()
        z: -1 // ensure that this is below notification items so we don't steal button clicks
    }

    ListView {
        id: list
        model: historyModel

        clip: true

        currentIndex: 0

        property var pendingNotificationWithAction

        readonly property int animationDuration: ShellSettings.Settings.animationsEnabled ? Kirigami.Units.longDuration : 0

        // If a screen overflow occurs, fix height in order to maintain tool buttons in place.
        readonly property bool listOverflowing: contentItem.childrenRect.height + toolButtons.height + spacing >= root.height

        bottomMargin: spacing
        height: count === 0 ? 0 : (listOverflowing ? root.height - toolButtons.height : contentItem.childrenRect.height + bottomMargin)

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        boundsBehavior: Flickable.StopAtBounds
        spacing: Kirigami.Units.largeSpacing

        // TODO keyboard focus
        highlightMoveDuration: 0
        highlightResizeDuration: 0
        highlight: Item {}

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

            Component {
                id: groupDelegate
                NotificationGroupHeader {
                    applicationName: model.applicationName
                    applicationIconSource: model.applicationIconName
                    originName: model.originName || ""
                }
            }

            Component {
                id: notificationDelegate

                Column {
                    spacing: Kirigami.Units.smallSpacing

                    height: notificationItem.height + showMoreLoader.height

                    NotificationItem {
                        id: notificationItem
                        width: parent.width
                        height: implicitHeight

                        inLockscreen: root.inLockscreen

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

    Item {
        id: toolButtons
        height: visible ? spacer.height + toolLayout.height + toolLayout.anchors.topMargin + toolLayout.anchors.bottomMargin : 0

        // do not show on lockscreen
        visible: !root.actionsRequireUnlock

        anchors {
            top: list.bottom
            left: parent.left
            right: parent.right
        }

        Rectangle {
            id: spacer
            anchors.left: parent.left
            anchors.right: parent.right

            visible: list.listOverflowing
            height: 1
            opacity: 0.25
            color: Kirigami.Theme.textColor
        }

        RowLayout {
            id: toolLayout

            anchors {
                top: spacer.bottom
                right: parent.right
                left: parent.left
                leftMargin: Kirigami.Units.largeSpacing
                rightMargin: Kirigami.Units.largeSpacing
                topMargin: list.spacing
                bottomMargin: list.spacing
            }

            PlasmaComponents3.ToolButton {
                id: clearButton

                Layout.alignment: Qt.AlignCenter

                visible: hasNotifications

                font.bold: true
                font.pointSize: Kirigami.Theme.smallFont.pointSize

                icon.name: "edit-clear-history"
                text: i18n("Clear All Notifications")
                onClicked: clearHistory()
            }
        }
    }
}
