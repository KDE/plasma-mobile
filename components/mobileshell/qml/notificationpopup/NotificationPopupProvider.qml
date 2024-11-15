/*
 *  SPDX-FileCopyrightText: 2024 Micah Stanley <stanleymicah@proton.me>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell as MobileShell

import org.kde.notificationmanager as NotificationManager
import org.kde.plasma.plasma5support 2.0 as P5Support

import org.kde.taskmanager 0.1 as TaskManager

/**
 * This sets up and manages the notification popup settings
 */
QtObject {
    id: notificationProvider

    property var notificationModelType: MobileShell.NotificationsModelType.NotificationsModel

    property QtObject notificationSettings: NotificationManager.Settings {
        onNotificationsInhibitedUntilChanged: notificationProvider.checkInhibition()
    }

    property QtObject popupNotificationsModel: NotificationManager.Notifications {
        showExpired: false
        showDismissed: false
        blacklistedDesktopEntries: notificationSettings.popupBlacklistedApplications
        blacklistedNotifyRcNames: notificationSettings.popupBlacklistedServices
        whitelistedDesktopEntries: []
        whitelistedNotifyRcNames: []
        showJobs: notificationSettings.jobsInNotifications
        sortMode: NotificationManager.Notifications.SortByTypeAndUrgency
        sortOrder: Qt.DescendingOrder
        groupMode: NotificationManager.Notifications.GroupDisabled
        urgencies: {
            var urgencies = 0;

            // Critical always except in do not disturb mode when disabled in settings
            if (!notificationProvider.inhibited || notificationSettings.criticalPopupsInDoNotDisturbMode) {
                urgencies |= NotificationManager.Notifications.CriticalUrgency;
            }

            // Normal only when not in do not disturb mode
            if (!notificationProvider.inhibited) {
                urgencies |= NotificationManager.Notifications.NormalUrgency;
            }

            // Low only when enabled in settings and not in do not disturb mode
            if (!notificationProvider.inhibited && notificationSettings.lowPriorityPopups) {
                urgencies |=NotificationManager.Notifications.LowUrgency;
            }

            return urgencies;
        }
    }

    property bool inhibited: false

    onInhibitedChanged: {
        var pa = pulseAudio.item;
        if (!pa) {
            return;
        }

        var stream = pa.notificationStream;
        if (!stream) {
            return;
        }

        if (inhibited) {
            // Only remember that we muted if previously not muted.
            if (!stream.muted) {
                notificationSettings.notificationSoundsInhibited = true;
                stream.mute();
            }
        } else {
            // Only unmute if we previously muted it.
            if (notificationSettings.notificationSoundsInhibited) {
                stream.unmute();
            }
            notificationSettings.notificationSoundsInhibited = false;
        }
        notificationSettings.save();
    }

    function checkInhibition() {
        notificationProvider.inhibited = Qt.binding(function() {
            var inhibited = false;

            if (!NotificationManager.Server.valid) {
                return false;
            }

            var inhibitedUntil = notificationSettings.notificationsInhibitedUntil;
            if (!isNaN(inhibitedUntil.getTime())) {
                inhibited |= (Date.now() < inhibitedUntil.getTime());
            }

            if (notificationSettings.notificationsInhibitedByApplication) {
                inhibited |= true;
            }

            if (notificationSettings.inhibitNotificationsWhenScreensMirrored) {
                inhibited |= notificationSettings.screensMirrored;
            }

            return inhibited;
        });
    }

    property QtObject tasksModel: TaskManager.TasksModel {
        groupMode: TaskManager.TasksModel.GroupApplications
        groupInline: false
    }


    property QtObject timeSource: P5Support.DataSource {
        engine: "time"
        connectedSources: ["Local"]
        interval: 60000 // 1 min
        intervalAlignment: P5Support.Types.AlignToMinute
        onDataChanged: {
            checkInhibition();
            npm.timeChanged();
        }
    }

    property var npm: NotificationPopupManager {
        notificationModelType: notificationProvider.notificationModelType
        notificationSettings: notificationProvider.notificationSettings
        popupNotificationsModel: notificationProvider.popupNotificationsModel
        timeSource: notificationProvider.timeSource
        inhibited: notificationProvider.inhibited
        tasksModel: notificationProvider.tasksModel
    }
}
