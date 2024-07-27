// SPDX-FileCopyrightText: 2020-2024 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.6
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami as Kirigami

Kirigami.PromptDialog {
    id: dialogRoot
    title: headingText

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

    ColumnLayout {
        id: column
        spacing: Kirigami.Units.largeSpacing

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
