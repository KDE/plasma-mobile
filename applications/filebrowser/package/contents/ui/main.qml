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

import QtQuick 1.0
import org.kde.metadatamodels 0.1 as MetadataModels
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.plasma.slccomponents 0.1 as SlcComponents
import org.kde.qtextracomponents 0.1


Image {
    id: imageViewer
    objectName: "imageViewer"
    source: "image://appbackgrounds/standard"
    fillMode: Image.Tile
    state: "browsing"

    width: 360
    height: 360


    signal zoomIn
    signal zoomOut


    MobileComponents.Package {
        id: viewerPackage
        name: "org.kde.active.filebrowser"
    }

    MobileComponents.ResourceInstance {
        id: resourceInstance
    }



    MetadataModels.MetadataUserTypes {
        id: userTypes
    }
    MetadataModels.MetadataModel {
        id: metadataModel
        //sortBy: ["nao:numericRating"]
        //sortOrder: Qt.DescendingOrder
        //queryString: "pdf"
        //limit: 20
    }



    PlasmaComponents.ToolBar {
        id: toolBar
    }

    PlasmaComponents.PageStack {
        id: mainStack
        clip: false
        toolBar: toolBar
        initialPage: Qt.createComponent("Browser.qml")
        anchors {
            right: sideBar.left
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
    }

    Image {
        id: sideBar
        source: "image://appbackgrounds/contextarea"
        fillMode: Image.Tile

        width: parent.width/4
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        Image {
            source: "image://appbackgrounds/shadow-right"
            fillMode: Image.TileVertically
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
        }

        Column {
            anchors {
                fill: parent
                topMargin: toolBar.height + theme.defaultFont.mSize.width
                leftMargin: theme.defaultFont.mSize.width * 2
                margins: theme.defaultFont.mSize.width
            }
            spacing: 4
            PlasmaComponents.Label {
                text: "<b>"+i18n("File types")+"</b>"
            }
            PlasmaComponents.ButtonColumn {
                spacing: 4
                anchors {
                    left: parent.left
                    leftMargin: theme.defaultFont.mSize.width
                }

                Repeater {
                    model: MetadataModels.MetadataCloudModel {
                        id: typesCloudModel
                        cloudCategory: "rdf:type"
                        resourceType: "nfo:FileDataObject"
                        allowedCategories: userTypes.userTypes
                    }
                    delegate: PlasmaComponents.RadioButton {
                            text: i18n("%1 (%2)", userTypes.typeNames[model["label"]], model["count"])
                            //FIXME: more elegant way to remove applications?
                            visible: model["label"] != undefined && model["label"] != "nfo:Application"
                            onCheckedChanged: {
                                if (checked) {
                                    metadataModel.resourceType = model["label"]
                                }
                            }
                        }
                }
            }



            PlasmaComponents.Label {
                text: "<b>"+i18n("Rating")+"</b>"
            }

            MobileComponents.Rating {
                anchors.horizontalCenter: parent.horizontalCenter
                onScoreChanged: metadataModel.minimumRating = score
            }




            PlasmaComponents.Label {
                text: "<b>"+i18n("Tags")+"</b>"
                visible: tagCloud.count > 0
            }
            Column {
                spacing: 4
                anchors {
                    left: parent.left
                    leftMargin: theme.defaultFont.mSize.width
                }
                Repeater {
                    model: MetadataModels.MetadataCloudModel {
                        id: tagCloud
                        cloudCategory: "nao:hasTag"
                        resourceType: metadataModel.resourceType
                    }
                    delegate: PlasmaComponents.CheckBox {
                        text: i18n("%1 (%2)", model["label"], model["count"])
                        visible: model["label"] != undefined
                        onCheckedChanged: {
                            var tags = metadataModel.tags
                            if (checked) {
                                tags[tags.length] = model["label"];
                                metadataModel.tags = tags
                            } else {
                                for (var i = 0; i < tags.length; ++i) {
                                    if (tags[i] == model["label"]) {
                                        tags.splice(i, 1);
                                        metadataModel.tags = tags
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
 
    SlcComponents.SlcMenu {
        id: contextMenu
    }
}
