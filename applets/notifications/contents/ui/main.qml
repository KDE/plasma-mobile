/*
 *   Copyright 2014 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2015 Marco Martin <notmart@gmail.com>
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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0

Item {
    id: root
    property int notificationId: 0

    Layout.minimumHeight: notificationView.contentHeight

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    function addNotification(source, data, actions) {
        // Do not show duplicated notifications
        // Remove notifications that are sent again (odd, but true)
        for (var i = 0; i < notificationsModel.count; ++i) {
            var tmp = notificationsModel.get(i);
            var matches = (tmp.appName == data.appName &&
                           tmp.summary == data.summary &&
                           tmp.body == data.body);
            var sameSource = tmp.source == source;

            if (sameSource && matches) {
                return;
            }

            if (sameSource || matches) {
                notificationsModel.remove(i)
                break;
            }
        }

        data["id"] = ++notificationId;
        data["source"] = source;
        if (data["summary"].length < 1) {
            data["summary"] = data["body"];
            data["body"] = '';
        }
        data["actions"] = actions;

        notificationsModel.insert(0, data);
        if (!data["isPersistent"]) {
            pendingRemovals.push(notificationId);
            pendingTimer.start();
        }
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
            Qt.openUrlExternally(id)
        }
    }

    PlasmaCore.DataSource {
        id: notificationsSource

        engine: "notifications"
        interval: 0

        onSourceAdded: {
            connectSource(source);
        }

        onSourceRemoved: {
            for (var i = 0; i < notificationsModel.count; ++i) {
                if (notificationsModel.get(i) == source) {
                    notificationsModel.remove(i);
                    break;
                }
            }
        }

        onNewData: {
            var actions = new Array()
            if (data["actions"] && data["actions"].length % 2 == 0) {
                for (var i = 0; i < data["actions"].length; i += 2) {
                    var action = new Object();
                    action["id"] = data["actions"][i];
                    action["text"] = data["actions"][i+1];
                    actions.push(action);
                }
            }

            root.addNotification(
                    sourceName,
                    data,
                    actions);
        }

    }

    PlasmaCore.FrameSvgItem {
        anchors.centerIn: parent
        visible: notificationsModel.count == 0
        imagePath: "widgets/background"
        width: childrenRect.width + margins.left + margins.right
        height: childrenRect.height + margins.top + margins.bottom
        PlasmaComponents.Label {
            anchors.centerIn: parent
            text: i18n("No recent notifications")
        }
    }

    ListModel {
        id: notificationsModel
    }

    ListView {
        id: notificationView
        spacing: units.smallSpacing
        anchors.fill: parent
        interactive: false
        cacheBuffer: 2000

        z: 1
        verticalLayoutDirection: ListView.BottomToTop
        model: notificationsModel

        add: Transition {
                NumberAnimation {
                    properties: "x"
                    from: notificationView.width
                    duration: units.shortDuration
                    easing.type: Easing.InOutQuad
                }
            }

        remove: Transition {
            NumberAnimation {
                properties: "x"
                to: notificationView.width
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                properties: "opacity"
                to: 0
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        removeDisplaced: Transition {
            SequentialAnimation {
                PauseAnimation {
                    duration: units.longDuration
                }
                NumberAnimation {
                    properties: "x,y"
                    duration: units.shortDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }

        delegate: NotificationStripe {}
    }
}
