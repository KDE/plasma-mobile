/*
Copyright (C) 2019 Nicolas Fella <nicolas.fella@gmx.de>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.12
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.12
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.workspace.keyboardlayout 1.0
import "../components"

PlasmaCore.ColorScope {
    id: root

    property string password

    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    anchors.fill: parent
    
    BrightnessContrast {
        id: darken
        anchors.fill: parent
        source: wallpaper
        brightness: -(passwordFlickable.contentY / passwordFlickable.columnHeight * 0.6)
    }

    DropShadow {
        id: clockShadow
        anchors.fill: clock
        source: clock
        horizontalOffset: 1
        verticalOffset: 1
        radius: 6
        samples: 14
        spread: 0.3
        color: PlasmaCore.ColorScope.backgroundColor
        
        // hide when keypad is shown
        opacity: 1 - (passwordFlickable.contentY / passwordFlickable.columnHeight)
    }

    Clock {
        id: clock

        property Item shadow: clockShadow

        anchors.leftMargin: units.gridUnit
        anchors.rightMargin: units.gridUnit
        anchors.topMargin: units.gridUnit * 3
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        opacity: 1 - (passwordFlickable.contentY / passwordFlickable.columnHeight)
    }
    
    // bottom of screen elements
    ColumnLayout {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottomMargin: units.gridUnit + passwordFlickable.contentY * 0.5
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 1 - (passwordFlickable.contentY / passwordFlickable.columnHeight)
        
        PlasmaCore.IconItem {
            Layout.alignment: Qt.AlignHCenter
            colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
            source: "arrow-up"
        }
        
        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Swipe up to unlock device")
        }
    }

    Flickable {
        id: passwordFlickable
        
        anchors.fill: parent
        
        property int columnHeight: units.gridUnit * 20
        
        height: columnHeight + root.height
        contentHeight: columnHeight + root.height
        boundsBehavior: Flickable.StopAtBounds
        
        // always snap to end (either hidden or shown)
        onFlickEnded: {
            if (!atYBeginning && !atYEnd) {
                if (contentY > columnHeight - contentY) {
                    flick(0, -1000);
                } else {
                    flick(0, 1000);
                }
            }
        }

        // wipe password if it is more than half way down the screen
        onContentYChanged: {
            if (contentY < columnHeight / 2)
                root.password = "";
        }
        
        ColumnLayout {
            id: passwordLayout
            anchors.bottom: parent.bottom
            
            width: parent.width
            spacing: units.gridUnit * 2
            opacity: Math.sin((Math.PI / 2) * (passwordFlickable.contentY / passwordFlickable.columnHeight) + 1.5 * Math.PI) + 1
            
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Enter PIN")
                font.pointSize: 12
            }
            
            Row {
                id: dotDisplay
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                Layout.minimumHeight: units.gridUnit
                Layout.maximumWidth: parent.width
                
                Repeater {
                    model: root.password.length
                    delegate: Rectangle {
                        width: units.gridUnit
                        height: width
                        radius: width
                        color: Qt.rgba(PlasmaCore.ColorScope.backgroundColor.r, PlasmaCore.ColorScope.backgroundColor.g, PlasmaCore.ColorScope.backgroundColor.b, 0.6)
                    }
                }
            }

            GridLayout {
                id: numBlock
                property string thePw

                Layout.fillWidth: true
                Layout.minimumHeight: units.gridUnit * 16
                Layout.maximumWidth: root.width
                Layout.bottomMargin: units.gridUnit * 2
                Layout.leftMargin: units.gridUnit * 2
                Layout.rightMargin: units.gridUnit * 2
                rowSpacing: units.gridUnit

                columns: 3

                Repeater {
                    model: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "R", "0", "E"]
                    delegate: Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Rectangle {
                            anchors.centerIn: parent
                            width: units.gridUnit * 3
                            height: width
                            radius: 12
                            color: Qt.rgba(PlasmaCore.ColorScope.backgroundColor.r, PlasmaCore.ColorScope.backgroundColor.g, PlasmaCore.ColorScope.backgroundColor.b, ma.pressed ? 0.8 : 0.3)
                            visible: modelData.length > 0

                            MouseArea {
                                id: ma
                                anchors.fill: parent
                                onClicked: {
                                    if (modelData === "R") {
                                        root.password = root.password.substr(0, root.password.length - 1);
                                    } else if (modelData === "E") {
                                        authenticator.tryUnlock(root.password);
                                    } else {
                                        root.password += modelData
                                    }
                                }
                            }
                        }

                        PlasmaComponents.Label {
                            visible: modelData !== "R" && modelData !== "E"
                            text: modelData
                            anchors.centerIn: parent
                            font.pointSize: 16
                        }

                        PlasmaCore.IconItem {
                            visible: modelData === "R"
                            anchors.centerIn: parent
                            colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                            source: "edit-clear"
                        }

                        PlasmaCore.IconItem {
                            visible: modelData === "E"
                            anchors.centerIn: parent
                            colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                            source: "go-next"
                        }
                    }
                }
            }
        }
    }
}
