/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
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
import org.kde.metadatamodels 0.1 as MetadataModels
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.draganddrop 1.0


PlasmaComponents.Page {
    id: root
    anchors.fill: parent
    clip: false

    property Item currentItem

    PlasmaExtras.Heading {
        anchors {
            top: parent.top
            right: parent.right
            rightMargin: theme.defaultFont.mSize.width
        }
        text: i18n("Tags")
    }

    PlasmaExtras.ScrollArea {
        anchors.fill: parent
        clip: false
        Component.onCompleted: mainFlickable.clip = false

        Flickable {
            id: mainFlickable
            contentWidth: width
            contentHeight: mainColumn.height
            clip: false

            anchors.fill: parent

            Column {
                id: mainColumn
                spacing: 8
                width: parent.width
                Item {
                    height: theme.defaultFont.mSize.height
                    width: height
                }

                Row {
                    spacing: 8
                    MouseArea {
                        width: theme.defaultFont.mSize.width * 10
                        height: width

                        DropArea {
                            anchors.fill: parent
                            property bool underDrag: false
                            onDragEnter: underDrag = true
                            onDragLeave: underDrag = false
                            onDrop: {
                                underDrag = false
                                newTagDialog.resourceUrls = event.mimeData.urls
                                newTagDialog.open()
                            }

                            Item {
                                anchors.fill: parent
                                Rectangle {
                                    id: newDragBackground
                                    color: theme.textColor
                                    anchors.fill: parent

                                    radius: width/2
                                    opacity: parent.parent.underDrag ? 0.6 : 0.2
                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 250
                                            easing.type: Easing.InOutQuad
                                        }
                                    }
                                }
                                Rectangle {
                                    anchors {
                                        fill: newDragBackground
                                        topMargin: 2
                                        bottomMargin: -2
                                    }
                                    radius: width/2
                                    color: "white"
                                    opacity: 0.6
                                }
                                Rectangle {
                                    color: theme.textColor
                                    anchors {
                                        fill: parent
                                        margins: 20
                                    }
                                    radius: width/2
                                    opacity: 0.6
                                }
                                Rectangle {
                                    color: theme.backgroundColor
                                    anchors.centerIn:parent
                                    width: 4
                                    height: parent.height/3
                                }
                                Rectangle {
                                    color: theme.backgroundColor
                                    anchors.centerIn:parent
                                    height: 4
                                    width: parent.height/3
                                }
                            }
                        }
                    }
                    PlasmaComponents.Label {
                        id: tagLabel
                        text: i18n("New Tag")
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Repeater {
                    id: tagRepeater
                    model: PlasmaCore.SortFilterModel {
                        id: sortFilterModel
                        sourceModel: MetadataModels.MetadataModel {
                            id: tagCloud
                            queryProvider: MetadataModels.CloudQueryProvider {
                                cloudCategory: "nao:hasTag"
                                resourceType: metadataModel.queryProvider.resourceType
                                minimumRating: metadataModel.queryProvider.minimumRating
                            }
                        }
                        sortRole: "label"
                    }

                    delegate: MouseArea {
                        id: tagDelegate

                        x: -mainFlickable.width

                        width: mainFlickable.width * 3
                        height: theme.defaultFont.mSize.width * 10
                        property bool checked: false

                        onReleased: {
                            if (tagDelegate.x > -mainFlickable.width/2) {
                                slideAnim.to = 0
                            } else if (tagDelegate.x < -mainFlickable.width - mainFlickable.width/2) {
                                slideAnim.to = -mainFlickable.width * 2
                            } else {
                                slideAnim.to = -mainFlickable.width
                            }
                            slideAnim.running = true
                        }
                        onClicked: checked = !checked
                        onCheckedChanged: {
                            var tags = metadataModel.queryProvider.tags
                            if (checked) {
                                tags[tags.length] = model["label"];
                                metadataModel.queryProvider.tags = tags
                            } else {
                                for (var i = 0; i < tags.length; ++i) {
                                    if (tags[i] == model["label"]) {
                                        tags.splice(i, 1);
                                        metadataModel.queryProvider.tags = tags
                                        break;
                                    }
                                }
                            }
                        }

                        drag {
                            target: tagDelegate
                            axis: Drag.XAxis
                            minimumX: -mainFlickable.width * 2
                            maximumX: 0
                        }

                        PlasmaExtras.ConditionalLoader {
                            width: mainFlickable.width
                            height: childrenRect.height
                            anchors.verticalCenter: parent
                            x: tagDelegate.x > -mainFlickable.width ? 0 : mainFlickable.width * 2
                            when: true//tagDelegate.x != -mainFlickable.width

                            source: Component {
                                Column {
                                    PlasmaComponents.Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: i18n("Delete tag \"%1\"?", model.label)
                                    }
                                    Row {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 8
                                        PlasmaComponents.Button {
                                            text: i18n("Delete")
                                        }
                                        PlasmaComponents.Button {
                                            text: i18n("Cancel")
                                        }
                                    }
                                }
                            }
                        }
                        NumberAnimation {
                            id: slideAnim
                            target: tagDelegate
                            property: "x"
                            to: -mainFlickable.width
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }

                        DropArea {
                            anchors {
                                fill: parent
                                leftMargin: mainFlickable.width
                                rightMargin: mainFlickable.width
                            }
                            property bool underDrag: false
                            onDragEnter: underDrag = true
                            onDragLeave: underDrag = false
                            onDrop: {
                                underDrag = false
                                var service = metadataSource.serviceForSource("")
                                print(service);
                                var operation = service.operationDescription("tagResources")
                                operation["ResourceUrls"] = event.mimeData.urls
                                operation["Tag"] = model["label"]
                                service.startOperationCall(operation)
                            }
                            Row {
                                spacing: 8

                                Item {
                                    width: height
                                    height: tagDelegate.height
                                    Rectangle {
                                        id: background
                                        color: theme.textColor
                                        anchors.fill: parent
                                        radius: width/2
                                        opacity: parent.underDrag ? 0.6 : 0.2
                                        Behavior on opacity {
                                            NumberAnimation {
                                                duration: 250
                                                easing.type: Easing.InOutQuad
                                            }
                                        }
                                    }

                                    Rectangle {
                                        anchors {
                                            fill: background
                                            topMargin: 2
                                            bottomMargin: -2
                                        }
                                        radius: width/2
                                        color: "white"
                                        opacity: 0.6
                                    }
                                    Rectangle {
                                        color: tagDelegate.checked ? theme.highlightColor : theme.textColor
                                        radius: width/2
                                        anchors.centerIn: parent
                                        width: Math.min(parent.width, 14 + 100 * (model.count / tagCloud.totalCount))
                                        height: width
                                    }
                                }

                                PlasmaComponents.Label {
                                    id: tagLabel
                                    text: model.label
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    DropArea {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: 20
        onDragEnter: {
            scrollTimer.down = false
            scrollTimer.running = true
        }
        onDragLeave: scrollTimer.running = false
        onDrop: scrollTimer.running = false
    }
    DropArea {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 20
        onDragEnter: {
            scrollTimer.down = true
            scrollTimer.running = true
        }
        onDragLeave: scrollTimer.running = false
        onDrop: scrollTimer.running = false
    }
    Timer {
        id: scrollTimer
        property bool down: true
        interval: 25
        repeat: true
        onTriggered: {
            if (down) {
                if (!mainFlickable.atYEnd) {
                    mainFlickable.contentY += 10
                }
            } else {
                if (!mainFlickable.atYBeginning) {
                    mainFlickable.contentY -= 10
                }
            }
        }
    }
    PlasmaComponents.CommonDialog {
        id: newTagDialog

        property variant resourceUrls

        titleText: i18n("New tag name")
        buttonTexts: [i18n("Ok"), i18n("Cancel")]
        content: Item {
            width: childrenRect.width + theme.defaultFont.mSize.width * 4
            height: childrenRect.height + theme.defaultFont.mSize.height * 2
            anchors.centerIn: parent
            PlasmaComponents.TextField {
                id: tagField
                anchors.centerIn: parent
                width: theme.defaultFont.mSize.width * 30
                Keys.onEnterPressed: newTagDialog.accept()
                Keys.onReturnPressed: newTagDialog.accept()
            }
        }
        onAccepted: {
            if (!tagField.text) {
                return
            }
            var service = metadataSource.serviceForSource("")
            var operation = service.operationDescription("tagResources")
            operation["ResourceUrls"] = resourceUrls
            operation["Tag"] = tagField.text
            service.startOperationCall(operation)
        }
        onButtonClicked: {
            if (index == 0) {
                accept()
            } else {
                reject()
            }

            tagField.text = ''
        }
        onStatusChanged: {
            if (status == PlasmaComponents.DialogStatus.Open) {
                tagField.forceActiveFocus()
            } else if (status == PlasmaComponents.DialogStatus.Closed) {
                tagField.closeSoftwareInputPanel()
            }
        }
    }
}
