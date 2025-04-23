// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma Singleton

import QtQuick

import org.kde.plasma.networkmanagement as PlasmaNM

QtObject {
    // Initialization of PlasmaNM.Handler is quite heavy, initialize it once for the shell as a singleton.
    readonly property PlasmaNM.Handler handler: PlasmaNM.Handler {}

    readonly property PlasmaNM.WirelessStatus wirelessStatus: PlasmaNM.WirelessStatus {}
}