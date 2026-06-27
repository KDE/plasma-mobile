/*
    SPDX-FileCopyrightText: 2024 Micah Stanley <stanleymicah@proton.me>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Window

import org.kde.kirigami as Kirigami

import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.notificationmanager as NotificationManager
import org.kde.plasma.clock

import org.kde.layershell 1.0 as LayerShell

/**
 * This sets up and manages the notification popups
 */
Window {
    id: notificationPopupManager

    width: Screen.width
    height: Screen.height
    visible: true
    color: isPopupDrawerOpen && visible ? backgroundColor : "transparent"

    LayerShell.Window.anchors: LayerShell.Window.AnchorTop | LayerShell.Window.AnchorHorizontalCenter
    LayerShell.Window.layer: LayerShell.Window.LayerOverlay
    LayerShell.Window.exclusionZone: -1
    LayerShell.Window.keyboardInteractivity: keyboardInteractivity

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    Kirigami.Theme.inherit: false

    property var notificationModelType
    property var popupNotificationsModel
    property QtObject notificationSettings
    property QtObject tasksModel
    property Clock clockSource
    property bool inhibited

    property var keyboardInteractivity: LayerShell.Window.KeyboardInteractivityNone
    property bool isPopupDrawerOpen: false // this toggles whether to show all the active popup notifications at ones in a list
    property real popupDrawerAnimationValue: notificationPopupManager.isPopupDrawerOpen ? 1 : 0 // animate notifications entering and exiting the drawer
    property var currentNotification: notifications.count > 0 ? notifications.itemAtIndex(0) : null

    readonly property int popupWidth: Math.min(Kirigami.Units.gridUnit * 20, Screen.width - Kirigami.Units.gridUnit * 2)
    readonly property real openOffset: (Kirigami.Units.smallSpacing * 3) + Kirigami.Units.gridUnit
    readonly property color backgroundColor: Qt.darker(Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.95), 1.05)

    signal timeChanged

    onWidthChanged: {
        if (visible) {
            notificationPopupManager.updateTouchArea();
        }
    }

    onCurrentNotificationChanged: {
        if (currentNotification) {
            updateTouchArea();
        }
    }

    Component.onCompleted: ShellUtil.setInputTransparent(notificationPopupManager, true)

    Binding {
        target: MobileShellState.ShellDBusClient
        property: "isNotificationPopupDrawerOpen"
        value: notificationPopupManager.isPopupDrawerOpen
    }

    Behavior on popupDrawerAnimationValue {
        NumberAnimation {
            duration: Kirigami.Units.veryLongDuration * 1.5
            easing.type: Easing.OutQuint
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Kirigami.Units.veryLongDuration * 1.5
            easing.type: Easing.OutExpo
        }
    }

    NumberAnimation {
        id: popupDrawerCloseAnimation
        target: notifications
        property: "contentY"
        to: notifications.originY - notifications.topMargin
        duration: Kirigami.Units.veryLongDuration * 1
        easing.type: Easing.OutExpo
    }

    // Update the window touch region to encapsulate the notification area or the whole screen depending on the 'isPopupDrawerOpen' state
    function updateTouchArea() {
        ShellUtil.setInputTransparent(notificationPopupManager, false);
        notificationPopupManager.currentNotification = Qt.binding(() => notifications.count > 0 ? notifications.itemAtIndex(0) : null);

        if (!(notifications.count > 0) || !currentNotification) {
            return;
        }

        if (isPopupDrawerOpen) {
            // reset the touch layout to use the entire screen dimensions
            ShellUtil.setInputRegion(notificationPopupManager, Qt.rect(0, 0, 0, 0));
        } else {
            let currentNotificationMappedToView = currentNotification.mapToItem(notifications, 0, 0);
            ShellUtil.setInputRegion(
                notificationPopupManager,
                Qt.rect(
                    currentNotificationMappedToView.x,
                    currentNotificationMappedToView.y,
                    currentNotification.width,
                    currentNotification.height + Kirigami.Units.gridUnit * 1.5
                )
            );
        }
    }

    ListView {
        id: notifications
        anchors.fill: parent
        topMargin: notificationPopupManager.openOffset
        bottomMargin: Kirigami.Units.gridUnit * 4
        spacing: 0

        model: popupNotificationsModel
        interactive: notificationPopupManager.isPopupDrawerOpen

        cacheBuffer: Math.max(notifications.height * 0.25, ((currentNotification ? currentNotification.height : Kirigami.Units.gridUnit * 3) * 3) - notifications.height)
        displayMarginEnd: Math.max(notifications.height, ((currentNotification ? currentNotification.height : Kirigami.Units.gridUnit * 3) * 3) - notifications.height)

        // internal tracking states for gesture thresholds
        property bool isAtBeginning: false
        property bool isAtEnd: false
        property int lastCount: count

        // event handlers
        onDragStarted: {
            isAtBeginning = notifications.atYBeginning;
            isAtEnd = notifications.atYEnd;
        }
        onFlickStarted: {
            isAtBeginning = notifications.atYBeginning;
            isAtEnd = notifications.atYEnd;
        }
        onDragEnded: notifications.checkDismiss()
        onFlickEnded: notifications.checkDismiss()

        onOriginYChanged: {
            resetContentVerticalAnimation.to = notifications.originY - notifications.topMargin;
            if (resetContentVerticalAnimation.running) {
                resetContentVerticalAnimation.restart();
            }
            updateTouchArea();
        }

        onCountChanged: {
            if (count == 0) {
                ShellUtil.setInputTransparent(notificationPopupManager, true);
                notificationPopupManager.isPopupDrawerOpen = false;
                return;
            }
            notificationPopupManager.updateTouchArea();
            lastCount = count;
        }

        NumberAnimation on contentY {
            id: resetContentVerticalAnimation
            running: false
            to: notifications.originY - notifications.topMargin
            duration: Kirigami.Units.veryLongDuration * 1.5
            easing.type: Easing.OutExpo
            onFinished: updateTouchArea()
        }

        // capture taps behind the notifications to close the drawer
        TapHandler {
            onTapped: notifications.dismiss()
        }

        // helper functions
        function checkDismiss() {
            let dismissFromTop = isAtBeginning && notifications.verticalOvershoot < -Kirigami.Units.gridUnit;
            let dismissFromBottom = isAtEnd && notifications.verticalOvershoot > Kirigami.Units.gridUnit;
            if (dismissFromTop || dismissFromBottom) {
                notifications.dismiss();
            }
        }

        function dismiss() {
            if (!notificationPopupManager.isPopupDrawerOpen) return;

            notificationPopupManager.isPopupDrawerOpen = false;
            notificationPopupManager.updateTouchArea();
            resetContentVerticalAnimation.restart();
        }

        delegate: NotificationPopup {
            id: notificationPopup
            width: notificationPopupManager.popupWidth
            z: notifications.count - index

            transform: [
                Translate {
                    x: (notificationPopupManager.width - notificationPopupManager.popupWidth) * 0.5
                }
            ]

            keyboardInteractivity: notificationPopupManager.keyboardInteractivity
            popupDrawerOpened: notificationPopupManager.isPopupDrawerOpen
            notificationsModel: popupNotificationsModel
            notificationsModelType: notificationModelType
            timeDataSource: clockSource
            notificationCount: notifications.count
            topPopupOffset: notificationPopupManager.openOffset
            popupDrawerAnimationValue: notificationPopupManager.popupDrawerAnimationValue
            timeout: model.timeout

            currentPopupHeight: (notifications.count > 0 && notificationPopup.index > 0 && currentNotification) ? currentNotification.cardHeight : Kirigami.Units.gridUnit * 6
            currentPopupDragOffset: (notifications.count > 0 && index > 0 && currentNotification) ? currentNotification.dragOffset : 0
            offsetFromCurrentPopup: notifications.originY - notificationPopup.y

            defaultTimeout: notificationSettings.popupTimeout + (model.urls && model.urls.length > 0 ? 5000 : 0)
            dismissTimeout: !notificationSettings.permanentJobPopups
                && model.type === NotificationManager.Notifications.JobType
                && model.jobState !== NotificationManager.Notifications.JobStateStopped
                ? defaultTimeout : 0

            onUpdateTouchArea: notificationPopupManager.updateTouchArea()
            onOpenPopupDrawer: notificationPopupManager.isPopupDrawerOpen = true
            onSetKeyboardFocus: notificationPopupManager.keyboardInteractivity = LayerShell.Window.KeyboardInteractivityOnDemand
            onRemoveKeyboardFocus: notificationPopupManager.keyboardInteractivity = LayerShell.Window.KeyboardInteractivityNone
            onDismissClicked: model.dismissed = true

            onExpired: {
                if (model.resident) {
                    // When resident, only mark it as expired so the popup disappears
                    // but don't actually invalidate the notification
                    model.expired = true;
                } else {
                    if (notificationModelType === NotificationsModelType.WatchedNotificationsModel) {
                        popupNotificationsModel.expire(model.notificationId);
                    } else if (notificationModelType === NotificationsModelType.NotificationsModel) {
                        popupNotificationsModel.expire(popupNotificationsModel.index(index, 0));
                    }
                }
            }

            Component.onCompleted: {
                if (model.type === NotificationManager.Notifications.NotificationType && model.desktopEntry) {
                    // Register apps that were seen spawning a popup so they can be configured later
                    // Apps with notifyrc can already be configured anyway
                    if (!model.notifyRcName) {
                        notificationSettings.registerKnownApplication(model.desktopEntry);
                        notificationSettings.save();
                    }
                }

                // Tell the model that we're handling the timeout now
                popupNotificationsModel.stopTimeout(popupNotificationsModel.index(index, 0));
            }
        }
    }
}
