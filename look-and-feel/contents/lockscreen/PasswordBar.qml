/*
SPDX-FileCopyrightText: 2020-2021 Devin Lin <espidev@gmail.com>

SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.12
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.12
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.workspace.keyboardlayout 1.0
import org.kde.kirigami 2.12 as Kirigami

Rectangle {
    id: root
    implicitHeight: units.gridUnit * 2.5
    
    // toggle between pin and password mode
    property bool isPinMode: true
    
    property string password
    property int previewCharIndex
    property string pinLabel
    property bool keypadOpen
    
    property color headerTextColor: Kirigami.ColorUtils.adjustColor(PlasmaCore.Theme.textColor, {"alpha": 0.75*255})
    property color headerTextInactiveColor: Kirigami.ColorUtils.adjustColor(PlasmaCore.Theme.textColor, {"alpha": 0.4*255})
    
    // we need to use a listmodel to avoid all delegates from reloading
    ListModel {
        id: dotDisplayModel
    }
    onPasswordChanged: {
        while (password.length < dotDisplayModel.count) {
            dotDisplayModel.remove(dotDisplayModel.count - 1);
        }
        while (password.length > dotDisplayModel.count) {
            dotDisplayModel.append({"char": password.charAt(dotDisplayModel.count)});
        }
    }
    
    // hidden textfield so that the virtual keyboard shows up
    TextField {
        visible: false
        id: textField
        focus: keypadOpen && !isPinMode
        z: 1
    }
    
    // toggle between showing keypad and not
    ToolButton {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: units.smallSpacing
        implicitWidth: height
        icon.name: "input-keyboard-virtual-symbolic"
        onClicked: root.isPinMode = !root.isPinMode
    }
    
    // label ("wrong pin", "enter pin")
    Label {
        opacity: password.length === 0 ? 1 : 0
        anchors.centerIn: parent
        text: root.pinLabel
        font.pointSize: 12
        color: root.headerTextColor 
        
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }
    
    // pin dot display
    ColumnLayout {
        anchors.fill: parent
        
        ListView {
            id: dotDisplay
            property int dotWidth: Math.round(units.gridUnit * 0.35)
            
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.bottomMargin: Math.round(dotWidth / 2)
            orientation: ListView.Horizontal
            implicitWidth: count * dotWidth + spacing * (count - 1)
            spacing: 8
            model: dotDisplayModel
            
            Behavior on implicitWidth {
                NumberAnimation { duration: 50 }
            }
            
            delegate: Item {
                implicitWidth: dotDisplay.dotWidth
                implicitHeight: dotDisplay.dotWidth
                property bool showChar: index === root.previewCharIndex
                
                Component.onCompleted: {
                    if (showChar) {
                        charAnimation.to = 1;
                        charAnimation.duration = 75;
                        charAnimation.restart();
                    } else {
                        dotAnimation.to = 1;
                        dotAnimation.restart();
                    }
                }
                
                onShowCharChanged: {
                    if (!showChar) {
                        charAnimation.to = 0;
                        charAnimation.duration = 50;
                        charAnimation.restart();
                        dotAnimation.to = 1;
                        dotAnimation.start();
                    }
                }
                
                Rectangle { // dot
                    id: dot
                    scale: 0
                    anchors.fill: parent
                    radius: width
                    color: keypadRoot.waitingForAuth ? root.headerTextInactiveColor : root.headerTextColor // dim when waiting for auth
                    
                    PropertyAnimation {
                        id: dotAnimation
                        target: dot;
                        property: "scale";
                        duration: 50
                    }
                }
                
                Label { // number/letter
                    id: charLabel
                    scale: 0
                    anchors.centerIn: parent
                    color: keypadRoot.waitingForAuth ? root.headerTextInactiveColor : root.headerTextColor // dim when waiting for auth
                    text: model.char
                    font.pointSize: 12
                    
                    PropertyAnimation {
                        id: charAnimation
                        target: charLabel;
                        property: "scale";
                    }
                }
            }
        }
    }
}
