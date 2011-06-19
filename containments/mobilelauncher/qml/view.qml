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
    width: 400
    height: 150

    Flickable {
        id: tagCloud
        width: 200
        contentWidth: tagFlow.width
        contentHeight: tagFlow.height
        opacity: (appGrid.searchQuery == "")?1:0.3
        clip: true

        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        Flow {
            id: tagFlow
            width: 200
            spacing: 8

            Text {
                id: everythingTag
                text: i18n("Everything")
                font.pointSize: 20
                font.bold: true

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        appModel.shownCategories = Array()
                        for (var i=0; i<tagFlow.children.length; ++i ) {
                            var child = tagFlow.children[i]
                            if (child.font) {
                                child.font.bold = false
                            }
                        }
                        everythingTag.font.bold = true
                    }
                }
            }

            Repeater {
                model: appModel.allCategories
                Text {
                    id: tagDelegate
                    text: display
                    font.pointSize: 8+(Math.min(weight*4, 40)/2)
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var categories = appModel.shownCategories
                            if (categories.indexOf(display) > -1) {
                                j = 0;
                                while (j < categories.length) {
                                    if (categories[j] == display) {
                                        categories.splice(j, 1);
                                    } else {
                                        j++;
                                    }
                                }
                                tagDelegate.font.bold = false
                            } else {
                                categories[categories.length] = display
                                tagDelegate.font.bold = true
                            }
                            appModel.shownCategories = categories
                            everythingTag.font.bold = (categories.length == 0)
                        }
                    }
                }
            }
        }
    }

    MobileComponents.IconGrid {
        id: appGrid
        model: (searchQuery == "")?appModel:runnerModel
        delegate: Component {
            MobileComponents.ResourceDelegate {
                width: appGrid.delegateWidth
                height: appGrid.delegateHeight
                property string className: "FileDataObject"
                resourceType: "FileDataObject"
                property string label: display
                property string mimeType: "buh"
                property variant icon: decoration
                onClicked: {
                    appsView.clicked(url)
                }

            }
        }
        /*Component {
            MobileComponents.IconDelegate {
                icon: decoration
                text: display
                onClicked: {
                    appsView.clicked(url)
                }
            }
        }*/

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


