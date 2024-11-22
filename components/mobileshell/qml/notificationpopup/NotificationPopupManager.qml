/*
 *  SPDX-FileCopyrightText: 2024 Micah Stanley <stanleymicah@proton.me>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Window

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState

import org.kde.layershell 1.0 as LayerShell

import org.kde.notificationmanager as NotificationManager
import org.kde.plasma.plasma5support 2.0 as P5Support

import QtQuick.Controls as Controls
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.taskmanager 0.1 as TaskManager


/**
 * This sets up and manages the notification popups
 */
Window {
    id: notificationPopupManager

    readonly property int popupWidth: Math.min(Kirigami.Units.gridUnit * 20, Screen.width - Kirigami.Units.gridUnit * 2)
    readonly property real openOffset: Kirigami.Units.gridUnit + Kirigami.Units.smallSpacing * 3
    readonly property int longestLength: Math.max(Screen.width, Screen.height)
    property var keyboardInteractivity: LayerShell.Window.KeyboardInteractivityNone

    LayerShell.Window.scope: "notification"
    LayerShell.Window.anchors: LayerShell.Window.AnchorTop | LayerShell.Window.AnchorHorizontalCenter
    LayerShell.Window.layer: LayerShell.Window.LayerOverlay
    LayerShell.Window.exclusionZone: -1
    LayerShell.Window.keyboardInteractivity: keyboardInteractivity

    // This toggles whether to show all the active popup notifications at ones in a list
    property bool popupDrawerOpened: false

    property var notificationModelType
    property QtObject notificationSettings
    property QtObject popupNotificationsModel
    property QtObject tasksModel
    property QtObject timeSource
    property bool inhibited

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    readonly property color backgroundColor: Qt.darker(Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.95), 1.05)
    color: popupDrawerOpened && visible ? backgroundColor : "transparent"
    Behavior on color {
        ColorAnimation {
            duration: Kirigami.Units.veryLongDuration * 1.5
            easing.type: Easing.OutExpo
        }
    }

    width: longestLength
    height: longestLength

    signal timeChanged

    Component.onCompleted: ShellUtil.setInputTransparent(notificationPopupManager, true)

    // Update the window touch region to encapsulate the notification area or the whole screen depending on the 'popupDrawerOpened' state
    function updateTouchArea() {
        ShellUtil.setInputTransparent(notificationPopupManager, false);
        if (popupDrawerOpened) {
            ShellUtil.setInputRegion(notificationPopupManager, Qt.rect(0, 0, 0, 0));
        } else {
            // get the height of the popup directly to ensure we get the lastest version
            let popupHeight = Kirigami.Units.gridUnit * 6;
            let currentPopup = notifications.objectAt(notifications.currentPopupIndex);
            if (currentPopup) {
                popupHeight = currentPopup.popupHeight;
            } else {
                console.warn("popupNotification: could not retrieve current popup height - falling back to a default value")
            }

            ShellUtil.setInputRegion(notificationPopupManager, Qt.rect((notificationPopupManager.width - notificationPopupManager.popupWidth - Kirigami.Units.gridUnit) / 2, openOffset - Kirigami.Units.gridUnit / 2, notificationPopupManager.popupWidth + Kirigami.Units.gridUnit, popupHeight + Kirigami.Units.gridUnit * ((notifications.count - notifications.currentPopupIndex > 1) ? 4 : 1)));
        }
    }

    // parent the popup notifications inside a Flickable so that they can be scrollable when the drawer state is active
    Flickable {
        id: flickable
        width: notificationPopupManager.width
        height: Screen.height
        contentHeight: notifications.fullHeight + notificationPopupManager.openOffset
        boundsBehavior: Flickable.DragAndOvershootBounds
        bottomMargin: Kirigami.Units.gridUnit * 6

        interactive: notificationPopupManager.popupDrawerOpened

        onDragEnded: flickable.checkDismiss();
        onFlickEnded: flickable.checkDismiss();
        onDragStarted: {
            notifications.recalculateHeight();
            atBeginning = flickable.atYBeginning;
            atEnd = flickable.atYEnd;
        }
        onFlickStarted: {
            notifications.recalculateHeight();
            atBeginning = flickable.atYBeginning;
            atEnd = flickable.atYEnd;
        }

        property bool atBeginning: false
        property bool atEnd: false

        function checkDismiss() {
            let dismissFromTop = atBeginning && flickable.verticalOvershoot < -Kirigami.Units.gridUnit;
            let dismissFromBottom = atEnd && flickable.verticalOvershoot > Kirigami.Units.gridUnit;
            if (dismissFromTop || dismissFromBottom) {
                flickable.dismiss();
            }
        }

        function dismiss() {
            notificationPopupManager.popupDrawerOpened = false;
            notificationPopupManager.updateTouchArea();
            resetContentY.running = true;
        }

        NumberAnimation on contentY {
            id: resetContentY
            running: false
            to: 0
            duration: Kirigami.Units.veryLongDuration * 1.5
            easing.type: Easing.OutExpo
        }

        MouseArea {
            // capture taps behind the notifications to close the drawer
            id: item
            anchors.left: parent.left
            anchors.right: parent.right
            width: notificationPopupManager.width
            height: Math.max(notifications.fullHeight, Screen.height)

            onReleased: flickable.dismiss();

            Instantiator {
                id: notifications
                model: popupNotificationsModel

                // get the height, drag offset, and idx of the current popup notifition and make it easily accessible by all popup notifications
                property int currentPopupHeight: (count > 0 && currentPopupIndex < count && objectAt(currentPopupIndex)) ? objectAt(currentPopupIndex).popupHeight : 0;
                property int currentDragOffset: 0
                property int currentPopupIndex: 0

                // calculate the full height of all the notifications combine for scrolling purposes
                property int fullHeight: 0
                onCountChanged: {
                    if (count == 0) {
                        ShellUtil.setInputTransparent(notificationPopupManager, true);
                        notificationPopupManager.visible = false;
                        notificationPopupManager.popupDrawerOpened = false;
                        fullHeight = 0;
                        return;
                    }
                    notificationPopupManager.visible = true;
                    notifications.recalculateHeight();
                }

                function recalculateHeight() {
                    let findHeight = 0
                    for (var i = 0; i < count; i++)  {
                        findHeight += notifications.objectAt(i).popupHeight + Kirigami.Units.gridUnit;
                    }
                    fullHeight = findHeight;
                }

                delegate: NotificationPopup {
                    id: popup

                    anchors.horizontalCenter: parent.horizontalCenter
                    z: notifications.count - index

                    popupWidth: notificationPopupManager.popupWidth
                    openOffset: notificationPopupManager.openOffset

                    keyboardInteractivity: notificationPopupManager.keyboardInteractivity
                    popupNotifications: notifications
                    popupIndex: index

                    popupDrawerOpened: notificationPopupManager.popupDrawerOpened

                    popupModel: model
                    notificationsModel: popupNotificationsModel
                    notificationsModelType: notificationModelType
                    timeDataSource: timeSource

                    timeout: model.timeout

                    onUpdateTouchArea: notificationPopupManager.updateTouchArea()

                    onSetInputTransparent: ShellUtil.setInputTransparent(notificationPopupManager, true)

                    onOpenPopupDrawer: notificationPopupManager.popupDrawerOpened = true

                    onSetKeyboardFocus: notificationPopupManager.keyboardInteractivity = LayerShell.Window.KeyboardInteractivityOnDemand

                    onRemoveKeyboardFocus: notificationPopupManager.keyboardInteractivity = LayerShell.Window.KeyboardInteractivityNone

                    defaultTimeout: notificationSettings.popupTimeout + (model.urls && model.urls.length > 0 ? 5000 : 0)

                    dismissTimeout: !notificationSettings.permanentJobPopups
                        && model.type === NotificationManager.Notifications.JobType
                        && model.jobState !== NotificationManager.Notifications.JobStateStopped
                        ? defaultTimeout : 0

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

                        item.children.push(this);
                    }
                }
            }
        }
    }
}
