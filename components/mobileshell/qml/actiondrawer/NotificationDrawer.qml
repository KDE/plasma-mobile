/*
 *   SPDX-FileCopyrightText: 2024 Micah Stanley <stanleymicah@proton.me>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1

import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: root

    required property var actionDrawer
    required property var contentContainer
    required property var swipeArea

    property alias mediaControlsWidget: notificationWidget.header
    property alias notificationWidget: notificationWidget
    property real contentY: notificationWidget.listView.contentY

    property real topPadding: actionDrawer.mode == ActionDrawer.Portrait ? Kirigami.Units.largeSpacing : date.y + date.height + Kirigami.Units.smallSpacing * 6
    property real topMargin: actionDrawer.mode == ActionDrawer.Portrait ? actionDrawer.offsetResistance + 1 : 0

    readonly property real minWidthHeight: Math.min(actionDrawer.width, actionDrawer.height)
    readonly property bool hasNotifications: notificationWidget.hasNotifications
    readonly property bool listOverflowing: notificationWidget.listView.listOverflowing

    height: Math.min(actionDrawer.height - toolButtons.height, notificationWidget.listView.contentHeight + 10 + topMargin)

    // time source for the time and date whenin landscape mode
    P5Support.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60 * 1000
    }

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    MobileShell.VelocityCalculator {
        id: velocityCalculator
    }

    // notification list widget
    // margin adjusted to fit and postion into the action drawer
    MobileShell.NotificationsWidget {
        id: notificationWidget
        anchors.fill: parent
        anchors.topMargin: root.topMargin
        anchors.rightMargin: actionDrawer.mode == ActionDrawer.Portrait ? 0 : Math.max(root.width - Kirigami.Units.gridUnit * 25, 0)
        anchors.leftMargin: actionDrawer.mode == ActionDrawer.Portrait ? 0 : -Kirigami.Units.gridUnit

        historyModel: actionDrawer.notificationModel
        historyModelType: actionDrawer.notificationModelType
        notificationSettings: actionDrawer.notificationSettings
        actionsRequireUnlock: actionDrawer.restrictedPermissions
        onUnlockRequested: actionDrawer.permissionsRequested()
        topPadding: root.topPadding
        showHeader: actionDrawer.mode != ActionDrawer.Portrait
        listView.interactive: !actionDrawer.dragging && root.listOverflowing

        Connections {
            target: actionDrawer

            function onRunPendingNotificationAction() {
                notificationWidget.runPendingAction();
            }
        }

        // the first swipe when at the top of the notification list is handeled using a MouseArea, not the flickable
        // this is so one can swipe down from the top of the notification drawer to expand the action drawer
        DragHandler {
            id: dragHandler
            // disable the draghandler when we are not at the top of the notification list as it can interfere with the notification scrolling
            yAxis.enabled: notificationWidget.listView.atYBeginning || active
            xAxis.enabled: false

            property bool startActive: false

            property real startOffset: 0
            property real startMouseY: 0
            property real lastMouseY: 0

            property bool startedAtYBeginning: false
            property bool startedAtYEnd: false
            property bool drawerDrag: true

            property string currentState

            onTranslationChanged: {
                if (startActive) {
                    dragHandler.startedAtYBeginning = notificationWidget.listView.atYBeginning;
                    dragHandler.startedAtYEnd = notificationWidget.listView.atYEnd;
                    startActive = false;

                    if (notificationWidget.listView.atYBeginning) {
                        currentState = actionDrawer.state;
                        actionDrawer.cancelAnimations();
                        actionDrawer.dragging = true;
                        actionDrawer.opened = true;
                        dragHandler.startOffset = actionDrawer.offset;
                        dragHandler.startMouseY = translation.y;
                        dragHandler.lastMouseY = dragHandler.startMouseY;
                        dragHandler.drawerDrag = true;

                        velocityCalculator.startMeasure();
                        velocityCalculator.changePosition(notificationWidget.listView.contentY);
                    }
                }

                if (!actionDrawer.dragging) {
                    return;
                }

                if (!(dragHandler.startedAtYBeginning && dragHandler.startedAtYEnd) && ((dragHandler.startedAtYBeginning && (dragHandler.startMouseY - translation.y) > 0) || (dragHandler.startedAtYEnd && (translation.y - dragHandler.startMouseY) > 0))) {
                    actionDrawer.state = currentState;
                    dragHandler.drawerDrag = false;
                }

                if (dragHandler.drawerDrag) {
                    actionDrawer.offset = dragHandler.startOffset - (dragHandler.startMouseY - translation.y);
                } else {
                    let contentY = notificationWidget.listView.contentY - (translation.y - dragHandler.lastMouseY);

                    notificationWidget.listView.contentY = contentY;
                    velocityCalculator.changePosition(notificationWidget.listView.contentY);
                    dragHandler.lastMouseY = translation.y;
                }
            }

            onActiveChanged: {
                startActive = active;

                if (!active) { // release event
                    if (actionDrawer.dragging) {
                        if (dragHandler.drawerDrag) {
                            actionDrawer.updateState();
                        } else {
                            notificationWidget.listView.flick(0, -velocityCalculator.velocity);
                        }
                    }
                    actionDrawer.dragging = false;
                    dragHandler.drawerDrag = true;
                }
            }
        }

    }

    // time and date displayed in landscape mode
    Item {
        id: landscapeModeHeader
        anchors.fill: parent
        visible: actionDrawer.mode != ActionDrawer.Portrait

        transform: [
            Translate {
                y: -notificationWidget.listView.contentY + notificationWidget.listView.originY
            }
        ]

        PlasmaComponents.Label {
            id: clock
            text: Qt.formatTime(timeSource.data.Local.DateTime, MobileShell.ShellUtil.isSystem24HourFormat ? "h:mm" : "h:mm ap")
            verticalAlignment: Qt.AlignVCenter

            anchors {
                left: parent.left
                top: parent.top
                topMargin: minWidthHeight * 0.03
            }

            font.pixelSize: Math.min(40, minWidthHeight * 0.1)
            font.weight: Font.ExtraLight
            elide: Text.ElideRight
        }

        PlasmaComponents.Label {
            id: date
            text: Qt.formatDate(timeSource.data.Local.DateTime, "ddd MMMM d")
            verticalAlignment: Qt.AlignTop
            color: Kirigami.Theme.disabledTextColor

            anchors {
                left: parent.left
                top: clock.bottom
                topMargin: Kirigami.Units.smallSpacing
            }

            font.pixelSize: Math.min(20, minWidthHeight * 0.05)
            font.weight: Font.Light
        }
    }
}
