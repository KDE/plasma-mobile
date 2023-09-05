/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>
 * 
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.notificationmanager 1.0 as NotificationManager

import org.kde.kirigami 2.12 as Kirigami

import org.kde.coreaddons 1.0 as KCoreAddons

import "util.js" as Util

// notification properties are in BaseNotificationItem
BaseNotificationItem {
    id: notificationItem
    implicitHeight: mainCard.implicitHeight + mainCard.anchors.topMargin + notificationHeading.height
    
    // notification heading for groups with one element
    NotificationGroupHeader {
        id: notificationHeading
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        Kirigami.Theme.colorSet: Kirigami.Theme.Header
        Kirigami.Theme.inherit: false

        visible: !notificationItem.inGroup
        height: visible ? implicitHeight : 0

        applicationName: notificationItem.applicationName
        applicationIconSource: notificationItem.applicationIconSource
        originName: notificationItem.originName
        
        notificationType: notificationItem.notificationType
        jobState: notificationItem.jobState
        jobDetails: notificationItem.jobDetails
        
        time: notificationItem.time
        timeSource: notificationItem.timeSource
    }
    
    // notification
    NotificationCard {
        id: mainCard
        anchors.topMargin: notificationHeading.visible ? Kirigami.Units.gridUnit : 0
        anchors.top: notificationHeading.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        
        tapEnabled: notificationItem.hasDefaultAction
        onTapped: notificationItem.actionInvoked("default");
        swipeGestureEnabled: notificationItem.notificationType != NotificationManager.Notifications.JobType
        onDismissRequested: notificationItem.close()
        
        ColumnLayout {
            id: column
            spacing: 0
            
            // notification summary row
            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                
                // notification summary
                PlasmaComponents.Label {
                    id: summaryLabel
                    Layout.fillWidth: true
                    textFormat: Text.PlainText
                    maximumLineCount: 3
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    text: Util.determineNotificationHeadingText(notificationItem)
                    visible: text !== ""
                    font.weight: Font.DemiBold
                }
                
                // notification timestamp
                NotificationTimeText {
                    Layout.alignment: Qt.AlignRight | Qt.AlignTop
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
                spacing: Kirigami.Units.smallSpacing

                // notification text
                NotificationBodyLabel {
                    id: bodyLabel
                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                    Layout.fillWidth: true
                    
                    // HACK RichText does not allow to specify link color and since LineEdit
                    // does not support StyledText, we have to inject some CSS to force the color,
                    // cf. QTBUG-81463 and to some extent QTBUG-80354
                    text: "<style>a { color: " + Kirigami.Theme.linkColor + "; }</style>" + notificationItem.body

                    // Cannot do text !== "" because RichText adds some HTML tags even when empty
                    visible: notificationItem.body !== ""
                }
                
                // notification icon
                Item {
                    id: iconContainer
                    Layout.preferredWidth: Kirigami.Units.iconSizes.large
                    Layout.preferredHeight: Kirigami.Units.iconSizes.large
                    Layout.topMargin: Kirigami.Units.smallSpacing
                    Layout.bottomMargin: Kirigami.Units.smallSpacing

                    visible: iconItem.active

                    Kirigami.Icon {
                        id: iconItem
                        // don't show two identical icons
                        readonly property bool active: valid && source != notificationItem.applicationIconSource
                        anchors.fill: parent
                        smooth: true
                        // don't show a generic "info" icon since this is a notification already
                        source: notificationItem.icon !== "dialog-information" ? notificationItem.icon : ""
                        visible: active
                    }
                }
            }
            
            // notification actions
            NotificationFooterActions {
                Layout.fillWidth: true
                notification: notificationItem
            }
            
            // thumbnails
            Loader {
                id: thumbnailStripLoader
                Layout.topMargin: Kirigami.Units.gridUnit
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
