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

    property string title
    property QtObject model
    property Item currentItem
    property string category

    anchors {
        left: parent.left
        right: parent.right
    }
    height: heading.height + loader.height

    PlasmaComponents.Highlight {
        anchors {
            left: parent.left
            right: parent.right
        }
        opacity: parent.currentItem != undefined && heading.open ? 1 : 0
        y: parent.mapFromItem(parent.currentItem, 0, 0).y + parent.currentItem.height/2 - height/2
        height: theme.defaultFont.mSize.height * 2
        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    }

    MouseArea {
        id: heading
        property bool open: false
        onClicked: heading.open = !heading.open
        anchors {
            left: parent.left
            right: parent.right
        }
        height: childrenRect.height
        visible: model.count > 0
        PlasmaExtras.Heading {
            text: i18n("%1 (%2)", root.title, model.count)
            PlasmaCore.IconItem {
                source: heading.open ? "go-down" : "go-next"
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
        id: loader

        anchors {
            top: heading.bottom
            left: parent.left
            right: parent.right
            leftMargin: theme.defaultFont.mSize.width
        }
        height: item && heading.open ? item.implicitHeight : 0
        clip: true
        when: heading.open
        Behavior on height {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        source: Component {
            Column {
                id: itemsColumn
                anchors {
                    left: parent.left
                    right: parent.right
                }
                Repeater {
                    model: PlasmaCore.SortFilterModel {
                        sourceModel: root.model
                        sortRole: "label"
                    }
                    delegate : PlasmaComponents.Label {
                        id: itemDelegate
                        text: i18nc("name and count", "%1 (%2)", label, count)
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        elide: Text.ElideRight
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (metadataModel.queryProvider.extraParameters[root.category] != resource) {
                                    metadataModel.queryProvider.extraParameters[root.category] = resource
                                    root.currentItem = itemDelegate
                                } else {
                                    metadataModel.queryProvider.extraParameters[root.category] = ""
                                    root.currentItem = null
                                }
                            }
                        }
                        Component.onCompleted: {
                            if (metadataModel.queryProvider.extraParameters[root.category] == resource) {
                                root.currentItem = itemDelegate
                            }
                        }
                    }
                }
            }
        }
    }
}
