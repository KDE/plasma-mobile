/*
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import "../components" as Components
import "quicksettings"

/**
 * Root element that contains all of the ActionDrawer's contents, and is anchored to the screen.
 */
PlasmaCore.ColorScope {
    id: root
    
    required property var actionDrawer
    
    property alias notificationsWidget: notificationWidget
    
    // pinned position (disabled when openToPinnedMode is false)
    readonly property real minimizedQuickSettingsOffset: quickSettings.minimizedHeight
    
    // fully open position
    readonly property real maximizedQuickSettingsOffset: minimizedQuickSettingsOffset + quickSettings.maxAddedHeight
    
    colorGroup: PlasmaCore.Theme.ViewColorGroup
    
    function applyMinMax(val) {
        return Math.max(0, Math.min(1, val));
    }
    
    // fullscreen background
    Rectangle {
        anchors.fill: parent
        // darken if there are notifications
        color: Qt.rgba(PlasmaCore.Theme.backgroundColor.r, 
                       PlasmaCore.Theme.backgroundColor.g, 
                       PlasmaCore.Theme.backgroundColor.b, 
                       0.95)
        Behavior on color { ColorAnimation { duration: PlasmaCore.Units.longDuration } }
        opacity: Math.max(0, Math.min(1, actionDrawer.offset / root.minimizedQuickSettingsOffset))
    }
    
    QuickSettingsDrawer {
        id: quickSettings
        z: 1 // ensure it's above notifications
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        
        actionDrawer: root.actionDrawer
        
        // opacity and move animation (disabled when openToPinnedMode is false)
        property real offsetDist: actionDrawer.offset - minimizedQuickSettingsOffset
        property real totalOffsetDist: maximizedQuickSettingsOffset - minimizedQuickSettingsOffset
        minimizedToFullProgress: actionDrawer.openToPinnedMode ? (actionDrawer.opened ? applyMinMax(offsetDist / totalOffsetDist) : 0) : 1
        
        // this drawer opens in two stages when pinned mode is enabled:
        // ---
        // stage 1: the transform effect is used, the drawer physically moves down to the pinned mode
        // stage 2: the rectangle increases height to reveal content, but the content stays still
        // when pinned mode is disabled, only stage 1 happens
        
        // increase height of drawer when between pinned mode <-> maximized mode
        addedHeight: {
            if (!actionDrawer.openToPinnedMode) {
                // if pinned mode disabled, just go to full height
                return quickSettings.maxAddedHeight;
            } else if (!actionDrawer.opened) {
                // over-scroll effect for initial opening
                let progress = (root.actionDrawer.offset - minimizedQuickSettingsOffset) / quickSettings.maxAddedHeight;
                let effectProgress = Math.atan(Math.max(0, progress));
                return quickSettings.maxAddedHeight * 0.25 * effectProgress;
            } else {
                // as the drawer opens, add height to the rectangle, revealing content
                return Math.max(0, Math.min(quickSettings.maxAddedHeight, root.actionDrawer.offset - minimizedQuickSettingsOffset));
            }
        }
        
        // physically move the drawer when between closed <-> pinned mode
        transform: Translate {
            id: translate
            readonly property real offsetHeight: actionDrawer.openToPinnedMode ? minimizedQuickSettingsOffset : maximizedQuickSettingsOffset
            y: Math.min(root.actionDrawer.offset - offsetHeight, 0)
        }
    }
    
    MobileShell.NotificationsWidget {
        id: notificationWidget
        historyModel: root.actionDrawer.notificationModel
        historyModelType: root.actionDrawer.notificationModelType
        notificationSettings: root.actionDrawer.notificationSettings
        actionsRequireUnlock: root.actionDrawer.restrictedPermissions
        onUnlockRequested: root.actionDrawer.permissionsRequested()
        
        Connections {
            target: root.actionDrawer
            
            function onRunPendingNotificationAction() {
                notificationWidget.runPendingAction();
            }
        }
        
        onBackgroundClicked: root.actionDrawer.close();
        
        anchors {
            top: quickSettings.top
            topMargin: quickSettings.height + translate.y
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        opacity: applyMinMax(root.actionDrawer.offset / root.minimizedQuickSettingsOffset)
        
        // HACK: there are weird issues with text rendering black regardless of opacity, just set the text to be invisible once it's out
        visible: opacity > 0.05
    }
}
