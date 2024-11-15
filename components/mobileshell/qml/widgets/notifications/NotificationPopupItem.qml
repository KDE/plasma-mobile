/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.notificationmanager as NotificationManager

import org.kde.kirigami 2.12 as Kirigami

import org.kde.coreaddons 1.0 as KCoreAddons

// notification properties are in BaseNotificationItem
BaseNotificationItem {
    id: notificationItem
    implicitHeight: mainCard.implicitHeight

    property bool inPopupDrawer: false
    property int currentPopupHeight: 0
    property real remainingTimeProgress: 1
    property bool closeTimerRunning: false

    property bool inLockscreen: false

    signal dragStart()
    signal dragEnd()
    signal takeFocus()
    signal dismissRequested()

    // notification
    NotificationCard {
        id: mainCard
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        popupNotification: true
        inPopupDrawer: notificationItem.inPopupDrawer
        currentPopupHeight: notificationItem.currentPopupHeight
        remainingTimeProgress: notificationItem.remainingTimeProgress
        closeTimerRunning: notificationItem.closeTimerRunning
        tapEnabled: notificationItem.hasDefaultAction
        onTapped: notificationItem.actionInvoked("default");
        swipeGestureEnabled: notificationItem.closable
        onDismissRequested: {
            model.resident = false;
            notificationItem.dismissRequested();
            notificationItem.close();
        }

        onDragStart: notificationItem.dragStart()
        onDragEnd: notificationItem.dragEnd()

        ColumnLayout {
            id: column
            spacing: 0

            opacity: notificationItem.inPopupDrawer ? 0 : 1
            Behavior on opacity {
                NumberAnimation {
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutExpo
                }
            }

            // notification summary row
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Layout.fillWidth: true
                Layout.bottomMargin: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    id: applicationIconItem
                    Layout.topMargin: Kirigami.Units.smallSpacing
                    Layout.bottomMargin: Kirigami.Units.smallSpacing
                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                    source: notificationItem.applicationIconSource
                    visible: valid
                }

                PlasmaComponents.Label {
                    id: applicationNameLabel
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                    Layout.fillWidth: true

                    color: Kirigami.Theme.textColor

                    elide: Text.ElideLeft
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize
                    text: notificationItem.applicationName + (notificationItem.originName ? " · " + notificationItem.originName : "")
                }

                // notification timestamp
                NotificationTimeText {
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                    Layout.topMargin: Kirigami.Units.smallSpacing
                    Layout.bottomMargin: Kirigami.Units.smallSpacing
                    notificationType: notificationItem.notificationType
                    jobState: notificationItem.jobState
                    jobDetails: notificationItem.jobDetails

                    time: notificationItem.time
                    timeSource: notificationItem.timeSource
                }
            }

            // notification contents
            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.smallSpacing
                Layout.alignment: Qt.AlignTop

                ColumnLayout {
                    Layout.alignment: Qt.AlignTop

                    // notification summary
                    PlasmaComponents.Label {
                        id: summaryLabel
                        Layout.fillWidth: true
                        textFormat: Text.PlainText
                        maximumLineCount: 3
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize
                        text: MobileShell.NotificationsUtils.determineNotificationHeadingText(notificationItem)
                        visible: text !== ""
                        font.weight: Font.DemiBold
                    }


                    // notification text
                    NotificationBodyLabel {
                        id: bodyLabel
                        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                        Layout.preferredWidth: column.width - iconContainer.width - Kirigami.Units.smallSpacing

                        text: ShellUtil.toPlainText(notificationItem.body)
                    }

                }

                // notification icon
                Item {
                    id: iconContainer
                    Layout.fillHeight: true
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                    Layout.topMargin: Kirigami.Units.smallSpacing
                    Layout.bottomMargin: Kirigami.Units.smallSpacing

                    visible: iconItem.shouldBeShown

                    Kirigami.Icon {
                        id: iconItem
                        // don't show two identical icons
                        readonly property bool shouldBeShown: valid && source != notificationItem.applicationIconSource
                        anchors.fill: parent
                        smooth: true
                        // don't show a generic "info" icon since this is a notification already
                        source: notificationItem.icon !== "dialog-information" ? notificationItem.icon : ""
                        visible: shouldBeShown
                    }
                }
            }

            // Job progress reporting
            Loader {
                id: jobLoader
                Layout.fillWidth: true
                Layout.preferredHeight: item ? item.implicitHeight : 0
                active: notificationItem.notificationType === NotificationManager.Notifications.JobType
                visible: active
                sourceComponent: NotificationJobItem {
                    iconContainerItem: iconContainer

                    jobState: notificationItem.jobState
                    jobError: notificationItem.jobError
                    percentage: notificationItem.percentage
                    suspendable: notificationItem.suspendable
                    killable: notificationItem.killable

                    jobDetails: notificationItem.jobDetails

                    onSuspendJobClicked: notificationItem.suspendJobClicked()
                    onResumeJobClicked: notificationItem.resumeJobClicked()
                    onKillJobClicked: notificationItem.killJobClicked()

                    onOpenUrl: notificationItem.openUrl(url)
                    onFileActionInvoked: notificationItem.fileActionInvoked(action)
                }
            }

            // notification actions
            NotificationFooterActions {
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing
                notification: notificationItem
                onTakeFocus: notificationItem.takeFocus()

                popupNotification: true
            }

            // thumbnails
            Loader {
                id: thumbnailStripLoader
                Layout.topMargin: Kirigami.Units.largeSpacing
                Layout.fillWidth: true
                active: notificationItem.urls.length > 0
                visible: active
                asynchronous: true
                sourceComponent: ThumbnailStrip {
                    leftPadding: -thumbnailStripLoader.Layout.leftMargin
                    rightPadding: -thumbnailStripLoader.Layout.rightMargin
                    topPadding: -notificationItem.thumbnailTopPadding
                    bottomPadding: -thumbnailStripLoader.Layout.bottomMargin
                    urls: notificationItem.urls
                    onOpenUrl: notificationItem.openUrl(url)
                    onFileActionInvoked: notificationItem.fileActionInvoked(action)
                }
            }
        }
    }
}
