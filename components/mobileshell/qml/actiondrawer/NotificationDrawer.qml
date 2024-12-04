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

    property alias mediaControlsWidget: notificationWidget.mediaControlsWidget
    property alias notificationWidget: notificationWidget
    property real contentY: notificationWidget.listView.contentY

    height: Math.min(actionDrawer.height - toolButtons.height, notificationWidget.listView.contentHeight + 10 + topMargin)

    property real topMargin: actionDrawer.mode == ActionDrawer.Portrait ? actionDrawer.offsetResistance + 1 : 0
    property real topPadding: actionDrawer.mode == ActionDrawer.Portrait ? Kirigami.Units.largeSpacing : date.y + date.height + Kirigami.Units.smallSpacing * 6

    readonly property real minWidthHeight: Math.min(actionDrawer.width, actionDrawer.height)
    readonly property bool hasNotifications: notificationWidget.hasNotifications
    readonly property bool listOverflowing: notificationWidget.listView.listOverflowing
    onTopMarginChanged: {
        if (!actionDrawer.dragging) {
            mouseArea.anchors.topMargin = topMargin;
        }
    }

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    P5Support.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60 * 1000
    }

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
        showMediaControlsWidget: actionDrawer.mode != ActionDrawer.Portrait
        listView.interactive: !actionDrawer.dragging && root.listOverflowing

        Connections {
            target: actionDrawer

            function onRunPendingNotificationAction() {
                notificationWidget.runPendingAction();
            }
        }

        onBackgroundClicked: actionDrawer.close();
    }

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

    MobileShell.VelocityCalculator {
        id: velocityCalculator
    }

    // the first swipe when at the top of the notification list is handeled using a MouseArea, not the flickable
    // this is so one can swipe down from the top of the notification drawer to expand the action drawer
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: actionDrawer.mode == ActionDrawer.Portrait && (notificationWidget.listView.atYBeginning || actionDrawer.dragging)
        preventStealing: actionDrawer.mode == ActionDrawer.Portrait && Math.abs(actionDrawer.offset - startOffset) > Kirigami.Units.largeSpacing

        property real startOffset: 0
        property real startMouseY: 0
        property real lastMouseY: 0

        property bool startedAtYBeginning: false
        property bool startedAtYEnd: false
        property bool drawerDrag: true

        property string currentState

        onPressed: {
            mouseArea.startedAtYBeginning = notificationWidget.listView.atYBeginning;
            mouseArea.startedAtYEnd = notificationWidget.listView.atYEnd;

            if (notificationWidget.listView.atYBeginning) {
                currentState = actionDrawer.state;
                actionDrawer.cancelAnimations();
                actionDrawer.dragging = true;
                actionDrawer.opened = true;
                mouseArea.startOffset = actionDrawer.offset;
                mouseArea.startMouseY = mouseY;
                mouseArea.lastMouseY = mouseArea.startMouseY;
                mouseArea.drawerDrag = true;

                velocityCalculator.startMeasure();
                velocityCalculator.changePosition(notificationWidget.listView.contentY);
            }
        }

        onReleased: {
            if (actionDrawer.dragging) {
                if (mouseArea.drawerDrag) {
                    actionDrawer.updateState();
                } else {
                    notificationWidget.listView.flick(0, -velocityCalculator.velocity);
                }
            }
            actionDrawer.dragging = false;
            mouseArea.drawerDrag = true;
            mouseArea.anchors.topMargin = topMargin;
        }

        onCanceled: {
            if (actionDrawer.dragging) {
                actionDrawer.state = currentState;
                actionDrawer.dragging = false;
                mouseArea.drawerDrag = true;
                mouseArea.anchors.topMargin = topMargin;
            }
        }

        onPositionChanged: {
            if (!actionDrawer.dragging) {
                return;
            }

            if (!(mouseArea.startedAtYBeginning && mouseArea.startedAtYEnd) && ((mouseArea.startedAtYBeginning && (mouseArea.startMouseY - mouseY) > 0) || (mouseArea.startedAtYEnd && (mouseY - mouseArea.startMouseY) > 0))) {
                actionDrawer.state = currentState;
                mouseArea.drawerDrag = false;
            }

            if (mouseArea.drawerDrag) {
                actionDrawer.offset = mouseArea.startOffset - (mouseArea.startMouseY - mouseY);
            } else {
                let contentY = notificationWidget.listView.contentY - (mouseY - mouseArea.lastMouseY);

                notificationWidget.listView.contentY = contentY;
                velocityCalculator.changePosition(notificationWidget.listView.contentY);
                mouseArea.lastMouseY = mouseY;
            }
        }
    }
}
