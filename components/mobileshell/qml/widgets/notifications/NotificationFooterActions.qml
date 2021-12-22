/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>
 * 
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: actionContainer
    
    required property BaseNotificationItem notification
    
    implicitHeight: Math.max(actionFlow.implicitHeight, replyLoader.height)
    visible: actionRepeater.count > 0
    
    Flow {
        id: actionFlow
        width: parent.width
        spacing: PlasmaCore.Units.smallSpacing
        layoutDirection: Qt.RightToLeft
        enabled: !replyLoader.active
        opacity: replyLoader.active ? 0 : 1
        
        Behavior on opacity {
            NumberAnimation {
                duration: PlasmaCore.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        // action buttons
        Repeater {
            id: actionRepeater

            model: {
                const buttons = [];
                var actionNames = (notificationItem.actionNames || []);
                var actionLabels = (notificationItem.actionLabels || []);
                for (var i = actionNames.length - 1; i >= 0; --i) {
                    buttons.push({
                        actionName: actionNames[i],
                        label: actionLabels[i]
                    });
                }
                
                if (notificationItem.hasReplyAction) {
                    buttons.unshift({
                        actionName: "inline-reply",
                        label: notificationItem.replyActionLabel || i18nc("Reply to message", "Reply")
                    });
                }
                
                return buttons;
            }

            PlasmaComponents.ToolButton {
                flat: false
                text: modelData.label || ""

                onClicked: {
                    if (modelData.actionName === "inline-reply") {
                        replyLoader.beginReply();
                        return;
                    }
                    notificationItem.actionInvoked(modelData.actionName);
                }
            }
        }
    }
    
    // inline reply field
    Loader {
        id: replyLoader
        width: parent.width
        height: active ? item.implicitHeight : 0
        
        // When there is only one action and it is a reply action, show text field right away
        active: false
        visible: active
        opacity: active ? 1 : 0
        x: active ? 0 : parent.width
        
        Behavior on x {
            NumberAnimation {
                duration: PlasmaCore.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: PlasmaCore.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        function beginReply() {
            active = true
            replyLoader.item.activate();
        }

        sourceComponent: NotificationReplyField {
            placeholderText: notificationItem.replyPlaceholderText
            buttonIconName: notificationItem.replySubmitButtonIconName
            buttonText: notificationItem.replySubmitButtonText
            onReplied: notificationItem.replied(text)
            
            replying: replyLoader.active
            onBeginReplyRequested: replyLoader.beginReply()
        }
    }
}
