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

import QtQuick 1.1
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

PlasmaComponents.Sheet {
    id: main
    signal closeRequested

    title: (configInterface.activityName == "") ? i18n("Create New Activity") : i18n("Edit Activity")
    acceptButtonText: (configInterface.activityName == "") ? i18n("Create activity") : i18n("Save Changes")

    rejectButtonText: i18n("Cancel")
    acceptButton.enabled: activityNameEdit.text != "" && !nameExists()

    Timer {
        running: true
        interval: 100
        onTriggered: open()
    }

    //used only toexplicitly close the keyboard
    TextInput { id: inputPanelController; width:0; height:0}
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
        //console.log("Creating activity " + activityNameEdit.text)
        configInterface.activityName = activityNameEdit.text
        configInterface.wallpaperIndex = wallpapersList.currentIndex
        configInterface.encrypted = encryptedSwitch.checked
    }

    // Virtual keyboard can emit the accepted signal several times.
    // For example, try pressing the RETURN key several times as fast as you can when creating one activity.
    Item {
        id: privateItem
        property bool creatingActivity: false
    }

    onAccepted: {
        if (privateItem.creatingActivity) {
            //console.log("Already creating activity")
            return;
        }
        privateItem.creatingActivity = true
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
        Row {
            id: nameRow
            spacing: 2
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.topMargin
            }
            visible: configInterface.activityNameConfigurable
            property int sideWidth: Math.max(activityNameLabel.paintedWidth, encryptRow.implicitWidth)
            PlasmaComponents.Label {
                id: activityNameLabel
                width: nameRow.sideWidth
                text: i18n("Activity name:")
                horizontalAlignment: Text.AlignRight
                anchors.verticalCenter: parent.verticalCenter
            }
            PlasmaComponents.TextField {
                id: activityNameEdit
                objectName: "activityNameEdit"
                placeholderText: i18n("Name")
                Component.onCompleted: activityNameEdit.forceActiveFocus()
                anchors.verticalCenter: parent.verticalCenter
                Keys.onReturnPressed: {
                    accept()
                }
            }
            Row {
                id: encryptRow
                width: nameRow.sideWidth
                spacing: 2
                visible: true

                //spacer
                Item {
                    width: 4
                    height: 4
                }
                PlasmaComponents.ToolButton {
                    iconSource: "document-decrypt"
                    width: theme.mediumIconSize+5
                    height: width
                    onClicked: encryptedSwitch.checked = false
                }
                PlasmaComponents.Switch {
                    id: encryptedSwitch
                    checked: configInterface.encrypted
                    anchors.verticalCenter: parent.verticalCenter
                }
                PlasmaComponents.ToolButton {
                    iconSource: "document-encrypt"
                    width: theme.mediumIconSize+5
                    height: width
                    onClicked: encryptedSwitch.checked = true
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
                bottom: parent.bottom
                right: parent.right
                topMargin: 6
                bottomMargin: 12
            }
            model: configInterface.wallpaperModel
            delegate: WallpaperDelegate {}
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
            privateItem.creatingActivity = false
        }
    }
    Timer {
        running: true
        interval: 200
        onTriggered: syncWallpaperIndex()
    }

}
