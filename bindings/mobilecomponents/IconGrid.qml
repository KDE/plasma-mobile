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
    property int pageSize: Math.floor(appsView.width/delegateWidth)*Math.floor(appsView.height/delegateHeight)
    property int delegateWidth: 120
    property int delegateHeight: 120

    PlasmaCore.Theme {
        id:theme
    }


    ListView {
        id: appsView
        objectName: "appsView"
        pressDelay: 200

        anchors.fill: parent


        model: main.model?Math.ceil(main.model.count/main.pageSize):0
        highlightRangeMode: ListView.StrictlyEnforceRange
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem

        clip: true
        signal clicked(string url)


        delegate: Flow {
            width: appsView.width
            height: appsView.height
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
