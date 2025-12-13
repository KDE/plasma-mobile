/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

.import org.kde.notificationmanager as NotificationManager
.import org.kde.coreaddons 1.0 as KCoreAddons
.import QtQml as QtQml

function determineNotificationHeadingText(notificationItem) {
    if (notificationItem.notificationType === NotificationManager.Notifications.JobType) {
        if (notificationItem.jobState === NotificationManager.Notifications.JobStateSuspended) {
            if (notificationItem.summary) {
                return i18nc("Job name, e.g. Copying is paused", "%1 (Paused)", notificationItem.summary);
            }
        } else if (notificationItem.jobState === NotificationManager.Notifications.JobStateStopped) {
            if (notificationItem.jobError) {
                if (notificationItem.summary) {
                    return i18nc("Job name, e.g. Copying has failed", "%1 (Failed)", notificationItem.summary);
                } else {
                    return i18n("Job Failed");
                }
            } else if (notificationItem.summary) {
                return i18ndc("plasma_applet_org.kde.plasma.notifications", "Job name, e.g. Copying has finished", "%1 (Finished)", notificationItem.summary);
            }
            return i18nd("plasma_applet_org.kde.plasma.notifications", "Job Finished");
        }
    }
    // some apps use their app name as summary, avoid showing the same text twice
    // try very hard to match the two
    if (notificationItem.summary && notificationItem.summary.toLocaleLowerCase().trim() !== notificationItem.applicationName.toLocaleLowerCase().trim()) {
        return notificationItem.summary;
    }
    return "";
}

function generateNotificationHeaderAgoText(time, jobState) {
    if (!time || isNaN(time.getTime()) || jobState === NotificationManager.Notifications.JobStateRunning) {
        return "";
    }

    const deltaMinutes = Math.floor((Date.now() - time.getTime()) / 1000 / 60);
    if (deltaMinutes < 1) {
        return i18n("now");
    }

    // Received less than an hour ago, show relative minutes
    if (deltaMinutes < 60) {
        return i18nc("Notification was added minutes ago, keep short", "%1m ago", deltaMinutes);
    }
    // Received less than a day ago, show time, 22 hours so the time isn't as ambiguous between today and yesterday
    if (deltaMinutes < 60 * 22) {
        return Qt.formatTime(time, Qt.locale().timeFormat(QtQml.Locale.ShortFormat).replace(/.ss?/i, ""));
    }

    // Otherwise show relative date (Yesterday, "Last Sunday", or just date if too far in the past)
    return KCoreAddons.Format.formatRelativeDate(time, QtQml.Locale.ShortFormat);
}

function generateNotificationHeaderRemainingText(notificationType, jobState, jobDetails) {
    if (notificationType !== NotificationManager.Notifications.JobType || jobState !== NotificationManager.Notifications.JobStateRunning) {
        return "";
    }

    const details = jobDetails;
    if (!details || !details.speed) {
        return "";
    }

    var remaining = details.totalBytes - details.processedBytes;
    if (remaining <= 0) {
        return "";
    }

    var eta = remaining / details.speed;
    if (eta < 0.5) { // Avoid showing "0 seconds remaining"
        return "";
    }

    if (eta < 60) { // 1 minute
        return i18nc("seconds remaining, keep short", "%1 s remaining", Math.round(eta));
    }
    if (eta < 60 * 60) {// 1 hour
        return i18nc("minutes remaining, keep short", "%1m remaining", Math.round(eta / 60));
    }
    if (eta < 60 * 60 * 5) { // 5 hours max, if it takes even longer there's no real point in showing that
        return i18nc("hours remaining, keep short", "%1h remaining", Math.round(eta / 60 / 60));
    }

    return "";
}
