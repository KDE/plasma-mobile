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
    objectName: "settingsRoot"
    id: mainItem
    state: "expanded"


    PlasmaCore.Theme {
        id: theme
    }

    PlasmaCore.FrameSvgItem {
        id: frame

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 300

        imagePath: "widgets/frame"
        prefix: "raised"

        Component {
            id: myDelegate
            Item {
                id: delegateItem
                height: 64
                width: 300
                //anchors.fill: parent
                anchors.margins: 20

                QIconItem {
                    id: iconItem
                    width: 48
                    height: 32
                    icon: QIcon(iconName)
                    //anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.rightMargin: 8
                    //image: preview
                }

                Text {
                    height: 32
                    id: textItem
                    text: "<strong>" + name + "</strong> <br />" + description
                    color: theme.textColor
                    anchors.left: iconItem.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.leftMargin: 20
                }

                MouseArea {
                    anchors.fill: delegateItem
                    onClicked: {
                        print("module from completer chosen: " + name + " " + description + " : " + module);
                        loadModule(module);
                        //urlEntered(url);
                    }
                }
            }
        }

        ListView {
            anchors {
                fill: parent
                leftMargin: frame.margins.left
                rightMargin: frame.margins.right
                topMargin: frame.margins.top
                bottomMargin: frame.margins.bottom
            }
            y: 16
            spacing: 4
            clip: true
            model: settingsModulesModel
            
            delegate: myDelegate
            highlight: Rectangle { color: theme.textColor; opacity: 0.3 }
        }
    }

    Loader {
        id: moduleContainer
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: frame.right
        anchors.right: parent.right
    }

    MobileComponents.Package {
        id: switcherPackage
        name: "org.kde.active.settings.time"
        Component.onCompleted: {
            loadModule(name);
        }

    }

    function loadModule(module) {
        switcherPackage.name = module
        print(" Creating package thing: " + switcherPackage.filePath("mainscript"));
        moduleContainer.source = switcherPackage.filePath("mainscript");
        /*
        if (typeof(mainItem.moduleItem) != "undefined") {
            mainItem.moduleItem.destroy();
        }
        var component = Qt.createComponent(switcherPackage.filePath("mainscript"));
        component.createObject(mainItem, {"anchors.fill": moduleContainer, id: "moduleItem"});
        mainItem.state = "expanded"
        */
    }


    states: [
        State {
            id: expanded
            name: "expanded";
            PropertyChanges {
                target: mainItem
                opacity: 1
            }
        },

        State {
            id: collapsed
            name: "collapsed";
            PropertyChanges {
                target: mainItem
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