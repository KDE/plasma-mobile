// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.2
import QtQuick.Layouts

import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.components 3.0 as PC3
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

/**
 * Root element that contains all the ActionDrawer's contents, and is anchored to the screen.
 */
Item {
    id: root

    required property var actionDrawer
    required property QS.QuickSettingsModel quickSettingsModel

    readonly property real minimizedQuickSettingsOffset: contentContainerLoader.minimizedQuickSettingsOffset
    readonly property real maximizedQuickSettingsOffset: contentContainerLoader.maximizedQuickSettingsOffset

    readonly property bool swipeAreaMoving: swipeAreaBase.moving || swipeAreaPortrait.moving

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    Kirigami.Theme.inherit: false

    readonly property alias brightnessPressedValue: quickSettings.brightnessPressedValue

    function applyMinMax(val) {
        return Math.max(0, Math.min(1, val));
    }

    function startSwipe() {
        actionDrawer.cancelAnimations();
        actionDrawer.dragging = true;
        // Immediately open action drawer if we interact with it and it's already open
        // This allows us to have 2 quick flicks from minimized -> expanded
        if (actionDrawer.visible && !actionDrawer.opened) {
            actionDrawer.opened = true;
        }
    }

    function endSwipe() {
        actionDrawer.dragging = false;
        actionDrawer.updateState();
    }

    function moveSwipe(totalDeltaX, totalDeltaY, deltaX, deltaY) {
        actionDrawer.offset += deltaY;
    }

    // Background color
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r,
                       Kirigami.Theme.backgroundColor.g,
                       Kirigami.Theme.backgroundColor.b,
                       0.9)
        Behavior on color { ColorAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.OutQuad } }
        opacity: Math.max(0, Math.min(brightnessPressedValue, actionDrawer.offset / root.minimizedQuickSettingsOffset))
    }

    // The base swipe area.
    // Used to cover the full surface of the drawer to allow dismissing or expanding it.
    MobileShell.SwipeArea {
        id: swipeAreaBase
        mode: MobileShell.SwipeArea.VerticalOnly
        anchors.fill: parent

        onSwipeStarted: root.startSwipe()
        onSwipeEnded: root.endSwipe()
        onSwipeMove: (totalDeltaX, totalDeltaY, deltaX, deltaY) => root.moveSwipe(totalDeltaX, totalDeltaY, deltaX, deltaY)

        onTouchpadScrollStarted: root.startSwipe()
        onTouchpadScrollEnded: root.endSwipe()
        onTouchpadScrollMove: (totalDeltaX, totalDeltaY, deltaX, deltaY) => root.moveSwipe(totalDeltaX, totalDeltaY, deltaX, deltaY)

        // Proxy in the layout that switches between landscape and portrait mode.
        ColumnLayout {
            anchors.fill: parent
            visible: root.actionDrawer.mode != MobileShell.ActionDrawer.Portrait
            LayoutItemProxy { target: contentContainerLoader }
        }

        // Mouse area for dismissing action drawer in portrait mode when background is clicked.
        MouseArea {
            anchors.fill: parent
            visible: root.actionDrawer.mode == MobileShell.ActionDrawer.Portrait

            // dismiss drawer when background is clicked
            onClicked: root.actionDrawer.close();
        }

        // The clear all notification history button.
        Item {
            id: toolButtons
            height: visible ? spacer.height + toolLayout.height + toolLayout.anchors.topMargin + toolLayout.anchors.bottomMargin : 0

            visible: actionDrawer.intendedToBeVisible
            opacity: Math.max(0, Math.min(root.brightnessPressedValue, actionDrawer.offsetResistance / root.minimizedQuickSettingsOffset))

            anchors {
                topMargin: notificationDrawer.height + 1
                leftMargin: actionDrawer.mode == MobileShell.ActionDrawer.Portrait ? 0 : 10
                rightMargin: actionDrawer.mode == MobileShell.ActionDrawer.Portrait ? 0 : notificationDrawer.notificationWidget.anchors.rightMargin + Kirigami.Units.gridUnit - notificationDrawer.anchors.leftMargin + 370
                top: parent.top
                left: parent.left
                right: parent.right
            }

            Rectangle {
                id: spacer
                anchors.left: parent.left
                anchors.right: parent.right

                visible: notificationDrawer.listOverflowing
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

                    visible: notificationDrawer.hasNotifications

                    font.bold: true
                    font.pointSize: Kirigami.Theme.smallFont.pointSize

                    icon.name: "edit-clear-history"
                    text: i18n("Clear All Notifications")
                    onClicked: notificationDrawer.notificationWidget.clearHistory()
                }
            }
        }
    }

    // notification drawer ui
    // separated from the main drawer ui swipe area to prevent scrolling conflicts
    NotificationDrawer {
        id: notificationDrawer

        swipeArea: swipeAreaPortrait
        actionDrawer: root.actionDrawer
        mediaControlsWidget: root.mediaControlsWidget
        contentContainer: root
        opacity: Math.max(0, Math.min(root.brightnessPressedValue, actionDrawer.offsetResistance / root.minimizedQuickSettingsOffset))

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            rightMargin: root.actionDrawer.mode == MobileShell.ActionDrawer.Portrait ? 0 : 360
            leftMargin: actionDrawer.mode == MobileShell.ActionDrawer.Portrait ? 0 : notificationDrawer.minWidthHeight * 0.06
        }
    }

    // Secondary swipe area for uses in portrait.
    // Covers the surface area of the quick settings panel to allow dismissing or expanding the drawer while also having it over top of the notification list.
    MobileShell.SwipeArea {
        id: swipeAreaPortrait
        mode: MobileShell.SwipeArea.VerticalOnly
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: root.actionDrawer.mode === MobileShell.ActionDrawer.Portrait ? actionDrawer.offsetResistance : root.height
        interactive: root.actionDrawer.mode === MobileShell.ActionDrawer.Portrait

        onSwipeStarted: root.startSwipe()
        onSwipeEnded: root.endSwipe()
        onSwipeMove: (totalDeltaX, totalDeltaY, deltaX, deltaY) => root.moveSwipe(totalDeltaX, totalDeltaY, deltaX, deltaY)

        onTouchpadScrollStarted: root.startSwipe()
        onTouchpadScrollEnded: root.endSwipe()
        onTouchpadScrollMove: (totalDeltaX, totalDeltaY, deltaX, deltaY) => root.moveSwipe(totalDeltaX, totalDeltaY, deltaX, deltaY)

        // Proxy in the layout that switches between landscape and portrait mode.
        ColumnLayout {
            anchors.fill: parent
            visible: root.actionDrawer.mode == MobileShell.ActionDrawer.Portrait
            LayoutItemProxy { target: contentContainerLoader }
        }
    }

    // Layout that switches between landscape and portrait mode
    Loader {
        id: contentContainerLoader

        Layout.fillWidth: true
        Layout.fillHeight: true

        readonly property real minimizedQuickSettingsOffset: item ? item.minimizedQuickSettingsOffset : 0
        readonly property real maximizedQuickSettingsOffset: item ? item.maximizedQuickSettingsOffset : 0

        readonly property real offsetDist: root.actionDrawer.offset - minimizedQuickSettingsOffset
        readonly property real totalOffsetDist: maximizedQuickSettingsOffset - minimizedQuickSettingsOffset
        readonly property real minimizedToFullProgress: root.actionDrawer.openToPinnedMode ? (root.actionDrawer.opened ? applyMinMax(offsetDist / totalOffsetDist) : 0) : 1

        asynchronous: true
        sourceComponent: root.actionDrawer.mode == MobileShell.ActionDrawer.Portrait ? portraitContentContainer : landscapeContentContainer
    }

    // The portrait content container.
    Component {
        id: portraitContentContainer
        PortraitContentContainer {
            actionDrawer: root.actionDrawer
            width: root.width
            height: root.height

            quickSettings: root.quickSettings
            statusBar: root.statusBar
            mediaControlsWidget: root.mediaControlsWidget
        }
    }

    // The landscape content container.
    Component {
        id: landscapeContentContainer
        LandscapeContentContainer {
            actionDrawer: root.actionDrawer
            width: root.width
            height: root.height

            quickSettings: root.quickSettings
            statusBar: root.statusBar
        }
    }

    // Components shared between the two layouts.
    // This allows us to avoid having to reload the components every time the screen size changes.

    property QuickSettings quickSettings: QuickSettings {
        id: quickSettings
        actionDrawer: root.actionDrawer
        quickSettingsModel: root.quickSettingsModel
        fullViewProgress: (root.actionDrawer.mode == MobileShell.ActionDrawer.Portrait) ? contentContainerLoader.minimizedToFullProgress : 1.0
    }

    property MobileShell.StatusBar statusBar: MobileShell.StatusBar {
        id: statusBar
        Kirigami.Theme.colorSet: Kirigami.Theme.Window
        Kirigami.Theme.inherit: false

        backgroundColor: "transparent"
        showSecondRow: root.actionDrawer.mode == MobileShell.ActionDrawer.Portrait
        showDropShadow: false
        showTime: root.actionDrawer.mode == MobileShell.ActionDrawer.Portrait

        // security reasons, system tray also doesn't work on lockscreen
        disableSystemTray: root.actionDrawer.restrictedPermissions

        opacity: brightnessPressedValue
    }

    property MobileShell.MediaControlsWidget mediaControlsWidget: MobileShell.MediaControlsWidget {
        id: mediaWidget
        opacity: brightnessPressedValue
    }
}
