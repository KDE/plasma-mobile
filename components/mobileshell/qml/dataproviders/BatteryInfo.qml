/*
 *  SPDX-FileCopyrightText: 2024 Sebastian Kügler <sebas@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

pragma Singleton

import QtQuick

import org.kde.plasma.private.battery

Item {

    BatteryControlModel {
        id: batteryControl
    }

    property bool isVisible: batteryControl.hasInternalBatteries
    property int percent: batteryControl.percent
    property bool pluggedIn: batteryControl.pluggedIn
    property alias batteries: batteryControl
}
