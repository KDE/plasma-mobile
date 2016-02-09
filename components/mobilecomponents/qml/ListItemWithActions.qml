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
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.5
import QtQuick.Layouts 1.2
import org.kde.plasma.mobilecomponents 0.2
import QtGraphicalEffects 1.0

/**
 * An item delegate Intended to support extra actions obtainable
 * by uncovering them by dragging away the item with the handle
 * This acts as a container for normal list items.
 * Any subclass of AbstractListItem can be assigned as the listItem property.
 * @code
 * ListView {
 *     model: myModel
 *     delegate: ListItemWidthActions {
 *         BasicListItem {
 *             label: model.text
 *         }
 *         actions: [
 *              Action {
 *                  iconName: "document-decrypt"
 *                  onTriggered: print("Action 1 clicked")
 *              },
 *              Action {
 *                  iconName: model.action2Icon
 *                  onTriggered: //do something
 *              }
 *         ]
 *     }
 * 
 * }
 * @endcode
 *
 * @inherit QtQuick.Item
 */
Item {
    id: listItemRoot

    default property AbstractListItem listItem

    /**
     * type: list<Action>
     * Defines the actions for the list item: at most 4 buttons will
     * contain the actions for the item, that can be revealed by
     * sliding away the list item.
     */
    property list<Action> actions



    implicitWidth: parent ? parent.width : listItem.width
    implicitHeight: listItem.height
    height: visible ? implicitHeight : 0

    onListItemChanged: {
        listItem.parent = listItemParent
    }
    Component.onCompleted: {
        listItem.parent = listItemParent
    }


    Rectangle {
        id: shadowHolder
        color: Theme.backgroundColor
        anchors.fill: parent
    }
    LinearGradient {
        height: Units.gridUnit/2
        anchors {
            right: parent.right
            left: parent.left
            top: parent.top
        }

        start: Qt.point(0, 0)
        end: Qt.point(0, Units.gridUnit/2)
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Qt.rgba(0, 0, 0, 0.2)
            }
            GradientStop {
                position: 0.3
                color: Qt.rgba(0, 0, 0, 0.1)
            }
            GradientStop {
                position: 1.0
                color:  "transparent"
            }
        }
    }


    RowLayout {
        id: actionsLayout
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: y
        }
        height: Math.min( parent.height / 1.5, Units.iconSizes.medium)
        property bool exclusive: false
        property Item checkedButton
        spacing: Units.largeSpacing
        Repeater {
            model: {
                if (listItemRoot.actions.length == 0) {
                    return null;
                } else {
                    return listItemRoot.actions[0].text !== undefined &&
                        listItemRoot.actions[0].trigger !== undefined ?
                            listItemRoot.actions :
                            listItemRoot.actions[0];
                }
            }
            delegate: Icon {
                Layout.fillHeight: true
                Layout.minimumWidth: height
                source: modelData.iconName
                MouseArea {
                    anchors {
                        fill: parent
                        margins: -Units.smallSpacing
                    }
                    onClicked: {
                        if (modelData && modelData.trigger !== undefined) {
                            modelData.trigger();
                        // assume the model is a list of QAction or Action
                        } else if (toolbar.model.length > index) {
                            toolbar.model[index].trigger();
                        } else {
                            console.log("Don't know how to trigger the action")
                        }
                        positionAnimation.to = 0;
                        positionAnimation.running = true;
                    }
                }
            }
        }
    }

    PropertyAnimation {
        id: positionAnimation
        target: mainFlickable
        properties: "contentX"
        duration: Units.longDuration
        easing.type: Easing.InOutQuad
        
    }
    Flickable {
        id: mainFlickable
        interactive: false
        boundsBehavior: Flickable.StopAtBounds
        anchors.fill: parent
        contentWidth: mainItem.width
        contentHeight: height
        onFlickEnded: {
            if (contentX > width / 2) {
                positionAnimation.to = width - height;
            } else {
                positionAnimation.to = 0;
            }
            positionAnimation.running = true;
        }

        Item {
            id: mainItem
            width: (mainFlickable.width * 2) - height 
            height: mainFlickable.height
            Item {
                id: listItemParent
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: mainFlickable.width
            }
            LinearGradient {
                width: Units.gridUnit/2
                anchors {
                    left: listItemParent.right
                    top: parent.top
                    bottom: parent.bottom
                }

                start: Qt.point(0, 0)
                end: Qt.point(Units.gridUnit/2, 0)
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: Qt.rgba(0, 0, 0, 0.2)
                    }
                    GradientStop {
                        position: 0.3
                        color: Qt.rgba(0, 0, 0, 0.1)
                    }
                    GradientStop {
                        position: 1.0
                        color:  "transparent"
                    }
                }
            }
            
            MouseArea {
                anchors {
                    left: listItemParent.right
                    top: parent.top
                    bottom: parent.bottom
                    leftMargin:  -height
                }
                preventStealing: true
                width: mainFlickable.width - actionsLayout.width
                property var downTimestamp;
                property int startX
                property int startMouseX

                onClicked: {
                    if (Math.abs(startX - mainFlickable.contentX) > Units.gridUnit ||
                        Math.abs(startMouseX - mouse.x) > Units.gridUnit) {
                        return;
                    }
                    if (mainFlickable.contentX > mainFlickable.width / 2) {
                        positionAnimation.to = 0;
                    } else {
                        positionAnimation.to = mainFlickable.width - mainFlickable.height;
                    }
                    positionAnimation.running = true;
                }
                onPressed: {
                    downTimestamp = (new Date()).getTime();
                    startX = mainFlickable.contentX;
                    startMouseX = mouse.x;
                }
                onPositionChanged: {
                    mainFlickable.contentX = Math.max(0, Math.min(mainFlickable.width - height, mainFlickable.contentX + (startMouseX - mouse.x)))
                }
                onReleased: {
                    var speed = ((startX - mainFlickable.contentX) / ((new Date()).getTime() - downTimestamp) * 1000);
                    mainFlickable.flick(speed, 0);
                }
                Icon {
                    id: handleIcon
                    anchors.verticalCenter: parent.verticalCenter
                    width: Units.iconSizes.smallMedium
                    height: width
                    x: y
                    source: "application-menu"
                }
            }
        }
    }

    Accessible.role: Accessible.ListItem
}
