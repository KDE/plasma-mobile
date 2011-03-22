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
        origin.x: 0
        origin.y: delegate.height
        angle: -PathView.itemRotation
    }

    width: mainView.delegateWidth
    height: mainView.delegateHeight

    Rectangle {
        anchors.fill:parent
        anchors.leftMargin: 60

        Image {
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.topMargin: 5
            anchors.rightMargin: 5
            anchors.bottomMargin: 5
            source: "images/"+model.image
            Text{
                color: "white"
                text: model.Name
                font.pixelSize: 20
            }
        }
    }
    Item {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        width: 240
        height: 32
        Image {
            id: holeImage
            y: 4
            source: plasmoid.file("images", "sliderhole.png")
            anchors.right: parent.right
            Text {
                anchors.centerIn: parent
                text: "Slide to activate"
            }
        }
        Image {
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
                drag.minimumX: 0
                drag.maximumX: holeImage.x - 4
                onReleased: {
                    parent.x = 0

                    var activityId = model["DataEngineSource"]
                    print(activityId)
                    var service = activitySource.serviceForSource(activityId)
                    var operation = service.operationDescription("setCurrent")
                    service.startOperationCall(operation)
                }
            }
        }
    }
}
