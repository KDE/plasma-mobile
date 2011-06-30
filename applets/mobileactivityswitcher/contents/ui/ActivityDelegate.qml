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
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

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

    width: mainView.delegateWidth
    height: mainView.delegateHeight

    PlasmaCore.FrameSvgItem {
        id: activityBorder
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
            property string path: activityThumbnailsSource.data[model.DataEngineSource]?activityThumbnailsSource.data[model.DataEngineSource]["path"]:""
            source: path?path:plasmoid.file("images", "emptyactivity.png")
            Text {
                anchors.top: parent.top
                anchors.left: parent.left
               // anchors.leftMargin: 22
                text: model.Name
                font.bold: true
                style: Text.Outline
                styleColor: Qt.rgba(1, 1, 1, 0.6)
                font.pixelSize: 25
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
        opacity: delegate.scale>0.9?1:(model["Current"]==true?1:0)
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
                text: model["Current"]==true?i18n("Active"):i18n("Slide to activate")
            }
        }
        Image {
            x: parent.width - width
            source: plasmoid.file("images", "slider.png")
            opacity: model["Current"]==true?0:1
            Text {
                anchors.centerIn: parent
                text: i18n("Activate")
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
    
    
    Row {
        anchors {
            bottom: activityBorder.bottom
            left: activityBorder.left
            bottomMargin: activityBorder.margins.bottom
            leftMargin: activityBorder.margins.left
        }
        spacing: 8
        opacity: delegate.scale>0.9?1:0
        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
        Item {
            width: iconSize
            height: iconSize
            z: 900
            //TODO: load on demand of the qml file
            ConfirmationDialog {
                id: confirmationDialog
                anchors {
                    left: deleteButton.horizontalCenter
                    bottom: deleteButton.verticalCenter
                }
                transformOrigin: Item.BottomLeft
                question: i18n("Are you sure you want permanently delete this activity?")
                onAccepted: {
                    var service = activitySource.serviceForSource("Status")
                    var operation = service.operationDescription("remove")
                    operation["Id"] = model["DataEngineSource"]
                    var job = service.startOperationCall(operation)
                }
                onDismissed: {
                    deleteButton.checked = false
                }
            }
            MobileComponents.ActionButton {
                id: deleteButton
                svg: iconsSvg
                elementId: "delete"
                toggle: true
                opacity: model["Current"]==true?0.3:1
                enabled: opacity==1

                onClicked: {
                    if (confirmationDialog.scale == 1) {
                        confirmationDialog.scale = 0
                    } else {
                        confirmationDialog.scale = 1
                    }
                }
            }
        }
    }
}
