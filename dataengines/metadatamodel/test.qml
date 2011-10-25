/*
    Copyright 2011 Marco Martin <notmart@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

import QtQuick 1.1
import org.kde.plasma.components 0.1
import org.kde.datamodels 0.1

Item {
    width: 800
    height: 480

    ToolBar {
        id: toolBar
        anchors {
            left: parent.left
            right: parent.right
        }
        tools: Row {
            spacing: 10
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: "Type"
            }
            ButtonRow {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                RadioButton {
                    text: "Documents"
                    onCheckedChanged: {
                        if (checked) {
                            metadataModel.resourceType = "nfo:Document"
                        }
                    }
                }
                RadioButton {
                    text: "Images"
                    onCheckedChanged: {
                        if (checked) {
                            metadataModel.resourceType = "nfo:Image"
                        }
                    }
                }
                RadioButton {
                    text: "Any"
                    onCheckedChanged: {
                        if (checked) {
                            metadataModel.resourceType = ""
                        }
                    }
                }
            }
            Item {
                width: 10
                height: 10
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: "Sort"
            }
            ButtonRow {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                RadioButton {
                    text: "Ascending"
                    onCheckedChanged: {
                        if (checked) {
                            metadataModel.sortOrder = Qt.AscendingOrder
                        }
                    }
                }
                RadioButton {
                    text: "Descending"
                    onCheckedChanged: {
                        if (checked) {
                            metadataModel.sortOrder = Qt.DescendingOrder
                        }
                    }
                }
            }
            Item {
                width: 10
                height: 10
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: "Tags"
            }
            ButtonRow {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                exclusive: false
                CheckBox {
                    id: kdeTagCheckbox
                    text: "kde"
                }
                CheckBox {
                    id: nepomukTagCheckbox
                    text: "nepomuk"
                }
            }
            Item {
                width: 10
                height: 10
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: "Dates"
            }
            TextField {
                anchors.verticalCenter: parent.verticalCenter
                onTextChanged: {
                    metadataModel.startDate = text
                }
            }
            TextField {
                anchors.verticalCenter: parent.verticalCenter
                onTextChanged: {
                    metadataModel.endDate = text
                }
            }
            Item {
                width: 10
                height: 10
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: "Rating"
            }
            TextField {
                anchors.verticalCenter: parent.verticalCenter
                onTextChanged: {
                    metadataModel.rating = text
                }
            }
        }
    }

    ListView {
        id: metadataList
        clip: true
        anchors {
            left: parent.left
            top: toolBar.bottom
            right: parent.right
            bottom: parent.bottom
        }

        model: MetadataModel {
            id: metadataModel
            //queryString: "pdf"
            //resourceType: "nfo:Document"
            //activityId: "12c8a6ea-c99b-4a54-bf42-a4e8fbcb9be7"
            //mimeType: "vnd.oasis.opendocument.text"
            sortBy: ["nie:url", "nao:lastModified"]
            tags: {
                if (kdeTagCheckbox.checked && nepomukTagCheckbox.checked) {
                    return ["nepomuk", "kde"]
                } else if (kdeTagCheckbox.checked) {
                    return ["kde"]
                } else if (nepomukTagCheckbox.checked) {
                    return ["nepomuk"]
                } else {
                    return []
                }
            }
            sortOrder: Qt.AscendingOrder
        }

        delegate: Column{
            /*Text {
                text: model["label"]
            }*/
            Text {
                text: model["url"]
            }
        }
    }

    ScrollDecorator {
        flickableItem: metadataList
        orientation: Qt.Vertical
        anchors {
            top:metadataList.top
            right:metadataList.right
            bottom:metadataList.bottom
        }
    }
}