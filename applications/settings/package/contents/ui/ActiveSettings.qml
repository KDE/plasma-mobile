/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
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

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.qtextracomponents 0.1
import org.kde.active.settings 0.1 as ActiveSettings

Image {
    id: rootItem
    source: "image://appbackgrounds/standard"
    fillMode: Image.Tile
    asynchronous: true
    width: 100
    height: 360
    anchors.margins: 8

    PlasmaCore.Theme {
        id: theme
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
            width: 360

            Image {
                source: "image://appbackgrounds/shadow-right"
                fillMode: Image.Tile
                anchors {
                    left: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    leftMargin: -1
                }
            }

            Component {
                id: settingsModuleDelegate
                Item {
                    id: delegateItem
                    height: 64
                    width: 340
                    anchors.margins: 20

                    QIconItem {
                        id: iconItem
                        width: 48
                        height: 32
                        icon: QIcon(iconName)
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.rightMargin: 8
                    }

                    Text {
                        id: textItem
                        text: name
                        elide: Text.ElideRight
                        color: theme.textColor
                        anchors.bottom: parent.verticalCenter
                        anchors.left: iconItem.right
                        anchors.right: parent.right
                    }

                    Text {
                        id: descriptionItem
                        text: description
                        opacity: 0.6
                        elide: Text.ElideRight
                        color: theme.textColor
                        anchors.top: parent.verticalCenter
                        anchors.left: iconItem.right
                        anchors.right: parent.right
                    }

                    MouseArea {
                        anchors.fill: delegateItem
                        onPressed: MobileComponents.PressedAnimation { targetItem: delegateItem }
                        onReleased: MobileComponents.ReleasedAnimation { targetItem: delegateItem }
                        onClicked: {
                            //if (module != switcherPackage.name) {
                                listView.currentIndex = index
                                //settingsComponent.loadPackage(module);
                                settingsComponent.module = module;
                            //}
                        }
                    }
                    Component.onCompleted: {
                        // mark current module as selected in the list on the left
                        // FIXME: not sure why this doesn't work???
                        if (typeof(startModule) != "undefined" && module == startModule) {
                            listView.currentIndex = index;
                        }
                    }
                }
            }

            ActiveSettings.SettingsModulesModel {
                id: settingsModulesModel
                //parent: settingsRoot

                Component.onCompleted: {
                    //print(" EINS +++ "  + items.count );
                    //print(" ZWEI +++ "  + settingsModulesItems.count );
                    print(" Model completed.");
                }
            }

            ListView {
                id: listView
                currentIndex: -1
                anchors.fill: parent
                spacing: 4
                clip: true
                interactive: false
                model: settingsModulesModel.settingsModules
                delegate: settingsModuleDelegate
                highlight: PlasmaComponents.Highlight {}
            }
        }

        Component {
            id: initial_page
            Item {
                visible: startModule == ""
                anchors { fill: parent; margins: 80; }
                PlasmaComponents.Label {
                    id: initial_page_label
                    text: "<h1>Active Settings</h1>";
                    anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; }
                }
                QIconItem {
                    icon: QIcon("preferences-desktop")
                    anchors { top: initial_page_label.bottom; right: parent.right; }
                    opacity: 0.1
                    width: 256
                    height: width
                }
            }
        }

        PlasmaComponents.PageStack {
            id: moduleContainer
            objectName: "moduleContainer"
            clip: false
            initialPage: initial_page
            anchors.margins: 20
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: modulesList.right
            anchors.right: parent.right
        }

        states: [
            State {
                id: expanded
                name: "expanded";
                PropertyChanges {
                    target: settingsRoot
                    opacity: 1
                }
            },

            State {
                id: collapsed
                name: "collapsed";
                PropertyChanges {
                    target: settingsRoot
                    opacity: 0
                }
            }
        ]

        transitions: [
            Transition {
                PropertyAnimation {
                    properties: "opacity"
                    duration: 400;
                    easing.type: Easing.InOutElastic;
                    easing.amplitude: 2.0; easing.period: 1.5
                }
            }
        ]
    }

    ActiveSettings.SettingsComponent {
        id: settingsComponent

        onModuleChanged: {
            //print("mainscriptChanged:: " + mainScript);
            //moduleContainer.replace(mainScript);
            switcherPackage.name = module
            print(" Loading package: " + switcherPackage.filePath("mainscript"));
            moduleContainer.replace(switcherPackage.filePath("mainscript"));
        }
    }

    MobileComponents.Package {
        id: switcherPackage
    }
    /*

    function loadPackage(module) {
        // Load the C++ plugin into our context
        settingsRoot.loadPlugin(module);
        switcherPackage.name = module
        print(" Loading package: " + switcherPackage.filePath("mainscript"));
        moduleContainer.replace(switcherPackage.filePath("mainscript"));
    }

    Component.onCompleted: {
        if (typeof(startModule) != "undefined") {
            loadPackage(startModule);
        }
    }
    */
}
