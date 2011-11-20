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

    title: i18n("Activity configuration")
    acceptButtonText: (configInterface.activityName == "") ? i18n("Create activity") : i18n("Save changes")
    rejectButtonText: i18n("Cancel")

    Component.onCompleted: open()
    onStatusChanged: {
        if (status == PlasmaComponents.DialogStatus.Closed) {
            closeRequested()
        }
    }

    function saveConfiguration()
    {
        configInterface.activityName = activityNameEdit.text
        configInterface.wallpaperIndex = wallpapersList.currentIndex
    }

    onAccepted: {
        saveConfiguration()
    }

    content: [
        Row {
            id: nameRow
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.topMargin
            }
            visible: configInterface.activityNameConfigurable
            Text {
                color: theme.textColor
                text: i18n("Activity name:")
                anchors.verticalCenter: activityNameEdit.verticalCenter
            }
            PlasmaComponents.TextField {
                id: activityNameEdit
                objectName: "activityNameEdit"
                Component.onCompleted: activityNameEdit.forceActiveFocus()
                Keys.onReturnPressed: saveConfiguration();
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
                leftMargin: frame.margins.left
                topMargin: 6
                rightMargin: frame.margins.right
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
        }

        onWallpaperIndexChanged: {
            if (configInterface.activityName == "" || configInterface.wallpaperIndex < 0) {
                var newIndex = Math.random()*wallpapersList.count
                wallpapersList.positionViewAtIndex(newIndex)
                wallpapersList.currentIndex = newIndex
            } else {
                wallpapersList.positionViewAtIndex(configInterface.wallpaperIndex)
                wallpapersList.currentIndex = configInterface.wallpaperIndex
            }
        }

        onActivityNameChanged: {
            if (configInterface.activityName == "") {
                activityNameEdit.text = i18n("New Activity")
            } else {
                activityNameEdit.text = configInterface.activityName
            }
        }
    }

}
