/*
 *   SPDX-FileCopyrightText: 2022 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15

import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import "../../components" as Components

// This is a test app to conveniently test the Quick Settings that are available
// on the system without having to load a full Plasma Mobile shell.
//
// Do not expect changes in this file to change the plasma UX. Do not install.
//
// This can be executed by running `qml QuickSettingsTest.qml`

GridView {
    model: MobileShell.QuickSettingsModel {}

    PlasmaComponents.Button {
        id: restrictedButton
        checkable: true
        text: "Restricted"
    }
    delegate: Components.BaseItem {
        required property var modelData

        implicitHeight: 150
        implicitWidth: 150
        horizontalPadding: (width - PlasmaCore.Units.gridUnit * 3) / 2
        verticalPadding: (height - PlasmaCore.Units.gridUnit * 3) / 2

        contentItem: QuickSettingsFullDelegate {
            restrictedPermissions: restrictedButton.checked

            text: modelData.text
            status: modelData.status
            icon: modelData.icon
            enabled: modelData.enabled
            settingsCommand: modelData.settingsCommand
            toggleFunction: modelData.toggle

            onCloseRequested: {
                actionDrawer.close();
            }
        }
    }
}
