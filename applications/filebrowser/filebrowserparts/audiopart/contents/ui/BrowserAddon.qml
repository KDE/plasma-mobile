/*
 *   Copyright 2013 Marco Martin <mart@kde.org>
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
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.metadatamodels 0.1 as MetadataModels
import org.kde.plasma.components 0.1 as PlasmaComponents

Item {
    id: root

    anchors {
        left: parent.left
        right: parent.right
    }
    height: mainColumn.height

    property Item currentItem


    PlasmaComponents.Highlight {
        id: highlight
        anchors {
            left: parent.left
            right: parent.right
        }
        opacity: currentItem == undefined ? 0 : 1
        y: root.mapFromItem(root.currentItem, 0, 0).y + currentItem.height/2 - height/2
        height: theme.defaultFont.mSize.height * 2
        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    }

    Column {
        id: mainColumn

        anchors {
            left: parent.left
            right: parent.right
            leftMargin: theme.defaultFont.mSize.width
        }

        MouseArea {
            id: artistHeading
            property bool open: false
            onClicked: artistHeading.open = !artistHeading.open
            anchors {
                left: parent.left
                right: parent.right
            }
            height: childrenRect.height
            PlasmaExtras.Heading {
                text: i18n("Artist")
                PlasmaCore.IconItem {
                    source: artistHeading.open ? "go-down" : "go-next"
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.left
                    }
                    width: height
                }
                anchors {
                    right: parent.right
                    rightMargin: theme.defaultFont.mSize.width
                }
            }
        }
        PlasmaExtras.ConditionalLoader {
            anchors {
                left: parent.left
                right: parent.right
            }
            height: item && artistHeading.open ? item.implicitHeight : 0
            clip: true
            when: artistHeading.open
            Behavior on height {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
            source: Component {
                Column {
                    id: artistList
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    Repeater {
                        model: MetadataModels.MetadataModel {
                                queryProvider: MetadataModels.CloudQueryProvider {
                                    cloudCategory: "nmm:performer"
                                    resourceType: "nfo:Audio"
                                    minimumRating: metadataModel.queryProvider.minimumRating
                                }
                            }
                        delegate : PlasmaComponents.Label {
                            id: artistDelegate
                            text: label
                            width: artistList.width
                            elide: Text.ElideRight
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (metadataModel.queryProvider.extraParameters["nmm:performer"] != label) {
                                        metadataModel.queryProvider.extraParameters["nmm:performer"] = label
                                        root.currentItem = artistDelegate
                                    } else {
                                        metadataModel.queryProvider.extraParameters["nmm:performer"] = ""
                                        root.currentItem = null
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        MouseArea {
            id: albumHeading
            property bool open: false
            onClicked: albumHeading.open = !albumHeading.open
            anchors {
                left: parent.left
                right: parent.right
            }
            height: childrenRect.height
            PlasmaExtras.Heading {
                text: i18n("Album")
                PlasmaCore.IconItem {
                    source: albumHeading.open ? "go-down" : "go-next"
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.left
                    }
                    width: height
                }
                anchors {
                    right: parent.right
                    rightMargin: theme.defaultFont.mSize.width
                }
            }
        }

        PlasmaExtras.ConditionalLoader {
            anchors {
                left: parent.left
                right: parent.right
            }
            height: item && albumHeading.open ? item.implicitHeight : 0
            clip: true
            when: albumHeading.open
            Behavior on height {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
            source: Component {
                Column {
                    id: albumList
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    Repeater {
                        model: MetadataModels.MetadataModel {
                                queryProvider: MetadataModels.CloudQueryProvider {
                                    cloudCategory: "nmm:musicAlbum"
                                    resourceType: "nfo:Audio"
                                    minimumRating: metadataModel.queryProvider.minimumRating
                                }
                            }
                        delegate : PlasmaComponents.Label {
                            id: albumDelegate
                            text: label
                            width: albumList.width
                            elide: Text.ElideRight
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (metadataModel.queryProvider.extraParameters["nmm:musicAlbum"] != label) {
                                        metadataModel.queryProvider.extraParameters["nmm:musicAlbum"] = label
                                        root.currentItem = albumDelegate
                                    } else {
                                        metadataModel.queryProvider.extraParameters["nmm:musicAlbum"] = ""
                                        root.currentItem = undefined
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
