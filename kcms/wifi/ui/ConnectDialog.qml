/*
    SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/
import QtQuick 2.6
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2 as Controls
import Qt5Compat.GraphicalEffects
import org.kde.kirigami 2.12 as Kirigami

Controls.Dialog {
    id: dialogRoot
    property int securityType
    property string headingText
    property string devicePath
    property string specificPath
    
    signal donePressed(string password)
    
    function openAndClear() {
        warning.visible = false;
        this.open();
        passwordField.text = "";
        passwordField.focus = true;
    }
    
    anchors.centerIn: parent
    modal: true
    standardButtons: Controls.Dialog.Ok | Controls.Dialog.Cancel
    
    onOpened: passwordField.forceActiveFocus()
    onRejected: {
        dialogRoot.close();
        passwordField.focus = false;
    }
    onAccepted: {
        if (passwordField.acceptableInput) {
            dialogRoot.close();
            handler.addAndActivateConnection(devicePath, specificPath, passwordField.text);
        } else {
            warning.visible = true;
        }
        passwordField.focus = false;
    }
    
    property int translateY: (1 - opacity) * Kirigami.Units.gridUnit * 2
    
    NumberAnimation on opacity {
        to: 1
        from: 0
        duration: Kirigami.Units.veryShortDuration
        easing.type: Easing.InOutQuad
        running: true
    }
    
    background: Item {
        transform: Translate { y: dialogRoot.translateY }
        
        RectangularGlow {
            anchors.fill: rect
            anchors.topMargin: 1
            cornerRadius: rect.radius * 2
            glowRadius: 2
            spread: 0.2
            color: Qt.rgba(0, 0, 0, 0.3)
        }
        Rectangle {
            id: rect
            anchors.fill: parent
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Window
            color: Kirigami.Theme.backgroundColor
            radius: Kirigami.Units.smallSpacing
            
            Kirigami.Separator {
                id: topSeparator
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: dialogRoot.header.implicitHeight
            }
            
            Kirigami.Separator {
                id: bottomSeparator
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: dialogRoot.footer.implicitHeight
            }
            
            Rectangle {
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.View
                color: Kirigami.Theme.backgroundColor
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: topSeparator.bottom
                anchors.bottom: bottomSeparator.top
            }
        }
    }
    
    header: Item {
        transform: Translate { y: dialogRoot.translateY }
        implicitHeight: heading.implicitHeight + Kirigami.Units.gridUnit * 2

        Kirigami.Heading {
            id: heading
            level: 2
            text: headingText
            wrapMode: Text.WordWrap
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Kirigami.Units.gridUnit
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    
    footer.transform: Translate { y: dialogRoot.translateY }
    
    ColumnLayout {
        id: column
        transform: Translate { y: dialogRoot.translateY }
        spacing: Kirigami.Units.gridUnit
        
        PasswordField {
            id: passwordField
            Layout.fillWidth: true
            securityType: dialogRoot.securityType
            onAccepted: dialogRoot.accept()
        }
        
        Controls.Label {
            id: warning
            text: i18n("Invalid input.")
            visible: false
        }
    }
    
}
