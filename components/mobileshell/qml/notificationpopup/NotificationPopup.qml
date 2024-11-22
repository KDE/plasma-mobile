/*
 *  SPDX-FileCopyrightText: 2024 Micah Stanley <stanleymicah@proton.me>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Window

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState

import org.kde.layershell 1.0 as LayerShell

import org.kde.notificationmanager as NotificationManager
import org.kde.plasma.plasma5support 2.0 as P5Support

Item {
    id: notificationPopup

    readonly property int popupHeight: notificationItem.implicitHeight
    readonly property bool isClosing: notificationItem.state == "closeWithMove" || notificationItem.state == "closeWithScale"
    readonly property real closedOffset: -(popupHeight + Kirigami.Units.smallSpacing)
    // 'popupWidth' and 'openOffset' is set by the 'notificationPopupManager'
    property int popupWidth
    property real openOffset

    // calculate the position needed to at when the expanded drawer is active
    readonly property real fullOpenOffset: popupDrawerOpened ? aboveNotificationFullOffset + aboveNotificationHeight + Kirigami.Units.gridUnit : 0
    property real aboveNotificationFullOffset: 0
    property int aboveNotificationHeight: 0

    // the drag offset on the current popup notification - used to position notification when stacked underneath
    property real currentDragOffset: {
        let current = popupNotifications.currentPopupIndex == notificationPopup.popupIndex;
        return current || popupDrawerOpened ? 0 : Math.max(popupNotifications.currentDragOffset, 0)
    }

    // due to it not looking great to have a notification sliding up while another one is sliding down
    // we use a timer so that the current notification can know to use "closeWithScale" instead
    property Timer queueTimer: Timer {
        interval: Kirigami.Units.veryLongDuration
        running: true
        onTriggered: {
            visible = true;
            updateNotificationPopups();
            checkActionDrawerOpened();
        }
    }

    // The timer for when the notification will dismiss
    Timer {
        id: hideTimer
        interval: notificationPopup.effectiveTimeout
        running: {
            if (interval <= 0) {
                return false;
            }
            if (notificationPopup.preventDismissTimeout) {
                return false;
            }
            if (notificationPopup.inPopupDrawer) {
                return false;
            }
            if (notificationPopup.popupDrawerOpened) {
                return false;
            }
            return true;
        }
        onTriggered: notificationPopup.closePopup()
    }

    // the value of how much time is left, normalized from 1 to 0
    property real remainingTimeProgress: 1
    NumberAnimation on remainingTimeProgress {
        from: 1
        to: 0
        duration: hideTimer.interval
        running: hideTimer.running
    }

    // set the height and width of the notification container with a extra space for starting a drag
    width: popupWidth + Kirigami.Units.gridUnit
    height: popupHeight + Kirigami.Units.gridUnit

    visible: false

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    signal expired()
    signal dismissClicked()
    signal updateTouchArea()
    signal setInputTransparent()
    signal openPopupDrawer()
    signal setKeyboardFocus()
    signal removeKeyboardFocus()

    // animate the notifications entering and exiting the expanded drawer
    property real fullOffsetAn: fullOpenOffset
    Behavior on fullOffsetAn {
        NumberAnimation {
            duration: Kirigami.Units.veryLongDuration * 1.5
            easing.type: Easing.OutExpo
        }
    }

    // when a notification is grouped behind the current Notification
    // we need the y origin to be a the bottom
    // however we need it at the center when "closeWithScale" is used
    // animate this value so that the popup in some situations will not jump around
    property real scaleOriginY: inPopupDrawer && !popupDrawerOpened ? popupNotifications.currentPopupHeight : Math.round(popupHeight / 2)
    Behavior on scaleOriginY {
        NumberAnimation {
            duration: Kirigami.Units.veryLongDuration
            easing.type: Easing.OutExpo
        }
    }

    // the vertical drag offset for the notification popup
    // we drag is released, animate back to 0
    property real dragOffset: 0
    NumberAnimation on dragOffset {
        id: dragOffsetAn
        running: false
        to: 0
        duration: Kirigami.Units.veryLongDuration * 1.5
        easing.type: Easing.OutExpo
    }

    // if the popup height ever changes, update the notification below wiht new height
    // also update the allowed touch area for the main window
    onPopupHeightChanged: {
        let abovePopup = popupNotifications.objectAt(popupIndex + 1)
        if (popupIndex + 1 < popupCount && abovePopup) {
            abovePopup.aboveNotificationHeight = popupHeight;
        }
        if (popupNotifications.currentPopupIndex == notificationPopup.popupIndex && notificationItem.state == "open") {
            notificationPopup.updateTouchArea();
        }
    }

    // if the offset position need in the expanded drawer changes, update the notification below wiht new offset
    onFullOpenOffsetChanged: {
        let abovePopup = popupNotifications.objectAt(popupIndex + 1)
        if (popupIndex + 1 < popupCount && abovePopup) {
            abovePopup.aboveNotificationFullOffset = fullOpenOffset;
        }
    }
    // if the notification is being draged and is the current one
    // update 'currentDragOffset' so all notifications can easily access this value
    onDragOffsetChanged: {
        let abovePopup = popupNotifications.objectAt(popupIndex + 1)
        if (popupNotifications.currentPopupIndex == notificationPopup.popupIndex) {
            popupNotifications.currentDragOffset = dragOffset;
        }
    }
    // if a new notification is added, update the above notification values need for the expanded drawer
    onPopupCountChanged: {
        let abovePopup = popupNotifications.objectAt(popupIndex + 1)
        if (popupIndex + 1 < abovePopup) {
            abovePopup.aboveNotificationHeight = popupHeight;
            abovePopup.aboveNotificationFullOffset = fullOpenOffset;
        }
    }
    // update the current popup index value if the index ever changes.
    onPopupIndexChanged: {
        if (!isClosing && !inPopupDrawer && !waiting) {
            popupNotifications.currentPopupIndex = popupIndex;
        }
    }
    // if the action drawer opens, it is best to dismiss all popup notifications
    onIsActionDrawerOpenChanged: checkActionDrawerOpened()

    property bool isActionDrawerOpen: MobileShellState.ShellDBusClient.isActionDrawerOpen

    property bool waiting: true
    property bool popupDrawerOpened: false
    property bool inPopupDrawer: false

    property var keyboardInteractivity
    property Instantiator popupNotifications
    property int popupCount: popupNotifications.count
    property int popupIndex

    property var popupModel
    property var notificationsModel
    property int notificationsModelType
    property var timeDataSource

    property bool preventDismissTimeout: true
    property int timeout
    property int dismissTimeout

    property int defaultTimeout: 5000
    readonly property int effectiveTimeout: {
        if (timeout === -1) {
            return defaultTimeout;
        }
        if (dismissTimeout) {
            return dismissTimeout;
        }
        return model.timeout;
    }

    // check if the action drawer is opened and the popup is fully created
    // if so, close the popup with a scale effect
    function checkActionDrawerOpened() {
        if (isActionDrawerOpen && popupNotifications.objectAt(popupIndex)) {
            notificationPopup.expired();
            keyboardInteractivity = LayerShell.Window.KeyboardInteractivityNone;
            notificationItem.state = "closeWithScale";
        }
    }

    // show the top most notification in the list and move the rest to the popup drawer
    function updateNotificationPopups() {
        if (popupCount != 1) {
            for (var i = 0; i < popupCount - 1; i++)  {
                popupNotifications.objectAt(i + 1).moveToPopupDrawer();
            }
        }
        popupNotifications.objectAt(0).showNotificationPopup();
        visible = true;
    }

    function showNotificationPopup() {
        if (isClosing) {
            closePopup();
            return;
        }
        if (notificationItem.state != "open") {
            preventDismissTimeout = true;
        }
        waiting = false;
        inPopupDrawer = false;
        popupNotifications.currentPopupIndex = popupIndex;
        visible = true;
        openPopup();
        updateTouchArea();
    }

    function moveToPopupDrawer() {
        if (isClosing) {
            return;
        }
        waiting = false;
        inPopupDrawer = true;
        if (notificationPopup.popupDrawerOpened && notificationItem.state != "inDrawerClosed" && notificationItem.state != "open") {
            notificationItem.offset = openOffset;
            notificationItem.scale = 0.75;
            notificationItem.opacity = 0.0;
        }
        notificationItem.state = "inDrawerClosed";
        notificationPopup.removeKeyboardFocus();
        visible = true;
    }

    function openPopup() {
        if (notificationPopup.popupDrawerOpened && notificationItem.state != "open" && notificationItem.state != "inDrawerClosed") {
            notificationItem.offset = openOffset;
            notificationItem.scale = 0.75;
            notificationItem.opacity = 0.0;
        }
        notificationItem.state = "open";
        notificationPopup.removeKeyboardFocus();
    }

    // if the notification ever expires, close it and move on to the next one in the list.
    property bool isExpired: model.expired
    onIsExpiredChanged: closePopup()

    // this closes the popup notification with the relvent animation while updating the popup below to show, if any exist
    function closePopup() {
        notificationPopup.removeKeyboardFocus();
        notificationPopup.setInputTransparent();
        if (popupIndex + 1 < popupCount) {
            popupNotifications.objectAt(popupIndex + 1).aboveNotificationHeight = 0;
            popupNotifications.objectAt(popupIndex + 1).aboveNotificationFullOffset = 0;
        }

        if (popupCount > 1) {
            let nextNotificationIdx = popupIndex + (popupIndex < popupCount - 1 ? 1 : -1);
            let nextNotification = popupNotifications.objectAt(nextNotificationIdx);

            if (nextNotification != null) {
                nextNotification.showNotificationPopup();
                if (!isExpired) {
                    if (!dragOffsetAn.running && nextNotification.queueTimer.running) {
                        nextNotification.queueTimer.stop();
                        notificationItem.state = "closeWithScale";
                    } else {
                        notificationItem.state = "closeWithMove";
                    }
                    return;
                }
            }
        }
        if (isExpired) {
            notificationItem.close();
            return;
        }
        notificationItem.state = "closeWithMove";
    }

    function calculateResistance(value : double, threshold : int) : double {
        if (value > threshold) {
            return threshold + Math.pow(value - threshold + 1, Math.max(0.8 - (value - threshold) / ((longestLength - threshold) * 15), 0.35));
        } else {
            return value;
        }
    }

    NotificationPopupItem {
        id: notificationItem

        inPopupDrawer: notificationPopup.inPopupDrawer && !notificationPopup.popupDrawerOpened

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        width: notificationPopup.popupWidth
        height: notificationPopup.popupHeight

        model: notificationPopup.popupModel
        modelIndex: notificationPopup.popupIndex
        notificationsModel: notificationPopup.notificationsModel
        notificationsModelType: notificationPopup.notificationsModelType
        timeSource: notificationPopup.timeDataSource

        currentPopupHeight: popupNotifications.currentPopupHeight

        remainingTimeProgress: notificationPopup.remainingTimeProgress
        closeTimerRunning: hideTimer.running

        onDragStart: preventDismissTimeout = true
        onDragEnd: preventDismissTimeout = (keyboardInteractivity == LayerShell.Window.KeyboardInteractivityOnDemand)

        onTakeFocus: {
            notificationPopup.setKeyboardFocus();
            preventDismissTimeout = true;
        }

        onDismissRequested: closePopup()

        property real offset: closedOffset
        property real scale: 1.0
        property real drawerScale: 1 - Math.max(notificationPopup.popupIndex - popupNotifications.currentPopupIndex, 1) * 0.075
        Behavior on drawerScale {
            NumberAnimation {
                duration: Kirigami.Units.veryLongDuration
                easing.type: Easing.OutExpo
            }
        }
        property real drawerAddedOffset: Kirigami.Units.gridUnit * 0.5 * Math.max(notificationPopup.popupIndex - popupNotifications.currentPopupIndex, 1)
        Behavior on drawerAddedOffset {
            NumberAnimation {
                duration: Kirigami.Units.veryLongDuration
                easing.type: Easing.OutExpo
            }
        }
        property real drawerOpacity: (Math.max(notificationPopup.popupIndex - popupNotifications.currentPopupIndex, 1) > 2) ? 0 : 1
        Behavior on drawerOpacity {
            NumberAnimation {
                duration: Kirigami.Units.veryLongDuration
                easing.type: Easing.OutExpo
            }
        }

        opacity: 1.0

        state: ""

        states: [
            State {
                name: "open"
                PropertyChanges {
                    target: notificationItem; offset: notificationPopup.openOffset
                }
                PropertyChanges {
                    target: notificationItem; scale: 1.0
                }
                PropertyChanges {
                    target: notificationItem; opacity: 1.0
                }
            },
            State {
                name: "closeWithMove"
                PropertyChanges {
                    target: notificationItem; offset: notificationPopup.closedOffset
                }
                PropertyChanges {
                    target: notificationItem; scale: 1.0
                }
                PropertyChanges {
                    target: notificationItem; opacity: 1.0
                }
            },
            State {
                name: "closeWithScale"
                PropertyChanges {
                    target: notificationItem; offset: notificationPopup.openOffset
                }
                PropertyChanges {
                    target: notificationItem; scale: 0.75
                }
                PropertyChanges {
                    target: notificationItem; opacity: 0.0
                }
            },
            State {
                name: "inDrawerClosed"
                PropertyChanges {
                    target: notificationItem; offset: notificationPopup.openOffset + (notificationPopup.popupDrawerOpened ? 0 : drawerAddedOffset)
                }
                PropertyChanges {
                    target: notificationItem; scale: notificationPopup.popupDrawerOpened ? 1 : drawerScale
                }
                PropertyChanges {
                    target: notificationItem; opacity: notificationPopup.popupDrawerOpened ? 1 : drawerOpacity
                }
            }
        ]

        transitions: Transition {
            SequentialAnimation {
                ParallelAnimation {
                    PropertyAnimation {
                        properties: "offset"; easing.type: Easing.OutExpo; duration: Kirigami.Units.veryLongDuration * 1.5
                    }
                    PropertyAnimation {
                        properties: "scale"; easing.type: Easing.OutExpo; duration: Kirigami.Units.veryLongDuration * 1.5
                    }
                    PropertyAnimation {
                        properties: "opacity"; easing.type: Easing.OutExpo; duration: Kirigami.Units.veryLongDuration * 1.5
                    }
                }
                ScriptAction {
                    script: {
                        if (notificationItem.state == "open") {
                            preventDismissTimeout = false;
                            notificationPopup.updateTouchArea();
                        } else if (notificationItem.state == "closeWithMove" || notificationItem.state == "closeWithScale") {
                            preventDismissTimeout = true;
                            if (dismissTimeout) {
                                notificationPopup.dismissClicked();
                            } else if (!isActionDrawerOpen) {
                               notificationPopup.expired();
                            }
                        }
                    }
                }
            }
        }

        transform: [
            Scale {
                origin.x: Math.round(notificationPopup.popupWidth / 2)
                origin.y: notificationPopup.scaleOriginY
                xScale: notificationItem.scale
                yScale: notificationItem.scale
            }
        ]
    }

    transform: [
        Translate {
            y: notificationItem.offset + notificationPopup.fullOffsetAn + notificationPopup.dragOffset + notificationPopup.currentDragOffset
        }
    ]

    DragHandler {
        id: dragHandler
        xAxis.enabled: false
        yAxis.enabled: popupNotifications.currentPopupIndex == notificationPopup.popupIndex && !notificationPopup.popupDrawerOpened
        target: null

        property real lastOffset: 0

        property real startDragOffset: 0
        property real startPosition: 0
        property bool startActive: false

        onTranslationChanged: {
            if (notificationItem.state == "closeWithScale" || notificationItem.state == "closeWithMove") {
                return;
            }
            if (startActive) {
                startDragOffset = notificationPopup.dragOffset;
                startPosition = translation.y;
                startActive = false;
            }
            lastOffset = notificationPopup.dragOffset;
            notificationPopup.dragOffset = calculateResistance(startDragOffset + (translation.y - startPosition), 0);
        }

        onActiveChanged: {
            startActive = active;
            notificationPopup.preventDismissTimeout = true;
            if (!active && !(notificationItem.state == "closeWithScale" || notificationItem.state == "closeWithMove")) {
                dragOffsetAn.running = true;
                if ((lastOffset - notificationPopup.dragOffset > 1.0 && notificationPopup.dragOffset < 0) || (-(notificationPopup.openOffset - notificationPopup.closedOffset) / 4 > notificationPopup.dragOffset)) {
                    // this code is called when the notifition is swiped or draged to the top.
                    notificationPopup.closePopup();
                    return;
                } else if (notificationPopup.dragOffset - lastOffset > 1.0 || Kirigami.Units.gridUnit * 3 < notificationPopup.dragOffset) {
                    // this code is called when the notifition is swiped or draged down.
                }
                notificationPopup.preventDismissTimeout = (keyboardInteractivity == LayerShell.Window.KeyboardInteractivityOnDemand);
            } else {
                dragOffsetAn.running = false;
            }
        }
    }

    MouseArea {
        // capture taps were the notifications are grouping together to open the popup notification drawer
        id: item
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: notificationItem.bottom

        height: Kirigami.Units.gridUnit * 2

        enabled: !notificationPopup.popupDrawerOpened && (notificationPopup.popupCount - popupNotifications.currentPopupIndex > 1)

        onReleased: {
            notificationPopup.openPopupDrawer();
            notificationPopup.updateTouchArea();
            notificationPopup.setKeyboardFocus();
        }
    }
}
