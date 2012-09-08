/*
 *   Copyright 2012 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents

Column {
    id: notificationsRoot
    property alias count: notificationsRepeater.count

    function addNotification(source, appIcon, appName, summary, body, expireTimeout, urgency, actions) {
        for (var i = 0; i < notificationsModel.count; ++i) {
            if (notificationsModel.get(i).source == source) {
                notificationsModel.remove(i)
                break
            }
        }
        notificationsModel.insert(0,
               {"source"  : source,
                "appIcon" : appIcon,
                "appName" : appName,
                "summary" : summary,
                "body"    : body,
                "expireTimeout": expireTimeout,
                "urgency" : urgency,
                "actions" : actions});
        lastNotificationPopup.popup(appIcon, body)
    }

    function executeAction(source, id) {
        //try to use the service
        if (source.indexOf("notification") !== -1) {
            var service = notificationsSource.serviceForSource(source)
            var op = service.operationDescription("invokeAction")
            op["actionId"] = id

            service.startOperationCall(op)
        //try to open the id as url
        } else if (source.indexOf("Job") !== -1) {
            plasmoid.openUrl(id)
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
            var actions = new Array()
            if (notificationsSource.data[sourceName]["actions"].length%2 == 0) {
                for (var i = 0; i < notificationsSource.data[sourceName]["actions"].length; i += 2) {
                    var action = new Object()
                    action["id"] = notificationsSource.data[sourceName]["actions"][i]
                    action["text"] = notificationsSource.data[sourceName]["actions"][i+1]
                    actions.push(action)
                }
            }
            notificationsRoot.addNotification(
                    sourceName,
                    notificationsSource.data[sourceName]["appIcon"],
                    notificationsSource.data[sourceName]["appName"],
                    notificationsSource.data[sourceName]["summary"],
                    notificationsSource.data[sourceName]["body"],
                    notificationsSource.data[sourceName]["expireTimeout"],
                    notificationsSource.data[sourceName]["urgency"],
                    actions)
        }

        onDataChanged: {
            var i = connectedSources[connectedSources.length-1]
            lastNotificationPopup.popup(data[i]["appIcon"], String(data[i]["body"]).replace("\n", " "))
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
        delegate: NotificationDelegate {}
    }
}