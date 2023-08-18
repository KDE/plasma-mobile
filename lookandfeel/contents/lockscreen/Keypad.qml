// SPDX-FileCopyrightText: 2020-2023 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.workspace.keyboardlayout 1.0
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import org.kde.kirigami 2.12 as Kirigami

Rectangle {
    id: keypadRoot
    
    required property var lockScreenState
    
    property alias passwordBar: passwordBar
    
    // 0 - keypad is not shown, 1 - keypad is shown
    property double swipeProgress
    
    // slightly translucent background, for key contrast
    color: Kirigami.ColorUtils.adjustColor(Kirigami.Theme.backgroundColor, {"alpha": 0.9*255})
    
    // colour calculations
    readonly property color buttonColor: Qt.lighter(Kirigami.Theme.backgroundColor, 1.3)
    readonly property color buttonPressedColor: Qt.darker(Kirigami.Theme.backgroundColor, 1.08)
    readonly property color buttonTextColor: Kirigami.Theme.textColor
    readonly property color dropShadowColor: Qt.darker(Kirigami.Theme.backgroundColor, 1.2)
    readonly property color headerBackgroundColor: Qt.lighter(Kirigami.Theme.backgroundColor, 1.3)
    
    opacity: Math.sin((Math.PI / 2) * swipeProgress + 1.5 * Math.PI) + 1
    
    implicitHeight: {
        if (passwordBar.isPinMode && !Qt.inputMethod.visible) {
            return Kirigami.Units.gridUnit * 17;
        } else {
            return Math.min(root.height - passwordBar.implicitHeight, // don't make the password bar go off the screen
                            Kirigami.Units.smallSpacing * 2 + Qt.inputMethod.keyboardRectangle.height + passwordBar.implicitHeight);
        }
    }
    
    Behavior on implicitHeight {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    MobileShell.HapticsEffectLoader {
        id: haptics
    }

    // pin display and bar
    PasswordBar {
        id: passwordBar
        
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        
        color: keypadRoot.headerBackgroundColor
        opacity: (Math.sin(2*((Math.PI / 2) * keypadRoot.swipeProgress + 1.5 * Math.PI)) + 1)

        lockScreenState: keypadRoot.lockScreenState
        
        keypadOpen: swipeProgress === 1
        previewCharIndex: -2

        layer.enabled: true
        layer.effect: MultiEffect {
            blurMax: 16
            shadowEnabled: true
            shadowVerticalOffset: 1
            shadowOpacity: 0.3
            shadowColor: keypadRoot.dropShadowColor
        }
    }
    
    // actual number keys
    ColumnLayout {
        visible: opacity > 0
        opacity: passwordBar.isPinMode ? 1 : 0
        
        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        
        anchors {
            left: parent.left
            right: parent.right
            top: passwordBar.bottom
            bottom: parent.bottom
            topMargin: Kirigami.Units.gridUnit
            bottomMargin: Kirigami.Units.gridUnit
        }
        spacing: Kirigami.Units.gridUnit

        GridLayout {
            id: grid
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.leftMargin: Kirigami.Units.gridUnit * 0.5
            Layout.rightMargin: Kirigami.Units.gridUnit * 0.5
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            Layout.maximumHeight: Kirigami.Units.gridUnit * 12.5
            opacity: (Math.sin(2*((Math.PI / 2) * keypadRoot.swipeProgress + 1.5 * Math.PI)) + 1)
            
            columns: 4
            
            readonly property real keyRadius: 5
            
            // numpad keys
            Repeater {
                model: ["1", "2", "3", "R", "4", "5", "6", "0", "7", "8", "9", "E"]

                delegate: AbstractButton {
                    id: button
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: modelData.length > 0
                    opacity: (Math.sin(2*((Math.PI / 2) * keypadRoot.swipeProgress + 1.5 * Math.PI)) + 1)

                    background: Rectangle {
                        id: keyRect
                        radius: grid.keyRadius
                        color: button.pressed ? keypadRoot.buttonPressedColor : keypadRoot.buttonColor
                    }

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurMax: 16
                        shadowEnabled: true
                        shadowVerticalOffset: 1
                        shadowOpacity: 0.3
                        shadowColor: button.pressed ? keypadRoot.buttonPressedColor : keypadRoot.dropShadowColor
                    }

                    onPressedChanged: {
                        if (pressed) {
                            haptics.buttonVibrate();
                        }
                    }

                    onClicked: {
                        if (modelData === "R") {
                            passwordBar.backspace();
                        } else if (modelData === "E") {
                            passwordBar.enter();
                        } else {
                            passwordBar.keyPress(modelData);
                        }
                    }
                    onPressAndHold: {
                        if (modelData === "R") {
                            haptics.buttonVibrate();
                            passwordBar.clear();
                        }
                    }
                    
                    contentItem: Item {
                        PlasmaComponents.Label {
                            visible: modelData !== "R" && modelData !== "E"
                            text: modelData
                            anchors.centerIn: parent
                            font.pointSize: 18
                            font.weight: Font.Light
                            color: keypadRoot.buttonTextColor
                        }

                        Kirigami.Icon {
                            visible: modelData === "R"
                            anchors.centerIn: parent
                            source: "edit-clear"
                        }

                        Kirigami.Icon {
                            visible: modelData === "E"
                            anchors.centerIn: parent
                            source: "go-next"
                        }
                    }
                }
            }
        }
    }
}
