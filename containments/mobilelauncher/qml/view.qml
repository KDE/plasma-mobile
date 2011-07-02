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
import org.kde.plasma.slccomponents 0.1 as SlcComponents

Item {
    width: 400
    height: 150

    MobileComponents.ResourceInstance {
        id: resourceInstance
    }

    SlcComponents.SlcMenu {
        id: contextMenu
    }

    PlasmaCore.Theme {
        id: theme
    }

    TagCloud {
        id:tagCloud
    }

    MobileComponents.ViewSearch {
        id: searchField

        anchors {
            left: tagCloud.right
            right: parent.right
            top:parent.top
        }
        
        onSearchQueryChanged: {
            if (searchQuery == "") {
                runnerModel.setQuery(runnerModel.defaultQuery)
            } else {
                runnerModel.setQuery(searchQuery)
            }
        }
    }

    MobileComponents.IconGrid {
        id: appGrid
        delegateWidth: 128
        delegateHeight: 100
        model: (searchField.searchQuery == "")?appModel:runnerModel
        delegate: Component {
            MobileComponents.ResourceDelegate {
                width: appGrid.delegateWidth
                height: appGrid.delegateHeight
                property string className: "FileDataObject"
                resourceType: "FileDataObject"
                property string label: display
                property string mimeType: "buh"
                onPressed: {
                    resourceInstance.uri = resourceUri
                }
                onClicked: {
                    appsView.clicked(url)
                }

            }
        }

        anchors {
            left: tagCloud.right
            right: parent.right
            top: searchField.bottom
            bottom: parent.bottom
            margins: 4
        }
    }
}


