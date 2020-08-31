/*
Copyright (C) 2020 Devin Lin <espidev@gmail.com>

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

Rectangle {
    color: Qt.rgba(250, 250, 250, 0.85) // slightly translucent background, for key contrast
    property string pinLabel: qsTr("Enter PIN")
    
    // for displaying temporary number in pin dot display
    property string lastKeyPressValue: "0"
    property int indexWithNumber: -2
    
    // keypad functions
    function backspace() {
        lastKeyPressValue = "0";
        indexWithNumber = -2;
        root.password = root.password.substr(0, root.password.length - 1);
    }
    
    function enter() {
        authenticator.tryUnlock(root.password);
    }
    
    function keyPress(data) {
        if (keypad.pinLabel !== qsTr("Enter PIN")) {
            keypad.pinLabel = qsTr("Enter PIN");
        }
        lastKeyPressValue = data;
        indexWithNumber = root.password.length;
        root.password += data
        
        // trigger turning letter into dot later
        letterTimer.restart();
    }
    
    Connections {
        target: authenticator
        function onFailed() {
            root.password = "";
            pinLabel = qsTr("Wrong PIN")
        }
    }
    
    // listen for keyboard events
    Keys.onPressed: {
        if (event.modifiers === Qt.NoModifier) {
            if (event.key === Qt.Key_Backspace) {
                backspace();
            } else if (event.key === Qt.Key_Return) {
                enter();
            } else if (event.text != "") {
                keyPress(event.text);
            }
        }
    }
    
    // trigger turning letter into dot after 500 milliseconds
    Timer {
        id: letterTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            lastKeyPressValue = 0;
            indexWithNumber = -2;
        }
    }
    
    ColumnLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            topMargin: units.gridUnit
            bottomMargin: units.gridUnit
        }
        spacing: units.gridUnit
        
        // pin dot display
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.minimumHeight: units.gridUnit * 0.5
            Layout.maximumWidth: parent.width
            
            Label {
                visible: root.password.length === 0
                anchors.centerIn: parent
                text: pinLabel
                font.pointSize: 12
                color: "#616161"
            }
            RowLayout {
                id: dotDisplay
                anchors.centerIn: parent
                height: units.gridUnit // maintain height when letter is shown
                spacing: 6
                
                Repeater {
                    model: root.password.length
                    delegate: Rectangle { // dot
                        visible: index !== indexWithNumber // hide dot if number is shown
                        Layout.preferredWidth: units.gridUnit * 0.25
                        Layout.preferredHeight: Layout.preferredWidth
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        radius: width
                        color: "#424242"
                    }
                }
                Label { // number/letter
                    visible: root.password.length-1 === indexWithNumber // hide label if no label needed
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    color: "#424242"
                    text: lastKeyPressValue
                    font.pointSize: 10
                }
            }
        }
        
        // separator
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#eeeeee"
        }
        
        // number keys
        GridLayout {
            property string thePw
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.leftMargin: units.gridUnit * 0.5
            Layout.rightMargin: units.gridUnit * 0.5
            Layout.maximumWidth: units.gridUnit * 22
            Layout.maximumHeight: units.gridUnit * 12.5
            columns: 4
            
            // numpad keys
            Repeater {
                model: ["1", "2", "3", "R", "4", "5", "6", "0", "7", "8", "9", "E"]
                
                delegate: Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    Rectangle {
                        id: keyRect
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        radius: 5
                        color: "white"
                        visible: modelData.length > 0

                        MouseArea {
                            anchors.fill: parent
                            onPressed: parent.color = "#e0e0e0"
                            onReleased: parent.color = "white"
                            onClicked: {
                                if (modelData === "R") {
                                    backspace();
                                } else if (modelData === "E") {
                                    enter();
                                } else {
                                    keyPress(modelData);
                                }
                            }
                        }
                    }
                    
                    DropShadow {
                        anchors.fill: keyRect
                        source: keyRect
                        cached: true
                        horizontalOffset: 0
                        verticalOffset: 1
                        radius: 4
                        samples: 6
                        color: "#e0e0e0"
                    }

                    PlasmaComponents.Label {
                        visible: modelData !== "R" && modelData !== "E"
                        text: modelData
                        anchors.centerIn: parent
                        font.pointSize: 18
                        color: "#424242"
                    }

                    PlasmaCore.IconItem {
                        visible: modelData === "R"
                        anchors.centerIn: parent
//                         colorGroup: PlasmaCore.ColorScope.backgroundColor
                        source: "edit-clear"
                    }

                    PlasmaCore.IconItem {
                        visible: modelData === "E"
                        anchors.centerIn: parent
//                         colorGroup: PlasmaCore.ColorScope.backgroundColor
                        source: "go-next"
                    }
                }
            }
        }
    }
}
