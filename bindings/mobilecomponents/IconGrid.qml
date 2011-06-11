/*
    Copyright 2010 Marco Martin <notmart@gmail.com>

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

import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents


Item {
    id: main

    property Component delegate
    property QtObject model
    property string searchQuery
    property int pageSize: 18

    PlasmaCore.Theme {
        id:theme
    }


    Item {
        id: searchFieldContainer
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }

        height: 64
        PlasmaWidgets.LineEdit {
            id : searchField

            /*width: 300
            height: 35*/
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            onTextChanged: {
                searchTimer.running = true
            }
        }
        Timer {
            id: searchTimer
            interval: 500;
            running: false
            repeat: false
            onTriggered: {
                if (searchField.text == "") {
                    clearButton.visible = false
                } else {
                    clearButton.visible = true
                }
                searchQuery = searchField.text
            }
        }
        PlasmaWidgets.IconWidget {
            id: clearButton
            y: 6
            anchors.right: searchField.right
            anchors.rightMargin: -6
            visible: false
            size: "48x48"
            Component.onCompleted: {
                setIcon("edit-clear-locationbar-rtl")
            }
            onClicked: {
                searchField.text = ""
            }
        }
    }
    ListView {
        id: appsView
        objectName: "appsView"

        anchors {
            left: parent.left
            top: searchFieldContainer.bottom
            right: parent.right
            bottom: parent.bottom
        }


        model: main.model?Math.ceil(main.model.count/main.pageSize):0
        highlightRangeMode: ListView.StrictlyEnforceRange
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem

        clip: true
        signal clicked(string url)


        delegate: Item {
            width: appsView.width
            height: appsView.height
            Flow {
                anchors.centerIn: parent
                width: appsView.width
                height: 400
                move: Transition {
                    NumberAnimation {
                        properties: "x,y"
                        duration: 150
                    }
                }
                Repeater {
                    model: MobileComponents.PagedProxyModel {
                        sourceModel: main.model
                        currentPage: index
                        pageSize: main.pageSize
                    }
                    delegate: main.delegate
                }
            }
        }
    }


    Item {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin:8
        }
        Row {
            anchors.centerIn: parent
            spacing: 20

            Repeater {
                model: main.model?Math.ceil(main.model.count/main.pageSize):0

                Rectangle {
                    y: appsView.currentIndex == index ? -2 : 0
                    width: appsView.currentIndex == index ? 10 : 6
                    height: appsView.currentIndex == index ? 10 : 6
                    radius: 4
                    smooth: true
                    opacity: appsView.currentIndex == index ? 0.8: 0.55
                    color: theme.textColor

                    MouseArea {
                        width: 20; height: 20
                        anchors.centerIn: parent
                        onClicked: appsView.currentIndex = index
                    }
                }
            }
        }
    }
}
