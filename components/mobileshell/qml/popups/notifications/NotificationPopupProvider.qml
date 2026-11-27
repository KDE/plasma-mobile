/*
    SPDX-FileCopyrightText: 2024 Micah Stanley <stanleymicah@proton.me>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.hapticsplugin as HapticsPlugin

import org.kde.notificationmanager as NotificationManager
import org.kde.plasma.clock

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

    property var popupNotificationsModel: NotificationManager.Notifications {
        showExpired: false
        showDismissed: false
        blacklistedDesktopEntries: notificationSettings.popupBlacklistedApplications
        blacklistedNotifyRcNames: notificationSettings.popupBlacklistedServices
        whitelistedDesktopEntries: notificationProvider.inhibited ? notificationSettings.doNotDisturbPopupWhitelistedApplications : []
        whitelistedNotifyRcNames: notificationProvider.inhibited ? notificationSettings.doNotDisturbPopupWhitelistedServices : []

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

    // Alert (sound hint + vibration) when new notification popups appear
    property QtObject __popupAlerts: Connections {
        target: notificationProvider.popupNotificationsModel

        function onRowsInserted(parent, first, last) {
            for (let row = first; row <= last; ++row) {
                notificationProvider.alertForPopup(notificationProvider.popupNotificationsModel.index(row, 0, parent));
            }
        }
    }

    // Short double buzz, as [amplitude, durationMs] pairs
    readonly property var notificationVibrationPattern: [[1.0, 60], [0.0, 80], [1.0, 60]]

    readonly property int maxAlertAgeMs: 5000
    readonly property int minVibrationIntervalMs: 1000
    property var __alertedIds: []
    property real __lastVibrationTime: 0

    function alertForPopup(idx) {
        const model = notificationProvider.popupNotificationsModel;

        if (model.data(idx, NotificationManager.Notifications.TypeRole) !== NotificationManager.Notifications.NotificationType) {
            return;
        }

        const id = model.data(idx, NotificationManager.Notifications.IdRole);
        if (__alertedIds.includes(id)) {
            return;
        }

        const created = model.data(idx, NotificationManager.Notifications.CreatedRole);
        if (!created || Date.now() - created.getTime() > maxAlertAgeMs) {
            return;
        }

        // Reassign rather than mutate in place, and only remember the most recent ids
        __alertedIds = __alertedIds.concat([id]).slice(-50);

        // Plays the sound hint for notifications that don't play their own sound (ex. non-KNotification apps)
        model.playSoundHint(idx);

        if (!ShellSettings.Settings.notificationVibrationsEnabled) {
            return;
        }
        if (model.data(idx, NotificationManager.Notifications.UrgencyRole) === NotificationManager.Notifications.LowUrgency) {
            return;
        }
        if (model.data(idx, NotificationManager.Notifications.UserActionFeedbackRole)) {
            return;
        }

        // Avoid a burst of vibrations when many notifications arrive at once
        const now = Date.now();
        if (now - __lastVibrationTime < minVibrationIntervalMs) {
            return;
        }
        __lastVibrationTime = now;

        HapticsPlugin.VibrationManager.vibratePattern(notificationVibrationPattern);
    }

    // TODO use pulseaudio-qt for this once it becomes a framework
    property QtObject __pulseAudio: Loader {
        source: "PulseAudio.qml"
    }

    property bool inhibited: false

    onInhibitedChanged: {
        var pa = __pulseAudio.item;
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

    property Clock clockSource: Clock {
        id: clockSource
        onTimeChanged: {
            checkInhibition();
            npm.timeChanged();
        }
    }

    property var npm: NotificationPopupManager {
        notificationModelType: notificationProvider.notificationModelType
        notificationSettings: notificationProvider.notificationSettings
        popupNotificationsModel: notificationProvider.popupNotificationsModel
        clockSource: notificationProvider.clockSource
        inhibited: notificationProvider.inhibited
        tasksModel: notificationProvider.tasksModel
    }
}
