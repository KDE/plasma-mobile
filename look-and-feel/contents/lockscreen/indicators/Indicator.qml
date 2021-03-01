/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.6
import QtQuick.Layouts 1.4

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents


RowLayout {

    property alias icon: icon.source
    property alias text: label.text
    PlasmaCore.IconItem {
        id: icon
        colorGroup: PlasmaCore.ColorScope.colorGroup

        Layout.fillHeight: true
        Layout.preferredWidth: height
    }
    PlasmaComponents.Label {
        id: label
        visible: text.length > 0
        color: PlasmaCore.ColorScope.textColor
        font.pixelSize: parent.height / 2
    }
}
