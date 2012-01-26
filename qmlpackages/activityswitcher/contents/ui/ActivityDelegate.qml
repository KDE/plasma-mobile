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
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.qtextracomponents 0.1

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
    Component.onCompleted: {
        if (current == "true") {
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

        QImageItem {
            anchors {
                fill: parent
                leftMargin: parent.margins.left
                topMargin: parent.margins.top
                rightMargin: parent.margins.right
                bottomMargin: parent.margins.bottom
            }

            image: activityThumbnailsSource.data[model.DataEngineSource]["image"]

            Image {
                anchors.fill: parent

                source: switcherPackage.filePath("images", "emptyactivity.png")
                visible: !activityThumbnailsSource.data[model.DataEngineSource]["path"]
                onVisibleChanged: {
                    if (!visible) {
                        destroy()
                    }
                }
            }

            MobileComponents.TextEffects {
                id: activityName
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

        enabled: delegate.scale > 0.4
        Item {
            id: deleteButtonParent
            width: iconSize
            height: iconSize
            z: 900
            //TODO: load on demand of the qml file
            Component {
                id: confirmationDialogComponent
                ConfirmationDialog {
                    enabled: true
                    transformOrigin: Item.BottomLeft
                    question: i18n("Do you want to permanently delete activity '%1'?", activityName.text)
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
            }
            property ConfirmationDialog confirmationDialog
            MobileComponents.ActionButton {
                id: deleteButton
                svg: iconsSvg
                elementId: "delete"
                toggle: true
                opacity: model["Current"] == true ? 0.4 : 1
                enabled: opacity == 1
                z: 800
                property double oldOpacity: delegate.PathView.itemOpacity

                onClicked: {
                    // always recreate the dialog because on a second launch it moves upper a little bit.
                    if (deleteButtonParent.confirmationDialog) {
                        deleteButtonParent.confirmationDialog.scale = 0
                        deleteButtonParent.confirmationDialog.destroy()
                        deleteButtonParent.confirmationDialog = null
                    }

                    if (toggle) {
                        deleteButtonParent.confirmationDialog = confirmationDialogComponent.createObject(deleteButtonParent)
                        deleteButtonParent.confirmationDialog.scale = 1 / delegate.scale

                        // scale does not change dialog's width so we need to anchor the confirmationDialog's center manually.
                        deleteButtonParent.confirmationDialog.x = deleteButton.x + deleteButton.width / 2 - deleteButtonParent.confirmationDialog.width * (1 / delegate.scale) / 2

                        if (delegate.PathView.itemScale == 1) { // activity at PathView's center, not necessary the current activity.
                            deleteButtonParent.confirmationDialog.anchors.bottom = deleteButton.top
                        } else {
                            deleteButtonParent.confirmationDialog.y = deleteButton.y - deleteButton.height / (3/2) * (1 / delegate.scale)
                        }
                    }
                }

                onCheckedChanged: {
                    // makes dialog and activity thumbnail fully opaque only when dialog is opened.
                    if (checked) {
                        oldOpacity = delegate.PathView.itemOpacity
                        delegate.PathView.itemOpacity = 1
                    } else {
                        delegate.PathView.itemOpacity = oldOpacity
                    }
                }
            }
        }
    }
}
