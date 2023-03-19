// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import org.kde.plasma.core as PlasmaCore

pragma Singleton

QtObject {
    readonly property real topPanelHeight: PlasmaCore.Units.gridUnit + PlasmaCore.Units.smallSpacing
}
