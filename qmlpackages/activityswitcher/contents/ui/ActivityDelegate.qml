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

    transform: Translate {
        x: delegate.PathView.itemXTranslate
        y: delegate.PathView.itemYTranslate
    }


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
            property string path: activityThumbnailsSource.data[model.DataEngineSource] ? activityThumbnailsSource.data[model.DataEngineSource]["path"] : ""
            source: path ? path : switcherPackage.filePath("images", "emptyactivity.png")

            MobileComponents.TextEffects {
                anchors {
                    top: parent.top
                    left: parent.left
                    leftMargin: 10
                    topMargin: 10
                }

                text: (String(model.Name).length <= 18) ? model.Name:String(model.Name).substr(0,18) + "..."
                color: "white"
                horizontalOffset: 1
                verticalOffset: 1
                pixelSize: 25
                bold: true
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            var activityId = model["DataEngineSource"]
            print(activityId)
            var service = activitySource.serviceForSource(activityId)
            var operation = service.operationDescription("setCurrent")
            service.startOperationCall(operation)
        }
    }

    Row {
        anchors {
            bottom: activityBorder.bottom
            left: activityBorder.left
            bottomMargin: activityBorder.margins.bottom + 13
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
                    var service = activitySource.serviceForSource(model["DataEngineSource"])
                    var operation = service.operationDescription("stop")
                    service.startOperationCall(operation)

                    deleteTimer.activityId = model["DataEngineSource"]
                    deleteTimer.running = true
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
                opacity: model["Current"]==true?0.4:1
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
