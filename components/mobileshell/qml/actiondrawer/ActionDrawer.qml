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
     * Same as offset value except this adds resistance when passing the open position of the current drawer state.
     */
    readonly property real offsetResistance: {
        if (!openToPinnedMode) {
            return root.calculateResistance(offset, contentContainer.maximizedQuickSettingsOffset);
        } else if (!opened) {
            return root.calculateResistance(offset, contentContainer.minimizedQuickSettingsOffset);
        } else {
            return root.calculateResistance(offset, contentContainer.maximizedQuickSettingsOffset);
        }
    }

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

    // calculates offset resistance for the action drawer overshoots it's open position
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

    // action drawer ui content
    ContentContainer {
        id: contentContainer
        anchors.fill: parent

        actionDrawer: root
        quickSettingsModel: root.quickSettingsModel
    }
}
