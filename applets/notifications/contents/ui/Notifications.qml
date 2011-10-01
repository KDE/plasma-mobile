/***************************************************************************
 *   Copyright 2011 Davide Bettio <davide.bettio@kdemail.net>              *
 *   Copyright 2011 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Library General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU Library General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1
import org.kde.plasma.mobilecomponents 0.1 as PlasmaComponents

Item {
    id: notificationsApplet
    state: "default"
    width: 32
    height: 32

    Component.onCompleted: {
        //plasmoid.popupIcon = QIcon("preferences-desktop-notification")
        plasmoid.aspectRatioMode = "ConstrainedSquare"
        plasmoid.status = PassiveStatus
    }

    states: [
        State {
            name: "default"
            PropertyChanges {
                target: notificationSvgItem
                elementId: "notification-disabled"
            }
            PropertyChanges {
                target: countText
                visible: false
            }
            PropertyChanges {
                target: plasmoid
                status: PassiveStatus
            }
        },
        State {
            name: "new-notifications"
            PropertyChanges {
                target: notificationSvgItem
                elementId: "notification-empty"
            }
            PropertyChanges {
                target: countText
                visible: true
            }
            PropertyChanges {
                target: plasmoid
                status: ActiveStatus
            }
        }
    ]

    PlasmaCore.Svg {
        id: notificationSvg
        imagePath: "icons/notification"
    }

    PlasmaCore.Theme {
        id: theme
    }

    PlasmaCore.Svg {
        id: configIconsSvg
        imagePath: "widgets/configuration-icons"
    }

    Timer {
        id: lastNotificationTimer
        interval: 3000
        repeat: false
        running: false
        onTriggered: lastNotificationPopup.visible = false
    }
    PlasmaCore.Dialog {
        id: lastNotificationPopup
        location: plasmoid.location
        windowFlags: windowFlags|Qt.WindowStaysOnTopHint
        mainItem: Item {
            width: 300
            height: lastNotificationText.height+50
            Text {
                id: lastNotificationText
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                //textFormat: Text.PlainText
                color: theme.textColor
                wrapMode: Text.Wrap
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    lastNotificationPopup.visible = false
                    lastNotificationTimer.running = false
                }
            }
        }
    }

    PlasmaCore.SvgItem {
        id: notificationSvgItem
        svg: notificationSvg
        elementId: "notification-disabled"
        anchors.fill: parent
        Item {
            id: jobProgressItem
            width: 0
            clip: true
            visible: jobsSource.sources.length > 0
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            PlasmaCore.SvgItem {
                svg: notificationSvg
                elementId: "notification-progress-active"
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: notificationSvgItem.width
            }
        }

        Text {
            id: countText
            text: notificationsRepeater.count+jobsRepeater.count
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (popup.visible) {
                    popup.visible = false
                } else if (notificationsRepeater.count+jobsRepeater.count > 0) {
                    var pos = popup.popupPosition(notificationsApplet, Qt.AlignCenter)
                    popup.x = pos.x
                    popup.y = pos.y
                    popup.visible = true
                }
            }
        }
    }


    ListModel {
        id: notificationsModel
    }

    PlasmaCore.DataSource {
        id: notificationsSource
        engine: "notifications"
        interval: 0

        onSourceAdded: {
            connectSource(source);
        }

        onNewData: {
            notificationsModel.append({"appIcon" : notificationsSource.data[sourceName]["appIcon"],
                                "appName" : notificationsSource.data[sourceName]["appName"],
                                "summary" : notificationsSource.data[sourceName]["summary"],
                                "body" : notificationsSource.data[sourceName]["body"],
                                "expireTimeout" : notificationsSource.data[sourceName]["expireTimeout"],
                                "urgency": notificationsSource.data[sourceName]["urgency"]});
        }

        onDataChanged: {
            var i = connectedSources[connectedSources.length-1]
            lastNotificationText.text = String(data[i]["body"]).replace("\n", " ")

            var pos = lastNotificationPopup.popupPosition(notificationsApplet, Qt.AlignCenter)
            lastNotificationPopup.x = pos.x
            lastNotificationPopup.y = pos.y
            lastNotificationPopup.visible = true
            lastNotificationTimer.running = true
        }
    }

    PlasmaCore.DataSource {
        id: jobsSource
        engine: "applicationjobs"
        interval: 0

        onSourceAdded: {
            connectSource(source);
        }
        Component.onCompleted: {
            connectedSources = sources
        }
        onDataChanged: {
            var total = 0
            for (var i = 0; i < sources.length; ++i) {
                total += jobsSource.data[sources[i]]["percentage"]
            }

            total /= sources.length
            jobProgressItem.width = notificationSvgItem.width * (total/100)
        }
    }

    PlasmaCore.Dialog {
        id: popup
        location: plasmoid.location
        windowFlags: Qt.Popup
        mainItem: Flickable {
            id: popupFlickable
            width: Math.max(300, contentsColumn.width)
            height: Math.min(350, contentHeight)
            contentWidth: contentsColumn.width
            contentHeight: contentsColumn.height
            clip: true

            Column {
                id: contentsColumn
                Repeater {
                    id: jobsRepeater
                    model: jobsSource.sources
                    delegate: JobDelegate {}
                    onCountChanged: {
                        if (count+notificationsRepeater.count > 0) {
                            notificationsApplet.state = "new-notifications"
                        } else {
                            notificationsApplet.state = "default"
                            popup.visible = false
                        }
                    }
                }
                Repeater {
                    id: notificationsRepeater
                    model: notificationsModel
                    onCountChanged: {
                        if (count+jobsRepeater.count > 0) {
                            notificationsApplet.state = "new-notifications"
                        } else {
                            notificationsApplet.state = "default"
                            popup.visible = false
                        }
                    }
                    delegate: NotificationDelegate {}
                }
            }
        }
    }
}
