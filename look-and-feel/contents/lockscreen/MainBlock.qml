/********************************************************************
 This file is part of the KDE project.

Copyright (C) 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*********************************************************************/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.workspace.keyboardlayout 1.0
import "../components"

PlasmaCore.ColorScope {
    id: block
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    anchors.fill: parent

    Item {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        height: infoPane.height + units.largeSpacing * 2

        Rectangle {
            anchors.fill: parent
            color: PlasmaCore.ColorScope.backgroundColor
            opacity: 0.8
        }
        InfoPane {
            id: infoPane
            anchors.centerIn: parent
        }
    }

    Item {
        height: mainLayout.height + units.largeSpacing * 2
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        Rectangle {
            anchors.fill: parent
            color: PlasmaCore.ColorScope.backgroundColor
            opacity: 0.8
        }
        function unlockFunction() {
            authenticator.tryUnlock(passwordInput.text);
        }

        ColumnLayout {
            id: mainLayout
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            spacing: units.largeSpacing
            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter


                PlasmaComponents.TextField {
                    id: passwordInput
                    placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Password")
                    echoMode: TextInput.Password
                    enabled: !authenticator.graceLocked
                    onAccepted: actionButton.clicked(null)
                    focus: false

                    onVisibleChanged: {
                        if (visible) {
                            forceActiveFocus();
                        }
                        text = "";
                    }
                    onTextChanged: {
                        if (text == "") {
                            clearTimer.stop();
                        } else {
                            clearTimer.restart();
                        }
                    }

                    Timer {
                        id: clearTimer
                        interval: 30000
                        repeat: false
                        onTriggered: {
                            passwordInput.text = "";
                        }
                    }
                }

                DialerIconButton { 
                    source: "edit-clear"
                    callback: function() {
                        if (passwordInput.text.length > 0) {
                            passwordInput.text = passwordInput.text.substr(0, passwordInput.text.length - 1);
                        }
                    }
                }

                Connections {
                    target: root
                    onClearPassword: {
                        passwordInput.selectAll();
                        passwordInput.forceActiveFocus();
                    }
                }
            }
            Dialer {
                id: dialer
                Layout.fillWidth: true
            }
            PlasmaComponents.Button {
                id: actionButton
                Layout.alignment: Qt.AlignHCenter
                Layout.minimumWidth: passwordInput.width
                text: i18n("Unlock")
                enabled: !authenticator.graceLocked
                onClicked: {
                    unlockFunction();
                }
            }
        }
    }
}
