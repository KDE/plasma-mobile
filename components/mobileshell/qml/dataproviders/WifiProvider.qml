/*
    SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.2
import QtQuick.Layouts 1.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM

pragma Singleton

QtObject {
    property string icon: connectionIconProvider.connectionIcon
    property bool indicatorRunning: connectionIconProvider.connecting
    
    property var networkStatus: PlasmaNM.NetworkStatus {
        id: networkStatus
    }

    property var networkModel: PlasmaNM.NetworkModel {
        id: connectionModel
    }

    property var handler: PlasmaNM.Handler {
        id: handler
    }

    property var connectionIcon: PlasmaNM.ConnectionIcon {
        id: connectionIconProvider
    }
}

