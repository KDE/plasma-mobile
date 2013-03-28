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
import org.kde.plasma.extras 0.1 as PlasmaExtraComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.draganddrop 1.0

Column {

    property string currentType

    anchors {
        left: parent.left
        right: parent.right
    }

    PlasmaCore.SortFilterModel {
        id: sortFilterModel
        sourceModel: MetadataModels.MetadataModel {
            id: typesCloudModel
            queryProvider: MetadataModels.CloudQueryProvider {
                cloudCategory: "rdf:type"
                resourceType: "nfo:FileDataObject"
                minimumRating: metadataModel.queryProvider.minimumRating
            }
        }
        sortRole: "count"
        sortOrder: Qt.DescendingOrder
        filterRole: "label"
        filterRegExp: "nfo:Document|nfo:Image|nfo:Audio|nfo:Video|nfo:Archive"
    }

    PlasmaExtraComponents.Heading {
        text: i18n("File type")
        anchors {
            top: parent.top
            right: parent.right
            rightMargin: theme.defaultFont.mSize.width
        }
    }

    PlasmaComponents.ButtonColumn {
        id: buttonColumn
        spacing: 4
        exclusive: false
        onCheckedButtonChanged: {
            resourceBrowser.ensureBrowserVisible()
        }
        anchors {
            left: parent.left
            leftMargin: theme.defaultFont.mSize.width
        }

        Repeater {
            id: categoryRepeater
            model: sortFilterModel
            delegate: PlasmaComponents.RadioButton {
                id: delegateItem
                text: userTypes.typeNames[model["label"]]
                //FIXME: more elegant way to remove applications?
                visible: model["label"] != undefined && model["label"] != "nfo:Application"
                //checked: metadataModel.queryProvider.resourceType == model["label"]
                onCheckedChanged: {
                    if (checked) {
                        buttonColumn.exclusive = true
                        metadataModel.queryProvider.resourceType = model["label"]
                    }
                }
            }
        }
        PlasmaExtraComponents.Heading {
            text: i18n("Activity")
            anchors {
                right: parent.right
                rightMargin: -(parent.parent.width - parent.width) + theme.defaultFont.mSize.width*2
            }
        }
        PlasmaComponents.RadioButton {
            text: i18n("Current activity")
            //checked: metadataModel.queryProvider.activityId == activitySource.data.Status.Current
            onCheckedChanged: {
                if (checked) {
                    buttonColumn.exclusive = true
                    metadataModel.queryProvider.resourceType = "nfo:FileDataObject"
                    metadataModel.queryProvider.activityId = activitySource.data.Status.Current
                } else {
                    metadataModel.queryProvider.activityId = ""
                }
            }
            Rectangle {
                anchors {
                    fill: parent
                    margins: -5
                }
                visible: activityDrop.underDrag
                radius: 4
                color: theme.textColor
                opacity: 0.4
            }
            DropArea {
                id: activityDrop
                anchors.fill: parent
                property bool underDrag: false
                onDragEnter: underDrag = true
                onDragLeave: underDrag = false
                onDrop: {
                    underDrag = false
                    var service = metadataSource.serviceForSource("")
                    var operation = service.operationDescription("connectToActivity")
                    operation["ActivityUrl"] = activitySource.data["Status"]["Current"]

                    for (var i = 0; i < event.mimeData.urls.length; ++i) {
                        operation["ResourceUrl"] = event.mimeData.urls[i]
                        service.startOperationCall(operation)
                    }
                }
            }
        }
    }
}
