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

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import "categories.js" as Categories


Flickable {
    id: tagCloud
    height: 200
    contentWidth: tagFlow.width
    contentHeight: tagFlow.height
    opacity: (searchField.searchQuery == "")?1:0.3
    clip: true


    PlasmaCore.DataSource {
        id: categoriesSource
        engine: "org.kde.active.apps"
        connectedSources: ["Categories"]
        interval: 0
    }
    PlasmaCore.DataModel {
        id: categoriesModel
        keyRoleFilter: ".*"
        dataSource: categoriesSource
    }

    anchors {
        left: parent.left
        top: parent.top
        right: parent.right
    }
    Flow {
        id: tagFlow
        height: 200
        spacing: 8
        flow: Flow.TopToBottom

        Text {
            id: everythingTag
            text: i18n("Everything")
            font.pointSize: 20
            font.bold: true
            color: theme.textColor

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    appsSource.connectedSources = ["Apps"]
                    Categories.activeCategories = new Array()
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
            model: categoriesModel
            Text {
                id: tagDelegate
                text: name
                font.pointSize: 8+(Math.min(items*4, 40)/2)
                color: theme.textColor

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (Categories.activeCategories.indexOf(name) > -1) {
                            j = 0;
                            while (j < Categories.activeCategories.length) {
                                if (Categories.activeCategories[j] == name) {
                                    Categories.activeCategories.splice(j, 1);
                                } else {
                                    j++;
                                }
                            }
                            tagDelegate.font.bold = false
                        } else {
                            Categories.activeCategories[Categories.activeCategories.length] = name
                            tagDelegate.font.bold = true
                        }

                        if (Categories.activeCategories.length > 0) {
                            appsSource.connectedSources = ["Apps:"+Categories.activeCategories.join("|")]
                        } else {
                            appsSource.connectedSources = ["Apps"]
                        }
                        everythingTag.font.bold = (Categories.activeCategories.length == 0)
                    }
                }
            }
        }
    }
}

