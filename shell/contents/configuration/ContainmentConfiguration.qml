// SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2
import QtQuick.Controls 2.15 as Controls

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.configuration 2.0
import org.kde.ksvg 1.0 as KSvg

/**
 * This component is loaded by libplasma when the "configuration window" is requested for a containment.
 */
AppletConfiguration {
    id: root
    isContainment: true
    loadApp: true

//BEGIN model
    globalConfigModel: globalContainmentConfigModel

    ConfigModel {
        id: globalContainmentConfigModel
        ConfigCategory {
            name: i18n("Wallpaper")
            icon: "viewimage-symbolic"
            source: "ChangeWallpaperModule.qml" // This is a relative path from inside private (since loading is invoked from there)
        }
        ConfigCategory {
            name: i18n("Change Homescreen")
            icon: "exchange-positions"
            source: "ChangeContainmentModule.qml" // This is a relative path from inside private (since loading is invoked from there)
            visible: configDialog.containmentPluginsConfigModel.count > 1
        }
    }
//END model
}
