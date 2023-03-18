/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.bluezqt as BluezQt

import "../../dataproviders" as DataProviders

PlasmaCore.IconItem {
    id: connectionIcon
    
    readonly property var provider: DataProviders.BluetoothInfo {}

    source: provider.icon
    colorGroup: PlasmaCore.ColorScope.colorGroup

    visible: provider.isVisible

    Layout.fillHeight: true
    Layout.preferredWidth: height
}
