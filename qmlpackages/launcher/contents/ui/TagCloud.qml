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
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import "categories.js" as Categories


Item {
    height: 200
    anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }
    Item {
        id: everythingButton
        x: enabled?parent.width/6:-width-10
        y: parent.height + 18
        width: everythingPushButton.width
        height: everythingPushButton.height
        enabled: false

        PlasmaWidgets.PushButton {
            id: everythingPushButton

            text: i18n("Show everything")

            onEnabledChanged: NumberAnimation {
                                duration: 250
                                target: everythingButton
                                properties: "x"
                                easing.type: Easing.InOutQuad
                            }
            onClicked: {
                appsSource.connectedSources = ["Apps"]
                Categories.activeCategories = new Array()
                for (var i=0; i<tagFlow.children.length; ++i ) {
                    var child = tagFlow.children[i]
                    if (child.active != undefined) {
                        child.active = false
                    }
                }
                everythingButton.enabled = false
            }
        }
        Behavior on x {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    }

    Flickable {
        id: tagCloud
        contentWidth: tagFlow.width
        contentHeight: tagFlow.height
        opacity: (searchField.searchQuery == "")?1:0
        clip: false


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

        anchors.fill: parent

        Flow {
            id: tagFlow
            height: 200
            spacing: 8
            flow: Flow.TopToBottom


            Repeater {
                model: categoriesModel
                Item {
                    id: tagDelegate
                    width: tagText.width
                    height: tagText.height
                    property bool active
                    Rectangle {
                        anchors.fill: parent
                        color: theme.backgroundColor
                        radius: 3
                        smooth: true
                        opacity: tagDelegate.active?0.5:0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                    Text {
                        id: tagText
                        text: name
                        font.pointSize: 8+(Math.min(items*4, 40)/2)
                        color: theme.textColor
                        font.bold: tagDelegate.active

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
                                    tagDelegate.active = false
                                } else {
                                    Categories.activeCategories[Categories.activeCategories.length] = name
                                    tagDelegate.active = true
                                }

                                if (Categories.activeCategories.length > 0) {
                                    appsSource.connectedSources = ["Apps:"+Categories.activeCategories.join("|")]
                                } else {
                                    appsSource.connectedSources = ["Apps"]
                                }
                                everythingButton.enabled = (Categories.activeCategories.length > 0)
                            }
                        }
                    }
                }
            }
        }
    }
}
