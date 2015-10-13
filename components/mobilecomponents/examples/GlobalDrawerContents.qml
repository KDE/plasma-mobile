/*
 *   Copyright 2012 Marco Martin <mart@kde.org>
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

import QtQuick 2.1
import QtQuick.Controls 1.0 as QtControls
import QtQuick.Layouts 1.3
import QtQml.Models 2.2
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons  2.0

Item {
    implicitWidth: units.gridUnit * 12
    ColumnLayout {
        id: mainColumn
        anchors.fill: parent

        RowLayout {
            //Layout.fillWidth: true
            anchors {
                left: parent.left
                margins: units.largeSpacing
            }
            PlasmaCore.IconItem {
                height: parent.height
                width: height
                source: "akregator"
            }
            PlasmaExtras.Heading {
                level: 1
                text: "Akregator"
            }
        }

        PlasmaExtras.PageRow {
            id: pageRow
            Layout.fillWidth: true
            Layout.fillHeight: true
            initialPage: menuComponent
        }

        Component {
            id: menuComponent
            ListView {
                id: optionMenu

                model: root.globalActions
                property int level: 0

                footer: PlasmaComponents.ListItem {
                    visible: level > 0
                    enabled: true
                    RowLayout {
                        anchors {
                            left: parent.left
                        }
                        PlasmaCore.IconItem {
                            Layout.maximumWidth: height
                            Layout.fillHeight: true
                            source: "go-previous"
                        }
                        PlasmaComponents.Label {
                            text: i18n("Back")
                        }
                    }
                    onClicked: pageRow.scrollToLevel(level - 1)
                }
                delegate: PlasmaComponents.ListItem {
                    enabled: true
                    RowLayout {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        PlasmaCore.IconItem {
                            Layout.maximumWidth: height
                            Layout.fillHeight: true
                            source: modelData.iconName
                        }
                        PlasmaComponents.Label {
                            Layout.fillWidth: true
                            text: modelData.text
                        }
                        PlasmaCore.IconItem {
                            Layout.maximumWidth: height
                            Layout.fillHeight: true
                            source: "go-next"
                            visible: modelData.children != undefined
                        }
                    }
                    onClicked: {
                        if (modelData.children) {
                            pageRow.pop(optionMenu)
                            pageRow.push(menuComponent, {"model": modelData.children, "level": level + 1})
                        } else {
                            modelData.trigger()
                        }
                    }
                }
            }
        }
    }
}

