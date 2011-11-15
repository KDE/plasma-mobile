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

import Qt 4.7
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Rectangle {
    id: widgetsExplorer

    color: Qt.rgba(0,0,0,0.5)
    objectName: "widgetsExplorer"
    width: 800
    height: 480
    opacity: 0

    signal addAppletRequested(string plugin)
    signal closeRequested

    Component.onCompleted: {
        appearAnimation.running = true
    }

    ParallelAnimation {
        id: appearAnimation
        NumberAnimation {
            targets: widgetsExplorer
            properties: "opacity"
            duration: 250
            to: 1
            easing.type: "InOutCubic"
        }
        NumberAnimation {
            targets: dialog
            properties: "scale"
            duration: 250
            to: 1
            easing.type: "InOutCubic"
        }
    }

    SequentialAnimation {
        id: disappearAnimation
        ParallelAnimation {
            NumberAnimation {
                targets: widgetsExplorer
                properties: "opacity"
                duration: 250
                to: 0
                easing.type: "InOutCubic"
            }
            NumberAnimation {
                targets: dialog
                properties: "scale"
                duration: 250
                to: 0
                easing.type: "InOutCubic"
            }
        }
        ScriptAction {
            script: widgetsExplorer.closeRequested()
        }
    }

    PlasmaCore.Theme {
        id: theme
    }

    MouseArea {
        anchors.fill: parent
        onClicked: disappearAnimation.running = true
    }

    ListModel {
        id: selectedModel
    }


    PlasmaCore.FrameSvgItem {
        id: dialog

        state: "hidden"
        imagePath: "dialogs/background"

        anchors.fill: parent
        anchors.margins: 50

        MouseArea {
            anchors.fill: parent
            //eat mouse events to mot trigger the dialog hide
            onPressed: mouse.accepted = true
        }

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
        }
        MobileComponents.IconGrid {
            id: appletsView

            anchors {
                left: parent.left
                right: parent.right
                top: searchField.bottom
                bottom: buttonsRow.top
                leftMargin: parent.margins.left
                topMargin: parent.margins.top
                rightMargin: parent.margins.right
                bottomMargin: parent.margins.bottom
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

        Row {
            id: buttonsRow
            spacing: 8
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: dialog.margins.bottom
            }

            PlasmaComponents.Button {
                id: okButton
                //enabled: selectedResourcesList.count>0

                text: i18n("Add items")
                onClicked : {
                    for (var i = 0; i < selectedModel.count; ++i) {
                        widgetsExplorer.addAppletRequested(selectedModel.get(i).pluginName)
                    }

                    disappearAnimation.running = true
                }
            }

            PlasmaComponents.Button {
                id: cancelButton
                text: i18n("Cancel")

                onClicked: {
                    disappearAnimation.running = true
                }
            }
        }
    }
}
