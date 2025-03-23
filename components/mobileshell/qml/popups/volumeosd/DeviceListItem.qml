/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.0

import org.kde.plasma.private.volume 0.1

// adapted from https://invent.kde.org/plasma/plasma-pa/-/blob/master/applet/contents/ui/DeviceListItem.qml
ListItemBase {
    readonly property var currentPort: Ports[ActivePortIndex]
    readonly property var currentActivePortIndex: ActivePortIndex
    readonly property var currentMuted: Muted
    readonly property var activePortIndex: ActivePortIndex
    property bool onlyone: false

    label: {
        if (currentPort && currentPort.description) {
            if (onlyone || !Description) {
                return currentPort.description;
            } else {
                return i18nc("label of device items", "%1 (%2)", currentPort.description, Description);
            }
        }
        if (Description) {
            return Description;
        }
        if (Name) {
            return Name;
        }
        return i18n("Device name not found");
    }
}
