/*
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.kirigami 2.12 as Kirigami

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
    
    readonly property real minimizedQuickSettingsOffset: height
    readonly property real maximizedQuickSettingsOffset: height
    
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
                       notificationWidget.hasNotifications ? 0.95 : 0.9)
        Behavior on color { ColorAnimation { duration: PlasmaCore.Units.longDuration } }
        opacity: Math.max(0, Math.min(1, actionDrawer.offset / root.minimizedQuickSettingsOffset))
    }
    
    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60 * 1000
    }
    
    // left side
    ColumnLayout {
        opacity: applyMinMax(root.actionDrawer.offset / root.maximizedQuickSettingsOffset)
        spacing: 0
        anchors {
            top: parent.top
            topMargin: Math.min(root.width, root.height) * 0.06
            bottom: parent.bottom
            bottomMargin: Math.min(root.width, root.height) * 0.06
            right: quickSettings.left
            rightMargin: Math.min(root.width, root.height) * 0.06
            left: parent.left
            leftMargin: Math.min(root.width, root.height) * 0.06
        }
        
        PlasmaComponents.Label {
            id: clock
            text: Qt.formatTime(timeSource.data.Local.DateTime, MobileShell.ShellUtil.isSystem24HourFormat ? "h:mm" : "h:mm ap")
            verticalAlignment: Qt.AlignTop
            Layout.fillWidth: true

            font.pixelSize: Math.min(40, Math.min(root.width, root.height) * 0.1)
            font.weight: Font.ExtraLight
            elide: Text.ElideRight
        }
        
        PlasmaComponents.Label {
            id: date
            text: Qt.formatDate(timeSource.data.Local.DateTime, "ddd MMMM d")
            verticalAlignment: Qt.AlignTop
            color: PlasmaCore.ColorScope.disabledTextColor
            Layout.fillWidth: true
            Layout.topMargin: PlasmaCore.Units.smallSpacing

            font.pixelSize: Math.min(20, Math.min(root.width, root.height) * 0.05)
            font.weight: Font.Light
        }
        
        MobileShell.NotificationsWidget {
            id: notificationWidget
            historyModel: root.actionDrawer.notificationModel
            notificationSettings: root.actionDrawer.notificationSettings
            
            // don't allow notifications widget to get too wide
            Layout.maximumWidth: PlasmaCore.Units.gridUnit * 25
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.topMargin: Math.min(root.width, root.height) * 0.02
        }
    }
    
    // right sidebar
    QuickSettingsPanel {
        id: quickSettings
        height: Math.min(root.height, Math.max(quickSettings.minimizedHeight, actionDrawer.offset))
        width: intendedWidth
        
        readonly property real intendedWidth: 360
        
        anchors.top: parent.top
        anchors.right: parent.right
        
        actionDrawer: root.actionDrawer
        fullHeight: root.height
        
        transform: Translate {
            id: translate
            y: Math.min(root.actionDrawer.offset - quickSettings.minimizedHeight, 0)
        }
    }
}
