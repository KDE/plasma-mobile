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

MobileComponents.IconGrid {
    id: resultsGrid
    anchors.fill: parent

    delegateWidth: 130
    delegateHeight: 120

    delegate: Item {
        width: resultsGrid.delegateWidth
        height: resultsGrid.delegateHeight
        PlasmaCore.FrameSvgItem {
                id: highlightFrame
                imagePath: "widgets/viewitem"
                prefix: "selected+hover"
                opacity: 0
                width: 130
                height: 120
                Behavior on opacity {
                    NumberAnimation {duration: 250}
                }
        }
        MobileComponents.ResourceDelegate {
            id: resourceDelegate
            width: 130
            height: 120
            infoLabelVisible: false
            //those two are to make appModel and runnerModel work
            property string label: model["label"]?model["label"]:(model["name"]?model["name"]:model["text"])

            onPressAndHold: {
                //take into account cases for all 3 models

                if (model["url"]) {
                    resourceInstance.uri = model["url"]
                } else if (model["resourceUri"]) {
                    resourceInstance.uri = model["resourceUri"]
                } else if (model["entryPath"]) {
                    resourceInstance.uri = model["entryPath"]
                }

                if (model["label"]) {
                    resourceInstance.title = model["label"]
                } else if (model["name"]) {
                    resourceInstance.title = model["name"]
                } else if (model["text"]) {
                    resourceInstance.title = model["text"]
                }
            }
            onClicked: {
                //already in the model?
                //second case, for the apps model
                for (var i = 0; i < selectedModel.count; ++i) {
                    if ((model.resourceUri && model.resourceUri == selectedModel.get(i).resourceUri) ||

                        (model.entryPath && model.entryPath == selectedModel.get(i).resourceUri)) {
                        highlightFrame.opacity = 0
                        selectedModel.remove(i)
                        return
                    }
                }

                var item = new Object
                item["resourceUri"] = model["resourceUri"]
                //this is to make AppModel work
                if (!item["resourceUri"]) {
                    item["resourceUri"] = model["entryPath"]
                }

                selectedModel.append(item)
                highlightFrame.opacity = 1
            }
            Component.onCompleted: {
                //FIXME: horribly inefficient
                //already in the model?
                for (var i = 0; i < selectedModel.count; ++i) {
                    if (model.resourceUri == selectedModel.get(i).resourceUri) {
                        highlightFrame.opacity = 1
                        return
                    }
                }
            }
            //FIXME here too
            Connections {
                target: selectedModel
                onCountChanged: {
                    if (selectedModel.count == 0) {
                        highlightFrame.opacity = 0
                    }
                }
            }
        }
    }
}
