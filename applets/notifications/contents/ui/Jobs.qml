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
    id: jobsRoot
    property alias count: jobsRepeater.count

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
            notifications.addNotification(
                source,
                runningJobs[source]["appIconName"],
                0,
                runningJobs[source]["appName"],
                i18n("%1 [Finished]", runningJobs[source]["infoMessage"]),
                message,
                0,
                0,
                [{"id": message, "text": i18n("Open")}])
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
                if (jobsSource.data[sources[i]]["percentage"]) {
                    total += jobsSource.data[sources[i]]["percentage"]
                }
            }

            total /= sources.length
            notificationsApplet.globalProgress = total/100
        }
    }

    Title {
        visible: jobsRepeater.count > 0
        text: i18n("Transfers")
    }
    PlasmaComponents.ListItem {
        visible: jobsRepeater.count > 1
        PlasmaComponents.ProgressBar {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                right: parent.right
            }
            minimumValue: 0
            maximumValue: 100
            value: notificationsApplet.globalProgress * 100
        }
    }
    Repeater {
        id: jobsRepeater
        model: jobsSource.sources
        delegate: JobDelegate {}
    }
}