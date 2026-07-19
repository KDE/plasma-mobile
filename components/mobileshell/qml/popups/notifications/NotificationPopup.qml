/*
    SPDX-FileCopyrightText: 2024-2025 Micah Stanley <stanleymicah@proton.me>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Window

import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState

import org.kde.layershell 1.0 as LayerShell

import org.kde.notificationmanager as NotificationManager
import org.kde.plasma.clock

Item {
    id: popupDelegate

    height: (notificationItem.cardHeight + Kirigami.Units.largeSpacing) * heightAnimationValue
    opacity: Math.max(1 * popupDelegate.popupDrawerAnimationValue, popupDelegate.opacityAnimationValue)

    required property var model
    required property int index

    property var popupManager
    property var keyboardInteractivity
    property bool popupDrawerOpened: false
    property var notificationsModel
    property int notificationsModelType
    property var timeDataSource
    property int notificationCount
    property real topPopupOffset
    property real popupDrawerAnimationValue: 0

    property bool isCurrentPopup: index < 1
    property real currentPopupHeight
    property real currentPopupDragOffset // the drag offset on the current popup notification - used to position notification when stacked underneath
    property real offsetFromCurrentPopup

    property real heightAnimationValue: 1
    property real opacityAnimationValue: index < 3 ? 1 : 0
    property real verticalOffset: 0
    property real dragOffset: 0
    property bool closedWithSwipe: false // set to true when notification is swiped up by user
    property string removalType: "slide"

    property bool preventDismissTimeout: false
    property int timeout
    property int dismissTimeout
    property int defaultTimeout: 5000
    property bool isExpired: model.expired
    property real remainingTimeProgress: 1 // the value of how much time is left, normalized from 1 to 0

    readonly property real cardHeight: notificationItem.cardHeight
    readonly property real closedOffset: -(notificationItem.height + Kirigami.Units.smallSpacing)
    readonly property int effectiveTimeout: {
        if (timeout === -1) return defaultTimeout;
        if (dismissTimeout) return dismissTimeout;
        return model.timeout;
    }

    signal updateTouchArea()
    signal openPopupDrawer()
    signal setKeyboardFocus()
    signal removeKeyboardFocus()
    signal dismissClicked()
    signal expired()

    onHeightChanged: {
        if (isCurrentPopup) {
            popupDelegate.updateTouchArea();
        }
    }

    onIsCurrentPopupChanged: {
        if (isCurrentPopup) {
            popupDelegate.updateTouchArea();
        }
    }

    onIsExpiredChanged: {
        if (isExpired) {
            popupDelegate.closePopup();
        }
    }

    // attached property action animations
    ListView.onAdd: {
        if (popupDrawerOpened) {
            notificationItem.opacity = 0;
            fadeInAnimation.restart();
        } else {
            popupDelegate.verticalOffset = -popupDelegate.height - popupDelegate.topPopupOffset;
            slideInAnimation.restart();
        }
    }

    ListView.onRemove: {
        fadeInAnimation.stop();
        slideInAnimation.stop();
        notificationItem.opacity = 1;
        verticalOffset = 0;
        ListView.delayRemove = true;
        popupManager.activeRemovalAnimations += 1;

        if (popupDrawerOpened || !isCurrentPopup) {
            fadeOutAnimation.restart();
        } else {
            slideOutAnimation.restart();
        }
    }

    // state transition animations / timers
    Behavior on opacityAnimationValue {
        NumberAnimation {
            duration: Kirigami.Units.veryLongDuration * 1.5
            easing.type: Easing.OutQuint
        }
    }

    NumberAnimation on dragOffset {
        id: dragOffsetAnimation
        running: false
        to: 0
        duration: Kirigami.Units.veryLongDuration * 1.5
        easing.type: Easing.OutExpo
    }

    NumberAnimation on remainingTimeProgress {
        from: 1
        to: 0
        duration: hideTimer.interval
        running: hideTimer.running
    }

    ParallelAnimation {
        id: slideInAnimation
        NumberAnimation {
            target: popupDelegate
            property: "verticalOffset"
            to: 0
            duration: Kirigami.Units.veryLongDuration * 1.25
            easing.type: Easing.OutQuint
        }
    }

    ParallelAnimation {
        id: slideOutAnimation
        NumberAnimation {
            target: popupDelegate
            property: "verticalOffset"
            to: {
                if (popupDelegate.closedWithSwipe) {
                    return -popupDelegate.height - popupDelegate.topPopupOffset - popupDelegate.dragOffset;
                } else {
                    return -popupDelegate.height - popupDelegate.topPopupOffset;
                }
            }
            duration: (popupDelegate.closedWithSwipe || popupDelegate.notificationCount > 0) ? Kirigami.Units.veryLongDuration * 0.5 : Kirigami.Units.veryLongDuration * 1.25
            easing.type: (popupDelegate.closedWithSwipe || popupDelegate.notificationCount > 0) ? Easing.Linear : Easing.InQuint
        }
        onStopped: {
            popupDelegate.ListView.delayRemove = false;
            popupManager.activeRemovalAnimations -= 1;
        }
    }

    ParallelAnimation {
        id: fadeOutAnimation
        NumberAnimation {
            target: notificationItem
            property: "opacity"
            to: 0
            duration: Kirigami.Units.veryLongDuration * 1.25
            easing.type: Easing.OutQuint
        }
        NumberAnimation {
            target: popupDelegate
            property: "heightAnimationValue"
            to: 0
            duration: Kirigami.Units.veryLongDuration * 1.25
            easing.type: Easing.OutQuint
        }
        onStopped: {
            popupDelegate.ListView.delayRemove = false;
            popupManager.activeRemovalAnimations -= 1;
        }
    }

    ParallelAnimation {
        id: fadeInAnimation
        NumberAnimation {
            target: notificationItem
            property: "opacity"
            to: 1
            duration: Kirigami.Units.veryLongDuration * 1.25
            easing.type: Easing.InQuint
        }
        NumberAnimation {
            target: popupDelegate
            property: "heightAnimationValue"
            from: 0
            to: 1
            duration: Kirigami.Units.veryLongDuration * 1.25
            easing.type: Easing.OutQuint
        }
    }

    // the timer for when the notification will dismiss
    Timer {
        id: hideTimer
        interval: popupDelegate.effectiveTimeout
        running: {
            if (interval <= 0) return false;
            if (popupDelegate.preventDismissTimeout) return false;
            if (!popupDelegate.isCurrentPopup) return false;
            if (popupDelegate.popupDrawerOpened) return false;
            return true;
        }
        onTriggered: popupDelegate.closePopup()
    }

    // helper functions
    function closePopup() {
        if (isExpired) {
            notificationItem.close();
            return;
        }
        dismissClicked();
    }

    function calculateResistance(value: real, threshold: int): real {
        if (value > threshold) {
            return threshold + Math.pow(value - threshold + 1, Math.max(0.8 - (value - threshold) / ((Screen.height - threshold) * 15), 0.35));
        } else {
            return value;
        }
    }

    NotificationPopupItem {
        id: notificationItem

        anchors.left: parent.left
        anchors.right: parent.right

        inPopupDrawer: !popupDelegate.isCurrentPopup && !popupDelegate.popupDrawerOpened
        model: popupDelegate.model
        modelIndex: popupDelegate.index
        notificationsModel: popupDelegate.notificationsModel
        notificationsModelType: popupDelegate.notificationsModelType
        clockSource: popupDelegate.timeDataSource
        panelType: popupDelegate.popupDrawerOpened ? MobileShell.PanelBackground.PanelType.Drawer : MobileShell.PanelBackground.PanelType.Popup
        animateHeight: popupDelegate.isCurrentPopup
        currentPopupHeight: popupDelegate.currentPopupHeight
        remainingTimeProgress: popupDelegate.remainingTimeProgress
        closeTimerRunning: hideTimer.running

        property real popupScale: (popupDelegate.index > 0) ? (1 - Math.min(popupDelegate.index, 3) * 0.075) : 1

        Behavior on popupScale {
            NumberAnimation {
                duration: Kirigami.Units.veryLongDuration * 1.5
                easing.type: Easing.OutQuint
            }
        }

        transform: [
            Scale {
                origin.x: Math.round(notificationItem.width * 0.5)
                origin.y: popupDelegate.currentPopupHeight + Kirigami.Units.gridUnit * 5
                xScale: (notificationItem.popupScale * (1 - popupDelegate.popupDrawerAnimationValue)) + popupDelegate.popupDrawerAnimationValue
                yScale: (notificationItem.popupScale * (1 - popupDelegate.popupDrawerAnimationValue)) + popupDelegate.popupDrawerAnimationValue
            },
            Translate {
                y: (popupDelegate.offsetFromCurrentPopup * (1 - popupDelegate.popupDrawerAnimationValue)) + popupDelegate.verticalOffset + popupDelegate.dragOffset + Math.max(currentPopupDragOffset, 0)
            }
        ]

        onDragStart: preventDismissTimeout = true
        onDragEnd: preventDismissTimeout = (keyboardInteractivity == LayerShell.Window.KeyboardInteractivityOnDemand)

        onTakeFocus: {
            popupDelegate.setKeyboardFocus();
            preventDismissTimeout = true;
        }

        onDismissRequested: notificationItem.close()

        // capture taps were the notifications are grouping together to open the popup notification drawer
        MouseArea {
            id: drawerInteractionArea
            anchors.left: notificationItem.left
            anchors.right: notificationItem.right
            anchors.top: notificationItem.bottom
            height: Kirigami.Units.gridUnit * 1.5

            enabled: !popupDelegate.popupDrawerOpened && popupDelegate.notificationCount > 1 && popupDelegate.isCurrentPopup

            onReleased: {
                popupDelegate.openPopupDrawer();
                popupDelegate.updateTouchArea();
                popupDelegate.setKeyboardFocus();
            }
        }
    }

    DragHandler {
        id: dragHandler
        xAxis.enabled: false
        yAxis.enabled: popupDelegate.index == 0 && !popupDelegate.popupDrawerOpened
        target: null

        property real lastOffset: 0
        property real startDragOffset: 0
        property real startPosition: 0
        property bool isStartActive: false

        onTranslationChanged: {
            if (popupDelegate.index < 0) return;
            if (isStartActive) {
                startDragOffset = notificationPopup.dragOffset;
                startPosition = translation.y;
                isStartActive = false;
            }
            lastOffset = notificationPopup.dragOffset;
            popupDelegate.dragOffset = calculateResistance(startDragOffset + (translation.y - startPosition), 0);
        }

        onActiveChanged: {
            isStartActive = active;
            popupDelegate.preventDismissTimeout = true;
            if (!active && !(slideOutAnimation.running || fadeOutAnimation.running)) {
                if ((lastOffset - popupDelegate.dragOffset > 1.0 && popupDelegate.dragOffset < 0) || (popupDelegate.closedOffset * 0.5 > popupDelegate.dragOffset)) {
                    // this code is called when the notification is swiped or dragged to the top.
                    popupDelegate.closedWithSwipe = true;
                    popupDelegate.closePopup();
                    return;
                }
                dragOffsetAnimation.running = true;
                if (popupDelegate.dragOffset - lastOffset > 1.0 || Kirigami.Units.gridUnit * 3 < popupDelegate.dragOffset) {
                    // this code is called when the notification is swiped or dragged down.
                }
                popupDelegate.preventDismissTimeout = (keyboardInteractivity == LayerShell.Window.KeyboardInteractivityOnDemand);
            } else {
                dragOffsetAnimation.running = false;
            }
        }
    }
}

