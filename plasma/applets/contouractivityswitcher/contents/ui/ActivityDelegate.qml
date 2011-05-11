/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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


Item {
    id: delegate
    scale: PathView.itemScale
    opacity: PathView.itemOpacity
    z: PathView.z
    property string current: model["Current"]
    onCurrentChanged: {
        if (current == "true") {
            highlightTimer.pendingIndex = index
            highlightTimer.running = true
        }
    }

    transform: Rotation {
        origin.x: delegate.width
        origin.y: delegate.height
        angle: PathView.itemRotation
    }

    width: mainView.delegateWidth
    height: mainView.delegateHeight

    Rectangle {
        anchors.fill:parent
        anchors.rightMargin: 100
        radius: 4

        Image {
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.topMargin: 5
            anchors.rightMargin: 5
            anchors.bottomMargin: 5
            property string path: activityThumbnailsSource.data[model.DataEngineSource]["path"]
            source: path?path:plasmoid.file("images", "emptyactivity.png")
            Rectangle {
                color: "white"
                x: 10
                y: 25
                radius: 10
                width: childrenRect.width
                height: childrenRect.height
                Text{
                    color: "black"
                    text: model.Name
                    font.pixelSize: 20
                }
            }
        }
    }
    Item {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        anchors.right: parent.right
        width: 240
        height: 32
        opacity: delegate.scale>0.95?1:0
        Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        Image {
            id: holeImage
            y: 4
            source: plasmoid.file("images", "sliderhole.png")
            anchors.left: parent.left
            Text {
                anchors.centerIn: parent
                text: "Slide to activate"
            }
        }
        Image {
            x: parent.width - width
            source: plasmoid.file("images", "slider.png")
            Text {
                anchors.centerIn: parent
                text: model.Name
                font.pixelSize: 14
            }
            Behavior on x {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
            MouseArea {
                anchors.fill: parent
                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: holeImage.x - 4
                drag.maximumX: parent.parent.width - width
                onReleased: {
                    if (parent.x <= 32) {
                        var activityId = model["DataEngineSource"]
                        print(activityId)
                        var service = activitySource.serviceForSource(activityId)
                        var operation = service.operationDescription("setCurrent")
                        service.startOperationCall(operation)
                    }
                    parent.x = parent.parent.width - parent.width
                }
            }
        }
    }
}
