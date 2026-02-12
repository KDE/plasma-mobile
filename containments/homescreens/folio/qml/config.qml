// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.configuration 2.0

/**
 * Part of the applet/containment spec, config.qml defines the categories to show in the settings.
 */
ConfigModel {

    ConfigCategory {
         name: i18n("General")
         icon: "go-home-symbolic"
         source: "settings/ConfigGeneral.qml"
    }
}
