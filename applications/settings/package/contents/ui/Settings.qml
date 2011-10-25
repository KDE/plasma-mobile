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
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.qtextracomponents 0.1

Item {
    width: 100
    height: 360
    id: rootItem
    anchors.margins: 8

    PlasmaCore.Theme {
        id: theme
    }

    PlasmaCore.FrameSvgItem {
        imagePath: "widgets/frame"
        prefix: "raised"
        id: settingsRoot
        objectName: "settingsRoot"
        state: "expanded"
        anchors.fill: parent

        signal loadPlugin(string module);

        Item {
            id: modulesList

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 360

            Component {
                id: myDelegate
                Item {
                    id: delegateItem
                    height: 64
                    width: 340
                    //anchors.fill: parent
                    anchors.margins: 20


                    QIconItem {
                        id: iconItem
                        width: 48
                        height: 32
                        icon: QIcon(iconName)
                        anchors.verticalCenter: parent.verticalCenter
                        //anchors.top: parent.top
                        //anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.rightMargin: 8
                        //image: preview
                    }

                    Text {
                        height: 32
                        id: textItem
                        text: "<strong>" + name + "</strong> <br />" + description
                        //./applets/org.kde.active.connman/contents/ui/WifiExpandingBox.qml:474:
                        //font.pixelSize: theme.fontPixelSizeNormal
                        elide: Text.ElideRight
                        color: theme.textColor
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: iconItem.right
                        //anchors.top: parent.top
                        //anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        //anchors.leftMargin: 20
                    }

                    MouseArea {
                        anchors.fill: delegateItem
                        onClicked: {
                            listView.currentIndex = index
                            loadPackage(module);
                        }
                    }
                }
            }

            ListView {
                id: listView
                currentIndex: -1
                anchors {
                    fill: parent
                    leftMargin: settingsRoot.margins.left
                    rightMargin: settingsRoot.margins.right
                    topMargin: settingsRoot.margins.top
                    bottomMargin: settingsRoot.margins.bottom
                }
                y: 16
                spacing: 4
                clip: true
                model: settingsModulesModel
                delegate: myDelegate
                //highlight: Rectangle { color: theme.textColor; opacity: 0.3 }
                highlight: PlasmaCore.FrameSvgItem {
                    id: highlightFrame
                    imagePath: "widgets/viewitem"
                    prefix: "selected+hover"
                }

            }
        }

        Loader {
            id: moduleContainer
            objectName: "moduleContainer"
            anchors.margins: 20
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: modulesList.right
            anchors.right: parent.right
        }

        Component.onCompleted: {
            print(" Loading Settings.qml done." + settingsRoot);
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

    MobileComponents.Package {
        id: switcherPackage
        //name: "org.kde.active.settings.time"
        Component.onCompleted: {
            //loadPackage("org.kde.active.settings.time");
        }

    }

    function loadPackage(module) {
        // Load the C++ plugin into our context
        settingsRoot.loadPlugin(module);
        switcherPackage.name = module
        //print(" Loading package: " + switcherPackage.filePath("mainscript"));
        moduleContainer.source = switcherPackage.filePath("mainscript");
    }


}
