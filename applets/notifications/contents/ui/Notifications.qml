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

import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.qtextracomponents 0.1
import org.kde.plasma.extras 0.1 as PlasmaExtras

Item {
    id: notificationsApplet
    state: "default"
    width: 32
    height: 32
    property int minimumWidth: mainScrollArea.implicitWidth
    property int minimumHeight: mainScrollArea.implicitHeight

    property real globalProgress: 0

    Component.onCompleted: {
        //plasmoid.popupIcon = QIcon("preferences-desktop-notification")
        plasmoid.aspectRatioMode = "ConstrainedSquare"
        plasmoid.status = PassiveStatus
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

        function popup(text)
        {
            lastNotificationText.text = text

            var pos = lastNotificationPopup.popupPosition(notificationsApplet, Qt.AlignCenter)
            lastNotificationPopup.x = pos.x
            lastNotificationPopup.y = pos.y
            lastNotificationPopup.visible = true
            lastNotificationTimer.running = true
        }

        location: plasmoid.location
        windowFlags: windowFlags|Qt.WindowStaysOnTopHint
        mainItem: Item {
            width: 300
            height: lastNotificationText.height+50
            PlasmaComponents.Label {
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

    property Component compactRepresentation: Component {
        PlasmaCore.SvgItem {
            id: notificationSvgItem
            svg: notificationSvg
            elementId: "notification-disabled"
            anchors.fill: parent
            state: notificationsApplet.state
            PlasmaCore.Svg {
                id: notificationSvg
                imagePath: "icons/notification"
            }

            Item {
                id: jobProgressItem
                width: notificationSvgItem.width * globalProgress
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

            PlasmaComponents.Label {
                id: countText
                text: notificationsRepeater.count+jobsRepeater.count
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (notificationsRepeater.count + jobsRepeater.count > 0) {
                        plasmoid.togglePopup()
                    } else {
                        plasmoid.hidePopup()
                    }
                }
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
            lastNotificationPopup.popup(String(data[i]["body"]).replace("\n", " "))
        }
    }

    PlasmaCore.DataSource {
        id: jobsSource
        engine: "applicationjobs"
        interval: 0

        onSourceAdded: {
            connectSource(source);
        }
        property variant runningJobs

        onSourceRemoved: {
            notificationsModel.append({"appIcon" : runningJobs[source]["appIcon"],
                                "appName" : runningJobs[source]["appName"],
                                "summary" : i18n("%1 [Finished]", runningJobs[source]["infoMessage"]),
                                "body" : runningJobs[source]["label1"],
                                "expireTimeout" :0,
                                "urgency": 0});
            lastNotificationPopup.popup(runningJobs[source]["label1"])
            delete runningJobs[source]
        }
        Component.onCompleted: {
            jobsSource.runningJobs = new Object
            connectedSources = sources
        }
        onNewData: {
            var jobs = runningJobs
            jobs[sourceName] = data
            runningJobs = jobs
        }
        onDataChanged: {
            var total = 0
            for (var i = 0; i < sources.length; ++i) {
                total += jobsSource.data[sources[i]]["percentage"]
            }

            total /= sources.length
            globalProgress = total/100
        }
    }

    PlasmaExtras.ScrollArea {
        id: mainScrollArea
        anchors.fill: parent
        implicitWidth: 400
        implicitHeight: Math.max(250, Math.min(450, contentsColumn.height))

        Flickable {
            id: popupFlickable
            anchors.fill:parent

            contentWidth: width
            contentHeight: contentsColumn.height
            clip: true

            Column {
                id: contentsColumn
                width: popupFlickable.width
                Title {
                    visible: jobsRepeater.count > 0
                    text: i18n("Transfers")
                }
                Repeater {
                    id: jobsRepeater
                    model: jobsSource.sources
                    delegate: JobDelegate {}
                    onCountChanged: {
                        if (count+notificationsRepeater.count > 0) {
                            notificationsApplet.state = "new-notifications"
                        } else {
                            notificationsApplet.state = "default"
                            plasmoid.hidePopup()
                        }
                    }
                }
                Title {
                    visible: notificationsRepeater.count > 0
                    text: i18n("Notifications")
                    PlasmaComponents.ToolButton {
                        iconSource: "window-close"
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        onClicked: notificationsModel.clear()
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
                            plasmoid.hidePopup()
                        }
                    }
                    delegate: NotificationDelegate {}
                }
            }
        }
    }
}
