/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kirigami 2.20 as Kirigami

PlasmaCore.IconItem {
    id: connectionIcon
    
    // data
    
    readonly property string icon: connectionIconProvider.connectionIcon
    readonly property bool indicatorRunning: connectionIconProvider.connecting
    
    readonly property var networkStatus: PlasmaNM.NetworkStatus {
        id: networkStatus
    }

    readonly property var networkModel: PlasmaNM.NetworkModel {
        id: connectionModel
    }

    readonly property var handler: PlasmaNM.Handler {
        id: handler
    }

    readonly property var connectionIcon: PlasmaNM.ConnectionIcon {
        id: connectionIconProvider
    }
    
    // implementation
    
    source: icon
    colorSet: Kirigami.Theme.colorSet

    PlasmaComponents.BusyIndicator {
        id: connectingIndicator

        anchors.fill: parent
        running: connectionIcon.indicatorRunning
        visible: running
    }
}
