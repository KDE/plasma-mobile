/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

pragma Singleton

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.workspace.components as PW

QtObject {
    property bool isVisible: pmSource.data["Battery"]["Has Cumulative"]
    property int percent: pmSource.data["Battery"]["Percent"]
    property bool pluggedIn: pmSource.data["AC Adapter"] ? pmSource.data["AC Adapter"]["Plugged in"] : false

    property P5Support.DataSource pmSource: P5Support.DataSource {
        engine: "powermanagement"
        connectedSources: ["Battery", "AC Adapter"]
    }
}
