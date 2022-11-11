/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.6
import QtQuick.Layouts 1.4

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.workspace.components 2.0 as PW

Item {
    property bool isVisible: pmSource.data["Battery"]["Has Cumulative"]
    property int percent: pmSource.data["Battery"]["Percent"]
    property bool pluggedIn: pmSource.data["AC Adapter"] ? pmSource.data["AC Adapter"]["Plugged in"] : false
    
    property PlasmaCore.DataSource pmSource: PlasmaCore.DataSource {
        engine: "powermanagement"
        connectedSources: ["Battery", "AC Adapter"]
    }
}
