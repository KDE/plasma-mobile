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

import QtQuick 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.baloo 0.1 as Baloo
import org.kde.draganddrop 2.0
import QtQuick.Layouts 1.1
import org.kde.activities 0.1 as Activities

ColumnLayout {
    anchors {
        left: parent.left
        right: parent.right
    }

    PlasmaCore.SortFilterModel {
        id: sortFilterModel
        sourceModel: ListModel {
            ListElement {
                resourceType: "File/Document"
                label: "Documents"
            }

            ListElement {
                resourceType: "File/Video"
                label: "Videos"
            }

            ListElement {
                resourceType: "File/Music"
                label: "Music"
            }
            ListElement {
                resourceType: "File/Image"
                label: "Images"
            }
        }

        sortRole: "count"
        sortOrder: Qt.DescendingOrder
        filterRole: "label"
    }

    ListModel {
        id: activityData
    }

    PlasmaCore.SortFilterModel{
        id: currentActivityData
        sourceModel:Activities.ResourceModel {
            shownActivities: ":current"
        }
    }

    PlasmaExtras.Heading {
        text: i18n("File type")
        anchors {
            top: parent.top
            right: parent.right
            rightMargin: theme.mSize(theme.defaultFont).width
        }
    }

    //recreate the QueryResultsModel
    Baloo.QueryResultsModel {
        id: balooRestoreModel
    }

    PlasmaComponents.ButtonColumn {
        id: buttonColumn
        spacing: 4
        exclusive: false

        anchors {
            left: parent.left
            leftMargin: theme.mSize(theme.defaultFont).width
        }

        Repeater {
            id: categoryRepeater
            model: sortFilterModel
            delegate: PlasmaComponents.RadioButton {
                id: delegateItem
                text: label

                onCheckedChanged: {
                    if (checked) {
                        buttonColumn.exclusive = true
                        if (fileBrowserRoot.model.sourceModel != balooDataModel) {
                            fileBrowserRoot.model.sourceModel = balooRestoreModel
                            balooDataModel.sourceModel.query.type = model.resourceType
                        }
                    }
                }
            }
        }
        PlasmaExtras.Heading {
            text: i18n("Activity")
            anchors {
                right: parent.right
                rightMargin: -(parent.parent.width - parent.width) + theme.mSize(theme.defaultFont).width*2
            }
        }
        PlasmaComponents.RadioButton {
            id: activityButton
            text: i18n("Current activity")
            onCheckedChanged: {
                if (checked) {
                    activityData.clear()
                    for (var i = 0; i < activitySource.sourceModel.count(); i++) {
                        var agent = activitySource.get(i).agent
                        if (agent !== "Application") {
                            currentActivityData.sourceModel.shownAgents = agent;
                            for (var j=0; j < currentActivityData.sourceModel.count(); j++) {
                                var data = currentActivityData.get(j)
                                data["resourceType"] = agent
                                activityData.append(data)
                            }
                        }
                    }
                    //change our model
                    fileBrowserRoot.model.sourceModel = activityData
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
