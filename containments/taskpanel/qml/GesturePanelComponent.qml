// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.plasmoid

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

MobileShell.GesturePanel {
    id: root

    onHandlePressedAndHeld: MobileShellState.ShellDBusClient.openHomeScreen()
    onHandleClicked: Plasmoid.triggerTaskSwitcher()
}
