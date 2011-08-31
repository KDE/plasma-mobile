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
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Rectangle {
    id: main
    signal closeRequested
    property variant containmentConfig
    color: Qt.rgba(0,0,0,0.5)
    width: 800
    height: 480
    opacity: 0

    PlasmaCore.DataSource {
        id: activitySource
        engine: "org.kde.activities"
        connectedSources: ["Status"]
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            disappearAnimation.running=true
        }
    }

    Component.onCompleted: {
        appearAnimation.running = true
    }

    ParallelAnimation {
        id: appearAnimation
        NumberAnimation {
            targets: main
            properties: "opacity"
            duration: 250
            to: 1
            easing.type: "InOutCubic"
        }
        NumberAnimation {
            targets: frame
            properties: "scale"
            duration: 250
            to: 1
            easing.type: "InOutCubic"
        }
    }

    SequentialAnimation {
        id: disappearAnimation
        ParallelAnimation {
            NumberAnimation {
                targets: main
                properties: "opacity"
                duration: 250
                to: 0
                easing.type: "InOutCubic"
            }
            NumberAnimation {
                targets: frame
                properties: "scale"
                duration: 250
                to: 0
                easing.type: "InOutCubic"
            }
        }
        ScriptAction {
            script: main.closeRequested()
        }
    }

    //FIXME: artificial delay to have configInterface working
    Timer {
        repeat: false
        running: true
        interval: 350
        onTriggered: {
            wallpapersList.model = configInterface.wallpaperModel
            if (configInterface.activityName == "") {
                activityNameEdit.text = i18n("New Activity")
            } else {
                activityNameEdit.text = configInterface.activityName
            }

            if (configInterface.activityName == "") {
                var newIndex = Math.random()*wallpapersList.count
                wallpapersList.positionViewAtIndex(newIndex, ListView.Center)
                wallpapersList.currentIndex = newIndex
            } else {
                wallpapersList.positionViewAtIndex(configInterface.wallpaperIndex, ListView.Center)
                wallpapersList.currentIndex = configInterface.wallpaperInde
            }
        }
    }

    PlasmaCore.Theme {
        id: theme
    }

    PlasmaCore.FrameSvgItem {
        id: frame
        anchors.centerIn: parent
        //FIXME: why +20?
        width: parent.width-100
        height: parent.height/1.4
        imagePath: "dialogs/background"
        scale: 0

        MouseArea {
            anchors.fill: parent
            onPressed: mouse.accepted = true
        }

        Row {
            id: nameRow
            anchors.horizontalCenter: parent.horizontalCenter
            y: frame.margins.top
            visible: configInterface.activityNameConfigurable
            Text {
                color: theme.textColor
                text: i18n("Activity name:")
                anchors.verticalCenter: activityNameEdit.verticalCenter
            }
            PlasmaWidgets.LineEdit {
                id: activityNameEdit
                objectName: "activityNameEdit"
            }
        }

        MobileComponents.IconGrid {
            id: wallpapersList
            property int currentIndex: 0
            onCurrentIndexChanged: {
                currentPage = Math.max(0, Math.floor(currentIndex/pageSize))
            }

            property int delegateWidth: 148
            property int delegateHeight: delegateWidth/1.6
            anchors {
                top: nameRow.bottom
                left: parent.left
                bottom: buttonsRow.top
                right: parent.right
                leftMargin: frame.margins.left
                topMargin: 6
                rightMargin: frame.margins.right
                bottomMargin: 12
            }
            model: configInterface.wallpaperModel
            delegate: WallpaperDelegate {}
        }

        Row {
            id: buttonsRow
            spacing: 8
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: frame.margins.bottom
            }

            PlasmaWidgets.PushButton {
                id: okButton

                text: configInterface.activityName == ""?i18n("Create activity"):i18n("Save changes")
                onClicked : {
                    configInterface.activityName = activityNameEdit.text
                    configInterface.wallpaperIndex = wallpapersList.currentIndex
                    disappearAnimation.running = true
                }
            }

            PlasmaWidgets.PushButton {
                id: closeButton

                text: i18n("Cancel")

                onClicked: {
                    disappearAnimation.running = true
                }
            }
        }
    }
}
