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

AppletConfiguration {
    id: root
    isContainment: true
    loadApp: true

    readonly property bool horizontal: root.width > root.height

    onAppLoaded: {
        app.width = root.width < root.height ? root.width : Math.min(root.width, Math.max(app.implicitWidth, Kirigami.Units.gridUnit * 45));
        app.height = Math.min(root.height, Math.max(app.implicitHeight, Kirigami.Units.gridUnit * 29));
    }

//BEGIN model
    globalConfigModel: globalContainmentConfigModel

    ConfigModel {
        id: globalContainmentConfigModel
        ConfigCategory {
            name: i18nd("plasma_shell_org.kde.plasma.desktop", "Wallpaper")
            icon: "preferences-desktop-wallpaper"
            source: "ConfigurationContainmentAppearance.qml"
        }
    }
//END model
}
