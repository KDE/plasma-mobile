/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Window

import org.kde.plasma.clock
import org.kde.plasma.components 3.0 as PlasmaComponents3

import org.kde.notificationmanager as NotificationManager

import org.kde.coreaddons 1.0 as KCoreAddons

Item {
    id: notificationItem

    property var notificationsModel

    property int notificationsModelType

    /**
     * Whether the notification is allowed to invoke any action, or if it should instead
     * emit the runActionRequested(action) signal, containing the code to run.
     *
     * This is useful for cases like the lockscreen, where actions should only be run after
     * the user logs in.
     */
    property bool requestToInvoke: false

    property var model
    property int modelIndex

    property Clock clockSource

    readonly property int notificationType: model.type

    readonly property bool inGroup: model.isInGroup || false
    readonly property bool inHistory: true

    readonly property string applicationIconSource: model.applicationIconName
    readonly property string applicationName: model.applicationName
    readonly property string originName: model.originName || ""

    readonly property string summary: model.summary
    readonly property var time: model.updated || model.created

    readonly property bool hasReplyAction: model.hasReplyAction || false
    readonly property string replyActionLabel: model.replyActionLabel || ""
    readonly property string replyPlaceholderText: model.replyPlaceholderText || ""
    readonly property string replySubmitButtonText: model.replySubmitButtonText || ""
    readonly property string replySubmitButtonIconName: model.replySubmitButtonIconName || ""

    // configure button on every single notifications is a bit overwhelming
    readonly property bool configurable: !inGroup && model.configurable

    readonly property bool dismissable: model.type === NotificationManager.Notifications.JobType
        && model.jobState !== NotificationManager.Notifications.JobStateStopped
        && model.dismissed
        && notificationSettings.permanentJobPopups
    readonly property bool dismissed: model.dismissed || false
    readonly property bool closable: model.closable

    readonly property string body: model.body || ""
    readonly property var icon: model.image || model.iconName

    readonly property var urls: model.urls || []

    readonly property int jobState: model.jobState || 0
    readonly property int percentage: model.percentage || 0
    readonly property int jobError: model.jobError || 0
    readonly property bool suspendable: !!model.suspendable
    readonly property bool killable: !!model.killable

    readonly property QtObject jobDetails: model.jobDetails || null

    readonly property string configureActionLabel: model.configureActionLabel || ""
    readonly property bool hasDefaultAction: model.hasDefaultAction
    readonly property bool addDefaultAction: (model.hasDefaultAction
                                            && model.defaultActionLabel
                                            && (model.actionLabels || []).indexOf(model.defaultActionLabel) === -1) ? true : false
    readonly property var actionNames: {
        var actions = (model.actionNames || []);
        if (addDefaultAction) {
            actions.unshift("default"); // prepend
        }
        return actions;
    }
    readonly property var actionLabels: {
        var labels = (model.actionLabels || []);
        if (addDefaultAction) {
            labels.unshift(model.defaultActionLabel);
        }
        return labels;
    }

    /**
     * This signal is emitted and intended for the parent to make its own decision
     * on whether to run the requested notification action.
     */
    signal runActionRequested()

    signal actionInvoked(string actionName)
    signal replied(string text)
    signal openUrl(string url)
    signal fileActionInvoked(QtObject action)

    signal suspendJobClicked
    signal resumeJobClicked
    signal killJobClicked

    function expire() {
        if (model.resident) {
            model.expired = true;
        } else {
            if (notificationsModelType === NotificationsModelType.WatchedNotificationsModel) {
                notificationsModel.expire(model.notificationId);
            } else if (notificationsModelType === NotificationsModelType.NotificationsModel) {
                notificationsModel.expire(notificationsModel.index(modelIndex, 0));
            }
        }
    }

    function close() {
        if (notificationsModelType === NotificationsModelType.WatchedNotificationsModel) {
            notificationsModel.close(model.notificationId);
        } else if (notificationsModelType === NotificationsModelType.NotificationsModel) {
            notificationsModel.close(notificationsModel.index(modelIndex, 0));
        }
    }

    // TODO call
    function configure() {
        notificationsModel.configure(notificationsModel.index(modelIndex, 0))
    }

    property var pendingAction: () => {}
    function runPendingAction() {
        pendingAction();
    }

    onActionInvoked: {
        let action = () => {
            if (notificationsModelType === NotificationsModelType.WatchedNotificationsModel) {
                if (actionName === "") {
                    notificationsModel.invokeDefaultAction(model.notificationId, NotificationManager.None);
                } else {
                    notificationsModel.invokeAction(notificationItem.model.notificationId, actionName, NotificationManager.None);
                }
            } else if (notificationsModelType === NotificationsModelType.NotificationsModel) {
                if (actionName === "default") {
                    notificationsModel.invokeDefaultAction(notificationsModel.index(modelIndex, 0),  NotificationManager.Close); // notification closes
                } else {
                    notificationsModel.invokeAction(notificationsModel.index(modelIndex, 0), actionName,  NotificationManager.Close); // notification closes
                }
            }
        }

        if (notificationItem.requestToInvoke) {
            pendingAction = action;
            runActionRequested();
        } else {
            action();
        }
    }

    onOpenUrl: {
        let action = () => {
            Qt.openUrlExternally(url);
            expire();
        }

        if (notificationItem.requestToInvoke) {
            pendingAction = action;
            runActionRequested();
        } else {
            action();
        }
    }

    onFileActionInvoked: {
        let action = () => {
            if (action.objectName === "movetotrash" || action.objectName === "deletefile") {
                close();
            } else {
                expire();
            }
        }

        if (notificationItem.requestToInvoke) {
            pendingAction = action;
            runActionRequested();
        } else {
            action();
        }
    }

    onSuspendJobClicked: {
        let action = () => notificationsModel.suspendJob(notificationsModel.index(modelIndex, 0));

        if (notificationItem.requestToInvoke) {
            pendingAction = action;
            runActionRequested();
        } else {
            action();
        }
    }

    onResumeJobClicked: {
        let action = () => notificationsModel.resumeJob(notificationsModel.index(modelIndex, 0));

        if (notificationItem.requestToInvoke) {
            pendingAction = action;
            runActionRequested();
        } else {
            action();
        }
    }

    onKillJobClicked: {
        let action = () => notificationsModel.killJob(notificationsModel.index(modelIndex, 0));

        if (notificationItem.requestToInvoke) {
            pendingAction = action;
            runActionRequested();
        } else {
            action();
        }
    }
}

