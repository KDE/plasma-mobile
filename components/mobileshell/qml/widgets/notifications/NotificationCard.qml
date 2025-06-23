// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL

import QtQuick
import QtQuick.Effects
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell as MobileShell

Item {
    id: root

    /**
     * The content that goes inside the notification card
     */
    default property Item contentItem

    /**
     * The panel background type for this notification.
     */
    property int panelType: MobileShell.PanelBackground.PanelType.Drawer

    /**
     * Whether this is a popup notification.
     */
    property bool popupNotification: false

    /**
     * Whether this popup notification is tucked underneath the current popup.
     */
    property bool inPopupDrawer: false

    /**
     * Whether this notification is within the lockscreen.
     */
    property bool inLockScreen: false

    /**
     * The current notification popup height.
     */
    property int currentPopupHeight: 0

    /**
     * The remaining time before the notification popup is dismissed.
     */
    property real remainingTimeProgress: 1

    /**
     * Whether the timer for dismissing the notification popup is running.
     */
    property bool closeTimerRunning: false

    /**
     * Whether tapping on this notification is enabled.
     */
    property bool tapEnabled: false

    /**
     * Whether swipping on this notification is enabled.
     */
    property bool swipeGestureEnabled: false

    /**
     * The current drag offset for this notification.
     */
    property real dragOffset: 0

    signal tapped()
    signal dismissRequested()
    signal configureClicked() // TODO implement settings button
    signal dragStart()
    signal dragEnd()

    onContentItemChanged: {
        contentItem.parent = contentParent;
        contentItem.anchors.fill = contentParent;
        contentItem.anchors.margins = Kirigami.Units.largeSpacing;
        contentParent.children.push(contentItem);
    }

    implicitHeight: contentParent.implicitHeight

    NumberAnimation on dragOffset {
        id: dragAnim
        duration: Kirigami.Units.longDuration
        easing.type: Easing.OutCubic
        onFinished: {
            if (to !== 0) {
                root.dismissRequested();
            }
        }
    }

    MobileShell.PanelBackground {
        anchors.fill: mainCard
        animate: true
        panelType: root.panelType
    }

    // card
    Item {
        id: mainCard
        anchors.left: parent.left
        anchors.leftMargin: root.dragOffset > 0 ? root.dragOffset : 0
        anchors.right: parent.right
        anchors.rightMargin: root.dragOffset < 0 ? -root.dragOffset : 0
        anchors.top: parent.top

        implicitHeight: inPopupDrawer ? currentPopupHeight : contentParent.implicitHeight
        Behavior on implicitHeight {
            NumberAnimation {
                duration: Kirigami.Units.veryLongDuration
                easing.type: Easing.OutExpo
            }
        }

        ProgressBar {
            id: progress
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            width: root.width
            height: 2
            value: remainingTimeProgress

            opacity: closeTimerRunning ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.OutQuad
                }
            }

            background: Item

            contentItem: Item {
                implicitWidth: parent.width
                height: parent.height
                clip: true

                Rectangle {
                    width: Math.min(progress.visualPosition * (parent.width + root.dragOffset), parent.width)
                    height: Math.max(Kirigami.Units.cornerRadius * 2, parent.height)
                    topLeftRadius: Kirigami.Units.cornerRadius
                    topRightRadius: Kirigami.Units.cornerRadius
                    color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.highlightColor, Kirigami.Theme.backgroundColor, 0.8)
                }
                Rectangle {
                    width: Math.min(progress.visualPosition * (parent.width + root.dragOffset), parent.width - Kirigami.Units.cornerRadius)
                    height: Math.max(Kirigami.Units.cornerRadius * 2, parent.height)
                    topLeftRadius: Kirigami.Units.cornerRadius
                    color: Kirigami.ColorUtils.linearInterpolation (Kirigami.Theme.highlightColor, Kirigami.Theme.backgroundColor, 0.8)
                }
            }
        }

        // clip
        layer.enabled: true

        // ensure this is behind the content to not interfere
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                if (root.tapEnabled) {
                    root.tapped()
                }
            }
        }

        // content parent
        Item {
            id: contentParent
            anchors.top: parent.top
            anchors.left: root.dragOffset > 0 ? parent.left : undefined
            anchors.right: root.dragOffset < 0 ? parent.right : undefined

            width: root.width
            implicitHeight: contentItem.implicitHeight + contentItem.anchors.topMargin + contentItem.anchors.bottomMargin
        }
    }

    DragHandler {
        id: dragHandler
        enabled: root.swipeGestureEnabled
        yAxis.enabled: false
        xAxis.enabled: !inPopupDrawer

        property real startDragOffset: 0
        property real startPosition: 0
        property bool startActive: false

        onTranslationChanged: {
            if (startActive) {
                startDragOffset = root.dragOffset;
                startPosition = translation.x;
                startActive = false;
            }
            root.dragOffset = startDragOffset + (translation.x - startPosition);
        }

        onActiveChanged: {
            dragAnim.stop();
            startActive = active;

            if (!active) { // release event
                root.dragEnd()
                let threshold = Kirigami.Units.gridUnit * 5; // drag threshold
                if (root.dragOffset > threshold) {
                    dragAnim.to = root.width;
                } else if (root.dragOffset < -threshold) {
                    dragAnim.to = -root.width;
                } else {
                    dragAnim.to = 0;
                }
                dragAnim.restart();
            } else {
                root.dragStart()
            }
        }
    }
}
