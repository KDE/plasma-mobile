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
        PlasmaCore.FrameSvgItem {
            id : background
            imagePath: "widgets/lineedit"
            prefix: "base"

            width: 300
            height: 35
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            TextInput {
                id: searchField
                anchors.fill:parent
                anchors.leftMargin: background.margins.left
                anchors.rightMargin: background.margins.right
                anchors.topMargin: background.margins.top
                anchors.bottomMargin: background.margins.bottom
                activeFocusOnPress: false
                onTextChanged: {
                    searchTimer.running = true
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (!searchField.activeFocus) {
                            searchField.forceActiveFocus()
                            searchField.openSoftwareInputPanel();
                        } else {
                            searchField.focus = false;
                        }
                    }
                    onPressAndHold: searchField.closeSoftwareInputPanel();
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
                    hideSearchFieldAnim.to = searchFieldContainer.height;
                    hideSearchFieldAnim.running = true;
                }
            }
            PlasmaWidgets.IconWidget {
                id: clearButton
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: -10
                visible: false
                size: "64x64"
                Component.onCompleted: {
                    setIcon("edit-clear-locationbar-rtl")
                }
                onClicked: {
                    searchField.text = ""
                }
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


        model: main.model?Math.ceil(main.model.count/18.0):0
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
                height: childrenRect.height
                Repeater {
                    model: MobileComponents.PagedProxyModel {
                        sourceModel: main.model
                        currentPage: index
                        pageSize: 18
                    }
                    delegate: main.delegate
                }
            }
        }
    }


    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: appsView.bottom
        anchors.topMargin: 10
        Row {
            anchors.centerIn: parent
            spacing: 20

            Repeater {
                model: main.model?Math.ceil(main.model.count/18.0):0

                Rectangle {
                    y: appsView.currentIndex == index ? -2 : 0
                    width: appsView.currentIndex == index ? 10 : 6
                    height: appsView.currentIndex == index ? 10 : 6
                    radius: 4
                    smooth: true
                    color: appsView.currentIndex == index ? Qt.rgba(1,1,1,1) : Qt.rgba(1,1,1,0.6)

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
