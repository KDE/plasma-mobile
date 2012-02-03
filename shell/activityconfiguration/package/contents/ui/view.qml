/*
 *   Copyright 2010 Marco Martin <notmart@gmail.com>
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

import Qt 4.7
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

MobileComponents.Sheet {
    id: main
    signal closeRequested

    title: (configInterface.activityName == "") ? i18n("Create new activity") : i18n("Activity configuration")
    acceptButtonText: {
        if (!encryptedSwitch.checked || encryptedSwitch.checked == internal.activityEncrypted) {
            (configInterface.activityName == "") ? i18n("Create activity") : i18n("Save changes")
        } else {
            i18n("Enter password")
        }
    }
    rejectButtonText: i18n("Close")
    acceptButton.enabled: activityNameEdit.text != "" && !nameExists()

    Component.onCompleted: open()

    QtObject {
        id: internal
        property bool activityEncrypted
    }

    onStatusChanged: {
        if (status == PlasmaComponents.DialogStatus.Closed) {
            closeRequested()
        }
    }

    function saveConfiguration()
    {
        if (activityNameEdit.text == "" || nameExists()) {
            return
        }
        configInterface.activityName = activityNameEdit.text
        configInterface.wallpaperIndex = wallpapersList.currentIndex

        var service = activitySource.serviceForSource(configInterface.activityId)
        var operation = service.operationDescription("setEncrypted")
        operation["Encrypted"] = encryptedSwitch.checked
        service.startOperationCall(operation)
    }

    onAccepted: {
        saveConfiguration()
    }

    //this is used to check the same name isn't given two times
    PlasmaCore.DataSource {
        id: activitySource
        property variant activityNames
        property string currentActivity
        engine: "org.kde.activities"
        onSourceAdded: {
            if (source != "Status") {
                connectSource(source)
            }
        }
        Component.onCompleted: {
            connectedSources = sources.filter(function(val) {
                return val != "Status";
            })
        }
        onDataChanged: {
            var names = new Array
            for (var i in data) {
                if (data[i]["Current"]) {
                    currentActivity = data[i]["Name"]
                    encryptedSwitch.checked = activitySource.data[i]["Encrypted"]
                    internal.activityEncrypted = activitySource.data[i]["Encrypted"]
                }
                names.push(data[i]["Name"])
            }
            activitySource.activityNames = names
        }
    }

    function nameExists()
    {
        /*empty configInterface activityname we are creating*/
        if (configInterface.activityName != "" && (activitySource.currentActivity == activityNameEdit.text)) {
            return false
        }

        return activitySource.activityNames.indexOf(activityNameEdit.text) != -1

    }

    function syncWallpaperIndex()
    {
        if (configInterface.activityName == "" || configInterface.wallpaperIndex < 0) {
            var newIndex = Math.random()*wallpapersList.count
            wallpapersList.positionViewAtIndex(newIndex)
            wallpapersList.currentIndex = newIndex
        } else {
            wallpapersList.positionViewAtIndex(configInterface.wallpaperIndex)
            wallpapersList.currentIndex = configInterface.wallpaperIndex
        }
    }

    content: [
        Grid {
            id: nameRow
            columns: 2
            rows: 2
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.topMargin
            }
            visible: configInterface.activityNameConfigurable
            PlasmaComponents.Label {
                color: theme.textColor
                text: i18n("Activity name:")
                anchors.verticalCenter: activityNameEdit.verticalCenter
                anchors.right: activityNameEdit.left
            }
            PlasmaComponents.TextField {
                id: activityNameEdit
                objectName: "activityNameEdit"
                Component.onCompleted: activityNameEdit.forceActiveFocus()
                Keys.onReturnPressed: {
                    saveConfiguration()
                    accept()
                }
            }
        },
        PlasmaComponents.Label {
            anchors {
                left: nameRow.right
                verticalCenter: nameRow.verticalCenter
            }
            text: i18n("An activity with this name already exists")
            opacity: nameExists() ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        },
        MobileComponents.IconGrid {
            id: wallpapersList
            property int currentIndex: 0
            onCurrentIndexChanged: {
                currentPage = Math.max(0, Math.floor(currentIndex/pageSize))
            }

            property int delegateWidth: 148
            property int delegateHeight: 130
            anchors {
                top: nameRow.bottom
                left: parent.left
                bottom: encryptRow.top
                right: parent.right
                topMargin: 6
                bottomMargin: 12
            }
            model: configInterface.wallpaperModel
            delegate: WallpaperDelegate {}
        },
        Row {
            id: encryptRow
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }

            PlasmaComponents.Label {
                id: encryptLabel
                color: theme.textColor
                text: i18n("Lock as private:")
                anchors.right: encryptedSwitch.left
            }
            PlasmaComponents.Switch {
                id: encryptedSwitch
            }
        }
    ]

    Connections {
        target: configInterface
        onModelChanged: {
            wallpapersList.model =  configInterface.wallpaperModel
            syncWallpaperIndex()
        }

        onWallpaperIndexChanged: syncWallpaperIndex()

        onActivityNameChanged: {
            if (configInterface.activityName == "") {
                activityNameEdit.text = i18n("New Activity")
            } else {
                activityNameEdit.text = configInterface.activityName
            }
        }
    }
    Timer {
        running: true
        interval: 200
        onTriggered: syncWallpaperIndex()
    }

}
