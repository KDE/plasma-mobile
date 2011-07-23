/*
 *   Copyright 2010 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1

ListItem {
    id: listItem
    property string name
    property string description
    property string icon
    property variant actions


    QIconItem {
        id: iconItem
        x: y
        anchors.verticalCenter: parent.verticalCenter
        width: 48
        height: 68
        icon: QIcon(listItem.icon)
    }

    Column {
        anchors.left: iconItem.right
        anchors.leftMargin: 8
        anchors.right: listItem.padding.right
        anchors.verticalCenter: listItem.verticalCenter
        Column {
            id : delegateLayout
            width: parent.width
            spacing: 5

            Text {
                width: delegateLayout.width
                color: theme.textColor
                font.pointSize: 20
                text: listItem.name
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var service = recommendationsSource.serviceForSource(DataEngineSource)
                        var operation = service.operationDescription("executeAction")
                        operation.Id = actions[0].actionId

                        service.startOperationCall(operation)
                    }
                }
            }
            Text {
                color: theme.textColor
                font.pixelSize: 13
                width: delegateLayout.width
                text: listItem.description
                visible: listItem.description.length>0
            }
        }
        Column {
            id : actionsLayout
            width: parent.width
            spacing: 5
            anchors.left: iconItem.right
            anchors.leftMargin: 8
            anchors.right: listItem.padding.right
            anchors.top: delegateLayout.bottom
            anchors.topMargin: 8
            visible: actions.length > 1

            Repeater {
                model: actions.length
                MouseArea {
                    width: actionLayout.width
                    height: actionLayout.height
                    onClicked: {
                        var service = recommendationsSource.serviceForSource(DataEngineSource)
                        var operation = service.operationDescription("executeAction")
                        operation.Id = actions[modelData].actionId

                        service.startOperationCall(operation)
                    }
                    Row {
                        id: actionLayout
                        spacing: 10
                        QIconItem {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 24
                            height: 24
                            icon: QIcon(actions[modelData].iconName)
                        }
                        Text {
                            text: actions[modelData].text
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
}
