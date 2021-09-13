/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.2
import QtQuick.Layouts 1.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.bluezqt 1.0 as BluezQt

import "providers"

PlasmaCore.IconItem {
    id: connectionIcon
    required property BluetoothProvider provider

    source: provider.icon;
    colorGroup: PlasmaCore.ColorScope.colorGroup

    visible: provider.isVisible

    Layout.fillHeight: true
    Layout.preferredWidth: height
}
