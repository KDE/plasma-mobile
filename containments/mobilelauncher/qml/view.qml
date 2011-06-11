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
    width: 800
    height: 480

    Flickable {
        id: tagCloud
        width: 300
        contentWidth: tagFlow.width
        contentHeight: tagFlow.height

        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        Flow {
            id: tagFlow
            width: 300
            spacing: 8

            Repeater {
                model: appModel.allCategories
                Text {
                    text: display
                    font.pointSize: 8+(Math.min(weight*4, 40)/2)
                    MouseArea {
                        anchors.fill: parent
                    }
                }
            }
        }
    }

    MobileComponents.IconGrid {
        model: (searchQuery == "")?appModel:runnerModel
        delegate: Component {
            MobileComponents.IconDelegate {
                icon: decoration
                text: display
                onClicked: {
                    appsView.clicked(url)
                }
            }
        }

        anchors {
            left: tagCloud.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            margins: 4
        }

        onSearchQueryChanged: {
            if (searchQuery == "") {
                runnerModel.setQuery(runnerModel.defaultQuery)
            } else {
                runnerModel.setQuery(searchQuery)
            }
        }
    }
}


