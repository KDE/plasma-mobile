/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
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

import QtQuick 1.1
import org.kde.metadatamodels 0.1 as MetadataModels
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents


ListView {
    id: root
    spacing: 0
    orientation: ListView.Horizontal
    //FIXME
    width: 300
    clip: true
    height: theme.defaultFont.mSize.height * 1.7


    property string path: dirModel.path
    onPathChanged: {
        var pieces = path.replace(/^[\/]+/, '').split("/")
        pathModel.clear()
        pathModel.append({title: ""})

        for (i in pieces) {
            pathModel.append({title: pieces[i]})
        }
        contentX = contentWidth - width
    }

    model: ListModel {
        id: pathModel
    }

    delegate: Item {
        width: stepButton.width - 10
        height: stepButton.height
        z: root.count - index
        PlasmaComponents.ToolButton {
            id: stepButton
            text: model["title"]
            flat: false
            checked: index == root.count-1
           // height: implicitHeight

            PlasmaCore.SvgItem {
                svg: PlasmaCore.Svg {imagePath: "toolbar-icons/go"}
                elementId: "go-next"
                width: theme.smallIconSize
                height: width
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: 4
                }
                visible: !stepButton.checked
            }
            onClicked: {
                var found = false
                for (var i = pathModel.count - 1; i >= 0; --i) {

                    if (pathModel.get(i).title == model["title"]) {
                        found = true
                        break
                    }
                    pathModel.remove(i)
                }
                var path = ""
                var item
                for (var i = 1; i < pathModel.count; ++i) {
                    item = pathModel.get(i)
                    path += "/" + item.title
                }
                dirModel.url = devicesSource.data[resourceBrowser.currentUdi]["File Path"] + path
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
