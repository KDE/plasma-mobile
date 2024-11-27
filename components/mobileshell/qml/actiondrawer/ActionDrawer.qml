/*
 *   SPDX-FileCopyrightText: 2014 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

Item {
    id: root

    /*
     * The intended visiblity of the action drawer.
     *
     * This is separate from "visible" in order to avoid having to set
     * item visiblity when its on its own window (wasteful since the window itself can be shown/hidden).
     */
    property bool intendedToBeVisible: false

    /**
     * The model for the notification widget.
     */
    property var notificationModel

    /**
     * The model type for the notification widget.
     */
    property var notificationModelType: MobileShell.NotificationsModelType.NotificationsModel

    /**
     * The model for the quick settings.
     */
    property QS.QuickSettingsModel quickSettingsModel: QS.QuickSettingsModel {}

    /**
     * The notification settings object to be used in the notification widget.
     */
    property var notificationSettings

    /**
     * Whether actions should be subject to restricted permissions (ex. lockscreen).
     *
     * The permissionsRequested() signal emits when authentication is requested.
     */
    property bool restrictedPermissions: false

    /**
     * The amount of pixels moved by touch/mouse in the process of opening/closing the panel.
     */
    property real offset: 0

    /**
     * Same as the offset value except this adds a resistance value when it passes the open position of the current drawer state.
     */
    property real offsetResistance: 0

    /**
     * Whether the panel is being dragged.
     */
    property bool dragging: false

    /**
     * Whether the panel is open after touch/mouse release from the first opening swipe.
     */
    property bool opened: false

    /**
     * Whether the panel should open to pinned mode first, with a second stroke needed to full open.
     * Only applies to portrait mode.
     */
    property bool openToPinnedMode: true

    /**
     * Direction the panel is currently moving in.
     */
    property int direction: MobileShell.Direction.None

    /**
     * The scroll position of the notification drawer
     */
    property alias notificationsScrollY: flickable.contentY

    /**
     * The bottom y position of the header content above the notifications
     * Only applies to landscape mode.
     */
    property int landscapeHeaderY: 0

    /**
     * The mode of the action drawer (portrait or landscape).
     */
    property int mode: (height > width && width <= largePortraitThreshold) ? ActionDrawer.Portrait : ActionDrawer.Landscape

    /**
     * At some point, even if the screen is technically portrait, if we have a ton of width it'd be best to just show the landscape mode.
     */
    readonly property real largePortraitThreshold: Kirigami.Units.gridUnit * 35

    enum Mode {
        Portrait = 0,
        Landscape
    }

    /**
     * Emitted when the drawer has closed.
     */
    signal drawerClosed()

    /**
     * Emitted when the drawer has opened.
     */
    signal drawerOpened()

    /**
     * Emitted when permissions are requested (ex. unlocking the phone).
     *
     * Only gets emitted when restrictedPermissions is set to true.
     */
    signal permissionsRequested()

    /**
     * Runs the held notification action that was pending for authentication.
     *
     * Should be called by users if authentication is successful after permissionsRequested() was emitted.
     */
    signal runPendingNotificationAction()

    onOpenedChanged: {
        if (opened) swipeArea.focus = true;
    }

    property real oldOffset
    onOffsetChanged: {
        if (offset < 0) {
            offset = 0;
        }

        root.direction = (oldOffset === offset)
        ? MobileShell.Direction.None
        : (offset > oldOffset ? MobileShell.Direction.Down : MobileShell.Direction.Up);

        if (!openToPinnedMode) {
            offsetResistance = root.calculateResistance(offset, contentContainer.maximizedQuickSettingsOffset);
        } else if (!opened) {
            offsetResistance = root.calculateResistance(offset, contentContainer.minimizedQuickSettingsOffset);
        } else {
            offsetResistance = root.calculateResistance(offset, contentContainer.maximizedQuickSettingsOffset);
        }

        oldOffset = offset;

        // close panel immediately after panel is not shown, and the flickable is not being dragged
        if (opened && root.offset <= 0 && !swipeArea.moving && !drawerAnimation.running) {
            root.state = "";
            offset = 0;
            focus = false;
            root.opened = false;
            root.updateState();
        }
    }

    function calculateResistance(value : double, threshold : int) : double {
        if (value > threshold) {
            return threshold + Math.pow(value - threshold + 1, Math.max(0.8 - (value - threshold) / ((root.height - threshold) * 15), 0.35));
        } else {
            return value;
        }
    }

    function cancelAnimations() {
        root.state = "";
    }

    function open() {
        cancelAnimations();
        if (openToPinnedMode) {
            root.state = "open"; // go to pinned height
        } else {
            root.state = "expand"; // go to maximized height
        }
    }

    function closeImmediately() {
        cancelAnimations();
        offset = 0;
        root.state = "close";
    }

    function close() {
        cancelAnimations();
        root.state = "close";
    }

    function expand() {
        cancelAnimations();
        root.state = "expand";
    }

    function updateState() {
        let openThreshold = Kirigami.Units.gridUnit;

        if (root.offset <= 0) {
            // close immediately, so that we don't have to wait Kirigami.Units.longDuration
            root.intendedToBeVisible = false;
            close();
        } else if (root.direction === MobileShell.Direction.None || !root.opened) {

            // if the panel has not been opened yet, run open animation only if drag passed threshold
            (root.offset < openThreshold) ? close() : open();

        } else if (root.offset > contentContainer.maximizedQuickSettingsOffset) {
            // if drag has gone past the fully expanded view
            expand();
        } else if (root.offset > contentContainer.minimizedQuickSettingsOffset) {
            // if drag is between pinned view and fully expanded view
            if (root.direction === MobileShell.Direction.Down) {
                expand();
            } else {
                // go back to pinned, or close if pinned mode is disabled
                openToPinnedMode ? open() : close();
            }
        } else if (root.direction === MobileShell.Direction.Down) {
            // if drag is between pinned view and open view, and dragging down
            open();
        } else {
            // if drag is between pinned view and open view, and dragging up
            close();
        }
    }
    Timer {
        id: updateStateTimer
        interval: 0
        onTriggered: updateState()
    }

    state: "close"

    states: [
        State {
            name: ""
            PropertyChanges {
                target: root; offset: offset
            }
        },
        State {
            name: "close"
            PropertyChanges {
                target: root; offset: 0
            }
        },
        State {
            name: "open"
            PropertyChanges {
                target: root; offset: contentContainer.minimizedQuickSettingsOffset
            }
        },
        State {
            name: "expand"
            PropertyChanges {
                target: root; offset: contentContainer.maximizedQuickSettingsOffset
            }
        }
    ]

    transitions: Transition {
        SequentialAnimation {
            PropertyAnimation {
                id: drawerAnimation
                properties: "offset"; easing.type: Easing.OutExpo; duration: root.state != "" ? Kirigami.Units.veryLongDuration : 0
            }
            ScriptAction {
                script: {
                    if (root.state != "") {
                        if (root.offset <= 0) {
                            root.intendedToBeVisible = false;
                            root.opened = false;
                            root.state = "";
                        } else {
                            root.opened = true;
                        }
                    }
                }
            }
        }
    }

    readonly property alias brightnessPressedValue: contentContainer.brightnessPressedValue

    MobileShell.SwipeArea {
        id: swipeArea
        mode: MobileShell.SwipeArea.VerticalOnly
        anchors.fill: parent

        function startSwipe() {
            root.cancelAnimations();
            root.dragging = true;

            // Immediately open action drawer if we interact with it and it's already open
            // This allows us to have 2 quick flicks from minimized -> expanded
            if (root.visible && !root.opened) {
                root.opened = true;
            }
        }

        function endSwipe() {
            root.dragging = false;
            root.updateState();
        }

        function moveSwipe(totalDeltaX, totalDeltaY, deltaX, deltaY) {
            root.offset += deltaY;
        }

        onSwipeStarted: startSwipe()
        onSwipeEnded: endSwipe()
        onSwipeMove: (totalDeltaX, totalDeltaY, deltaX, deltaY) => moveSwipe(totalDeltaX, totalDeltaY, deltaX, deltaY)

        onTouchpadScrollStarted: startSwipe()
        onTouchpadScrollEnded: endSwipe()
        onTouchpadScrollMove: (totalDeltaX, totalDeltaY, deltaX, deltaY) => moveSwipe(totalDeltaX, totalDeltaY, deltaX, deltaY)

        ContentContainer {
            id: contentContainer
            anchors.fill: parent

            actionDrawer: root
            quickSettingsModel: root.quickSettingsModel
        }

        Item {
            id: toolButtons
            height: visible ? spacer.height + toolLayout.height + toolLayout.anchors.topMargin + toolLayout.anchors.bottomMargin : 0

            visible: root.intendedToBeVisible
            opacity: Math.max(0, Math.min(root.brightnessPressedValue, root.offsetResistance / contentContainer.minimizedQuickSettingsOffset))

            anchors {
                topMargin: root.mode == ActionDrawer.Landscape && flickable.interactive ? root.height - toolButtons.height : flickable.height + flickable.topMargin
                leftMargin: root.mode == ActionDrawer.Portrait ? 0 : 10
                rightMargin: root.mode == ActionDrawer.Portrait ? 0 : 360
                top: parent.top
                left: parent.left
                right: parent.right
            }

            Rectangle {
                id: spacer
                anchors.left: parent.left
                anchors.right: parent.right

                visible: flickable.listOverflowing
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
                    topMargin: Kirigami.Units.largeSpacing
                    bottomMargin: Kirigami.Units.largeSpacing
                }

                PlasmaComponents.ToolButton {
                    id: clearButton

                    Layout.alignment: Qt.AlignCenter

                    visible: flickable.hasNotifications

                    font.bold: true
                    font.pointSize: Kirigami.Theme.smallFont.pointSize

                    icon.name: "edit-clear-history"
                    text: i18n("Clear All Notifications")
                    onClicked: clearHistory()
                }
            }
        }
    }

    MobileShell.Flickable {
        id: flickable
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: flickable.topMargin
            leftMargin: root.mode == ActionDrawer.Portrait ? 0 : Math.round(Math.min(root.width, root.height) * 0.06) - Kirigami.Units.gridUnit
            rightMargin: root.mode == ActionDrawer.Portrait ? 0 : 360
        }

        height: Math.min(root.height - flickable.topMargin - toolButtons.height, column.implicitHeight)
        property int topMargin: root.mode == ActionDrawer.Portrait ? root.offsetResistance + 1 : Math.max(Math.min(topPadding - contentY, topPadding), 0)
        property int topPadding: root.mode == ActionDrawer.Portrait ? Kirigami.Units.largeSpacing : root.landscapeHeaderY

        contentHeight: column.implicitHeight + topPadding
        boundsBehavior: Flickable.DragAndOvershootBounds

        clip: true
        visible: root.intendedToBeVisible
        opacity: Math.max(0, Math.min(root.brightnessPressedValue, root.offsetResistance / contentContainer.minimizedQuickSettingsOffset))

        readonly property bool hasNotifications: notificationWidget.hasNotifications
        readonly property bool listOverflowing: {
            let padding = root.mode == ActionDrawer.Portrait ? root.offsetResistance + 1 + Kirigami.Units.largeSpacing : topPadding
            return column.implicitHeight + toolButtons.height > root.height - padding
        }
        onListOverflowingChanged: flickable.contentY = 0
        interactive: listOverflowing && !root.dragging

        Kirigami.Theme.colorSet: Kirigami.Theme.View
        Kirigami.Theme.inherit: false

        ColumnLayout {
            id: column
            width: parent.width

            y: root.mode == ActionDrawer.Portrait ? Kirigami.Units.largeSpacing : Math.max(Math.min(flickable.contentY, flickable.topPadding), 0)

            MobileShell.NotificationsWidget {
                id: notificationWidget
                historyModel: root.notificationModel
                historyModelType: root.notificationModelType
                notificationSettings: root.notificationSettings
                actionsRequireUnlock: root.restrictedPermissions
                onUnlockRequested: root.permissionsRequested()

                Connections {
                    target: root

                    function onRunPendingNotificationAction() {
                        notificationWidget.runPendingAction();
                    }
                }

                onBackgroundClicked: root.close();
                Layout.maximumWidth: root.mode == ActionDrawer.Portrait ? -1 : Kirigami.Units.gridUnit * 25
                Layout.preferredHeight: notificationWidget.listHeight
                Layout.fillWidth: true
            }
        }
    }
}
