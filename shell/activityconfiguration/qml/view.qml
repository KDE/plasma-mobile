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

    MouseArea {
        anchors.fill: parent
        onClicked: disappearAnimation.running=true
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
        interval: 250
        onTriggered: {
            print(configInterface.wallpaperModel)
            wallpapersList.model = configInterface.wallpaperModel
            activityNameEdit.text = configInterface.activityName
        }
    }

    PlasmaCore.Theme {
        id: theme
    }

    PlasmaCore.FrameSvgItem {
        id: frame
        anchors.centerIn: parent
        //FIXME: why +40?
        width: Math.min(wallpapersList.height*1.6*3+40, parent.width/1.05)
        height: parent.height/2
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
            Text {
                color: theme.textColor
                text: i18n("Activity:")
                anchors.verticalCenter: activityNameEdit.verticalCenter
            }
            PlasmaWidgets.LineEdit {
                id: activityNameEdit
            }
        }

        ListView {
            id: wallpapersList
            spacing: 4
            anchors {
                top: nameRow.bottom
                left: parent.left
                bottom: closeButton.top
                right: parent.right
                leftMargin: frame.margins.left
                topMargin: 12
                rightMargin: frame.margins.right
                bottomMargin: 12
            }
            clip: true
            snapMode: ListView.SnapOneItem
            orientation: ListView.Horizontal
            model: configInterface.wallpaperModel
            delegate: Rectangle {
                radius: 4
                width: wallpapersList.height*1.6
                height: wallpapersList.height-4

                QPixmapItem {
                    pixmap: screenshot
                    anchors {
                        fill: parent
                        margins: 6
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Qt.rgba(1,1,1,0.6)
                        radius: 4
                        width: wallpaperName.paintedWidth
                        height: wallpaperName.paintedHeight
                        Text {
                            id: wallpaperName
                            text: display
                        }
                    }
                    Rectangle {
                        opacity:wallpapersList.currentIndex == index?1:0
                        width:10
                        height:10
                        radius:5
                        anchors.top:parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: wallpapersList.currentIndex = index
                }
            }
        }

        PlasmaWidgets.PushButton {
            id: closeButton
            anchors {
                bottom: parent.bottom
                right: parent.right
                rightMargin: frame.margins.right
                bottomMargin: frame.margins.bottom
            }

            text: i18n("Cancel")
            onClicked : disappearAnimation.running = true
        }

        PlasmaWidgets.PushButton {
            id: okButton
            anchors {
                bottom: parent.bottom
                left: parent.left
                leftMargin: frame.margins.left
                bottomMargin: frame.margins.bottom
            }

            text: i18n("Ok")
            onClicked : {
                configInterface.activityName = activityNameEdit.text
                configInterface.wallpaperIndex = wallpapersList.currentIndex
                disappearAnimation.running = true
            }
        }
    }
}
