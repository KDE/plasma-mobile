/***************************************************************************
 *                                                                         *
 *   Copyright 2011,2012 Sebastian Kügler <sebas@kde.org>                  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0
import org.kde.active.settings 2.0 as ActiveSettings

Rectangle {
    id: rootItem

    width: 800
    height: 600

    color: theme.backgroundColor

    Image {
        source: "image://appbackgrounds/standard"
        fillMode: Image.Tile
        asynchronous: true
        anchors.margins: 8
        anchors.fill: parent

        Item {
            id: settingsRoot
            objectName: "settingsRoot"
            state: "expanded"
            anchors.fill: parent

            signal loadPlugin(string module);

            Image {
                id: modulesList
                source: "image://appbackgrounds/contextarea"
                fillMode: Image.Tile
                z: 800

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                width: parent.width/4

                Image {
                    source: "image://appbackgrounds/shadow-left"
                    fillMode: Image.Tile
                    anchors {
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                        rightMargin: -1
                    }
                }

                Component {
                    id: settingsModuleDelegate
                    PlasmaComponents.ListItem {
                        id: delegateItem
                        height: 64
                        width: parent ? parent.width : 100
                        anchors.margins: 20
                        enabled: true
                        checked: listView.currentIndex == index

                        PlasmaCore.IconItem {
                            id: iconItem
                            width: 48
                            height: 32
                            source: iconName
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.rightMargin: 8
                        }

                        PlasmaExtras.Heading {
                            id: textItem
                            text: name
                            level: 4
                            elide: Text.ElideRight
                            anchors.bottom: parent.verticalCenter
                            anchors.left: iconItem.right
                            anchors.right: parent.right
                        }

                        PlasmaComponents.Label {
                            id: descriptionItem
                            text: description
                            font.pointSize: theme.defaultFont.pointSize -1
                            opacity: 0.6
                            elide: Text.ElideRight
                            anchors.top: parent.verticalCenter
                            anchors.left: iconItem.right
                            anchors.right: parent.right
                        }

                        onClicked: {
                            listView.currentIndex = index
                            settingsItem.module = module
                        }

                        onPressAndHold: {
                            listView.currentIndex = index
                            settingsItem.module = module
                        }
                    }
                }

                ActiveSettings.SettingsModulesModel {
                    id: settingsModulesModel
                    onSettingsModulesChanged: {
                        // when the modules are loaded, we need to ensure that
                        // the list has the correct item loaded
                        var module;
                        if (settingsItem.module) {
                            module = settingsItem.module
                        } else if (typeof(startModule) != "undefined") {
                            module = startModule
                        }

                        if (module) {
                            var index = 0;
                            var numModules = settingsModules.length
                            var i = 0
                            while (i < numModules) {
                                if (settingsModules[i].module == module) {
                                    listView.currentIndex = i;
                                    break
                                }
                                ++i
                            }
                        }
                    }
                }

                ListView {
                    id: listView
                    currentIndex: -1
                    anchors.fill: parent
                    clip: true
                    interactive: false
                    model: settingsModulesModel.settingsModules
                    delegate: settingsModuleDelegate
                }
            }

            Component {
                id: initial_page
                Item {
                    visible: startModule == ""
                    anchors { fill: parent; margins: 80; }
                    PlasmaCore.IconItem {
                        source: "preferences-desktop"
                        anchors { top: parent.top; right: parent.right; }
                        opacity: 0.1
                        width: 256
                        height: width
                    }
                }
            }

            ActiveSettings.SettingsItem {
                id: settingsItem
                initialPage: initial_page
                anchors {
                    margins: 20
                    top: parent.top
                    bottom: parent.bottom
                    left: modulesList.right
                    right: parent.right
                }
            }
        }

        Component.onCompleted: {
            print("ActiveSettings Completed.");
            if (typeof(startModule) != "undefined") {
                settingsItem.module = startModule;
            }
        }
    }
}