// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls

import org.kde.kirigami 2.20 as Kirigami

Kirigami.PromptDialog {
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

    title: headingText
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
