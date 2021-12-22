/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>
 * 
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.8
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtGraphicalEffects 1.12

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.notificationmanager 1.0 as NotificationManager

import org.kde.kcoreaddons 1.0 as KCoreAddons

Item {
    id: notificationItem
    required property NotificationManager.Notifications notificationsModel
    
    property var model
    property int modelIndex
    
    property PlasmaCore.DataSource timeSource
    
    readonly property int notificationType: model.type

    readonly property bool inGroup: model.isInGroup
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
    
    // configure button on every single notifications is bit overwhelming
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

    signal actionInvoked(string actionName)
    signal replied(string text)
    signal openUrl(string url)
    signal fileActionInvoked(QtObject action)

    signal suspendJobClicked
    signal resumeJobClicked
    signal killJobClicked
    
    onActionInvoked: {
        if (actionName === "default") {
            notificationsModel.invokeDefaultAction(notificationsModel.index(modelIndex, 0));
        } else {
            notificationsModel.invokeAction(notificationsModel.index(modelIndex, 0), actionName);
        }

        expire();
    }
    onOpenUrl: {
        Qt.openUrlExternally(url);
        expire();
    }
    onFileActionInvoked: {
        if (action.objectName === "movetotrash" || action.objectName === "deletefile") {
            close();
        } else {
            expire();
        }
    }
    onSuspendJobClicked: notificationsModel.suspendJob(notificationsModel.index(modelIndex, 0))
    onResumeJobClicked: notificationsModel.resumeJob(notificationsModel.index(modelIndex, 0))
    onKillJobClicked: notificationsModel.killJob(notificationsModel.index(modelIndex, 0))

    function expire() {
        if (model.resident) {
            model.expired = true;
        } else {
            notificationsModel.expire(notificationsModel.index(modelIndex, 0));
        }
    }

    function close() {
        notificationsModel.close(notificationsModel.index(modelIndex, 0));
    }
    
    // TODO call
    function configure() {
        notificationsModel.configure(notificationsModel.index(modelIndex, 0))
    }
}

