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
import org.kde.locale 0.1 as KLocale

Item {
    id: notificationsApplet
    state: "default"
    width: 32
    height: 32
    property int minimumWidth: mainScrollArea.implicitWidth
    property int minimumHeight: mainScrollArea.implicitHeight

    property real globalProgress: 0

    property Item notificationIcon

    Component.onCompleted: {
        //plasmoid.popupIcon = QIcon("preferences-desktop-notification")
        plasmoid.aspectRatioMode = "ConstrainedSquare"
        plasmoid.status = PassiveStatus
        allApplications = new Object
    }

    KLocale.Locale {
        id: locale
    }

    PlasmaCore.Svg {
        id: configIconsSvg
        imagePath: "widgets/configuration-icons"
    }

    LastNotificationPopup {
        id: lastNotificationPopup
    }


    property Component compactRepresentation: Component {
        NotificationIcon {
            id: notificationIcon
            Component.onCompleted: notificationsApplet.notificationIcon = notificationIcon
        }
    }


    ListModel {
        id: notificationsModel
    }
    ListModel {
        id: allApplicationsModel
        function addApplication(icon, name)
        {
            for (var i = 0; i < count; ++i) {
                var item = get(i)
                if (item.name == name) {
                    setProperty(i, "count", item.count + 1)
                    return
                }
            }
            append({"icon": icon, "name": name, "count": 1})
        }
        function removeApplication(name)
        {
            for (var i = 0; i < count; ++i) {
                var item = get(i)
                if (item.name == name) {
                    if (item.count <= 1) {
                        remove(i)
                        appTabBar.currentTab = allAppsTab
                        return
                    }
                    setProperty(i, "count", item.count - 1)
                    return
                }
            }
        }
    }

    PlasmaCore.DataSource {
        id: notificationsSource
        engine: "notifications"
        interval: 0

        onSourceAdded: {
            connectSource(source);
        }

        onNewData: {
            notificationsModel.insert(0, {"appIcon" : notificationsSource.data[sourceName]["appIcon"],
                                "appName" : notificationsSource.data[sourceName]["appName"],
                                "summary" : notificationsSource.data[sourceName]["summary"],
                                "body" : notificationsSource.data[sourceName]["body"],
                                "expireTimeout" : notificationsSource.data[sourceName]["expireTimeout"],
                                "urgency": notificationsSource.data[sourceName]["urgency"]});
        }

        onDataChanged: {
            var i = connectedSources[connectedSources.length-1]
            lastNotificationPopup.popup(data[i]["appIcon"], String(data[i]["body"]).replace("\n", " "))
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
            var message = runningJobs[source]["label1"] ? runningJobs[source]["label1"] : runningJobs[source]["label0"]
            notificationsModel.insert(0, {"appIcon" : runningJobs[source]["appIconName"],
                                "appName" : runningJobs[source]["appName"],
                                "summary" : i18n("%1 [Finished]", runningJobs[source]["infoMessage"]),
                                "body" : message,
                                "expireTimeout" :0,
                                "urgency": 0});
            lastNotificationPopup.popup(runningJobs[source]["appIconName"], message)
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
                PlasmaComponents.ListItem {
                    visible: allApplicationsModel.count > 1
                    PlasmaComponents.TabBar {
                        id: appTabBar
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.min(implicitWidth, parent.width-8)
                        PlasmaComponents.TabButton {
                            id: allAppsTab
                            text: i18n("All")
                            iconSource: "dialog-information"
                        }
                        Repeater {
                            model: allApplicationsModel
                            PlasmaComponents.TabButton {
                                text: name
                                iconSource: icon
                            }
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
                            plasmoid.hidePopup()
                        }
                    }
                    delegate: NotificationDelegate {}
                }
            }
        }
    }
}
