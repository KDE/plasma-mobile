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

Item {
    id: root

    Layout.minimumHeight: notificationView.contentsHeight

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

            homescreen.addNotification(
                    sourceName,
                    data,
                    actions);
        }

    }

    ListModel {
        id: notificationsModel

        ListElement {
            appIcon: "call-start"
            summary: "Missed call from Joe"
            body: "Called at 8:42 from +41 56 373 37 31"
        }
        ListElement {
            appIcon: "im-google"
            summary: "July: Hey! Are you around?"
        }
        ListElement {
            appIcon: "im-google"
            summary: "July: Hello?"
        }
    }

    ListView {
        id: notificationView
        spacing: units.smallSpacing
        anchors.fill: parent
        interactive: false

        z: 1
        verticalLayoutDirection: ListView.BottomToTop
        model: notificationsModel

        add: Transition {
                NumberAnimation {
                    properties: "x"
                    from: notificationView.width
                    duration: 100
                }
            }

        remove: Transition {
            NumberAnimation {
                properties: "x"
                to: notificationView.width
                duration: 500
            }
            NumberAnimation {
                properties: "opacity"
                to: 0
                duration: 500
            }
        }

        removeDisplaced: Transition {
            SequentialAnimation {
                PauseAnimation { duration: 600 }
                NumberAnimation { properties: "x,y"; duration: 100 }
            }
        }

        delegate: NotificationStripe {}
    }
}
