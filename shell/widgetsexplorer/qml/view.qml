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
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Sheet {
    id: widgetsExplorer
    objectName: "widgetsExplorer"

    signal addAppletRequested(string plugin)
    signal closeRequested


    onAccepted: {
        for (var i = 0; i < selectedModel.count; ++i) {
            widgetsExplorer.addAppletRequested(selectedModel.get(i).pluginName)
        }
    }
    onStatusChanged: {
        if (status == PlasmaComponents.DialogStatus.Closed) {
            closeRequested()
        }
    }

    ListModel {
        id: selectedModel
    }


    Component.onCompleted: open()

    content: [
        MobileComponents.ViewSearch {
            id: searchField

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }

            onSearchQueryChanged: {
                appletsFilter.filterRegExp = ".*"+searchQuery+".*"
            }
        },
        MobileComponents.IconGrid {
            id: appletsView

            anchors {
                left: parent.left
                right: parent.right
                top: searchField.bottom
                bottom: parent.bottom
            }

            model: PlasmaCore.SortFilterModel {
                id: appletsFilter
                sourceModel: myModel
            }


            delegate: Component {
                Item {
                    width: appletsView.delegateWidth
                    height: appletsView.delegateHeight
                    PlasmaCore.FrameSvgItem {
                            id: highlightFrame
                            imagePath: "widgets/viewitem"
                            prefix: "selected+hover"
                            opacity: 0
                            width: appletsView.delegateWidth
                            height: appletsView.delegateHeight
                            Behavior on opacity {
                                NumberAnimation {duration: 250}
                            }
                    }
                    MobileComponents.ResourceDelegate {
                        //icon: decoration
                        genericClassName: "FileDataObject"
                        property string label: display
                        width: appletsView.delegateWidth
                        height: appletsView.delegateHeight

                        onClicked: {
                            //already in the model?
                            //second case, for the apps model
                            for (var i = 0; i < selectedModel.count; ++i) {
                                if (model.pluginName == selectedModel.get(i).pluginName) {
                                    highlightFrame.opacity = 0
                                    selectedModel.remove(i)
                                    return
                                }
                            }

                            var item = new Object
                            item["pluginName"] = model["pluginName"]
                            //this is to make AppModel work
                            if (!item["pluginName"]) {
                                item["pluginName"] = pluginName
                            }

                            selectedModel.append(item)
                            highlightFrame.opacity = 1
                        }
                    }
                }
            }
        }
    ]

}
