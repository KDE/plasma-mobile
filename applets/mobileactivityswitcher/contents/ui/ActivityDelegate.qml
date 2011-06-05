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
import org.kde.plasma.core 0.1 as PlasmaCore

Item {
    id: delegate
    scale: PathView.itemScale
    opacity: PathView.itemOpacity
    z: PathView.z
    property string current: model["Current"]

    onCurrentChanged: {
        //avoid to restart the timer if the current index is already correct
        if (current == "true" && highlightTimer.pendingIndex != index) {
            highlightTimer.pendingIndex = index
            highlightTimer.running = true
        }
    }
    property int iconSize: 48

    PlasmaCore.Svg {
        id: iconsSvg
        imagePath: "widgets/configuration-icons"
    }

    width: mainView.delegateWidth
    height: mainView.delegateHeight

    PlasmaCore.FrameSvgItem {
        imagePath: "widgets/media-delegate"
        prefix: "picture"

        anchors.fill:parent
        anchors.rightMargin: 100

        Image {
            anchors {
                fill: parent
                leftMargin: parent.margins.left
                topMargin: parent.margins.top
                rightMargin: parent.margins.right
                bottomMargin: parent.margins.bottom
            }
            property string path: activityThumbnailsSource.data[model.DataEngineSource]["path"]
            source: path?path:plasmoid.file("images", "emptyactivity.png")
            Rectangle {
                color: "white"
                x: 10
                y: 10
                radius: 10
                width: childrenRect.width+10
                height: childrenRect.height
                Text{
                    anchors.centerIn: parent
                    color: "black"
                    text: model.Name
                    font.pixelSize: 20
                }
            }
            ActionButton {
                elementId: "configure"
                action: plasmoid.action("configure")
                opacity: model["Current"]==true?1:0
                anchors.bottom: parent.bottom
            }
        }
    }
    Item {
        anchors {
            bottom: parent.bottom
            bottomMargin: 40
            right: parent.right
            rightMargin: 10
        }
        width: 240
        height: 32
        opacity: delegate.scale>0.9?1:0
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
            x: model["Current"]==true?-4:parent.width - width
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
                enabled: model["Current"]==true?false:true
                onPressed: {
                    mainView.interactive = false
                    mouse.accepted = true
                }
                onReleased: {
                    mainView.interactive = true
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
