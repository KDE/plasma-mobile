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
    
    readonly property real minimizedQuickSettingsOffset: quickSettings.minimizedHeight
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
                       notificationWidget.hasNotifications ? 0.95 : 0.7)
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
        
        // opacity and move animation
        property real offsetDist: actionDrawer.offset - minimizedQuickSettingsOffset
        property real totalOffsetDist: maximizedQuickSettingsOffset - minimizedQuickSettingsOffset
        minimizedToFullProgress: actionDrawer.opened ? applyMinMax(offsetDist / totalOffsetDist) : 0
        
        addedHeight: {
            if (!actionDrawer.opened) {
                // over-scroll effect for initial opening
                let progress = (root.actionDrawer.offset - minimizedQuickSettingsOffset) / quickSettings.maxAddedHeight;
                let effectProgress = Math.atan(Math.max(0, progress));
                return quickSettings.maxAddedHeight * 0.25 * effectProgress;
            } else {
                return Math.max(0, Math.min(quickSettings.maxAddedHeight, root.actionDrawer.offset - minimizedQuickSettingsOffset));
            }
        }
        
        transform: Translate {
            id: translate
            y: Math.min(root.actionDrawer.offset - minimizedQuickSettingsOffset, 0)
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
            bottomMargin: PlasmaCore.Units.largeSpacing
            left: parent.left
            leftMargin: PlasmaCore.Units.largeSpacing
            right: parent.right
            rightMargin: PlasmaCore.Units.largeSpacing
        }
        opacity: applyMinMax(root.actionDrawer.offset / root.minimizedQuickSettingsOffset)
    }
}
