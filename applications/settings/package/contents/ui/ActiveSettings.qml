/***************************************************************************
 *                                                                         *
 *   Copyright 2011-2014 Sebastian Kügler <sebas@kde.org>                  *
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
    state: "navigation"

    property bool loading: false
    property bool compactMode: width < units.gridUnit * 30

    onCompactModeChanged: {
        if (!compactMode) {
            appBackground.x = 0;
        }
    }


    Image {
        id: appBackground
        source: "image://appbackgrounds/standard"
        fillMode: Image.Tile
        asynchronous: true
        anchors {
            top: parent.top
            bottom: toolBar.top
        }
        width: rootItem.compactMode ? rootItem.width * 2 : rootItem.width
        Behavior on x {
            enabled: rootItem.compactMode
            PropertyAnimation {
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

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
                width: rootItem.compactMode ? rootItem.width : Math.min(units.gridUnit * 15, parent.width/3)

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

                ModulesList {
                    anchors.fill: parent
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

            ModuleItem {
                id: settingsItem

                anchors {
                    margins: 20
                    top: parent.top
                    bottom: parent.bottom
                    left: modulesList.right
                    right: parent.right
                }
                onModuleChanged: {
                    if (rootItem.compactMode) {
                        appBackground.x = - rootItem.width
                    }
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
    PlasmaComponents.ToolBar {
        id: toolBar
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        visible: rootItem.compactMode
        enabled: appBackground.x < 0
        tools: Row {
            PlasmaComponents.ToolButton {
                iconSource: "go-previous"
                onClicked: {
                    appBackground.x = 0;
                    listView.currentIndex = -1
                }
            }
        }
    }
}