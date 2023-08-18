/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.0

import org.kde.plasma.private.volume 0.1

// adapted from https://invent.kde.org/plasma/plasma-pa/-/blob/master/applet/contents/ui/StreamListItem.qml
ListItemBase {
    id: item

    property QtObject devicesModel
    readonly property bool isEventStream: Name == "sink-input-by-media-role:event"

    label: {
        if (isEventStream) {
            return i18n("Notification Sounds");
        }
        if (Client && Client.name) {
            return i18nc("label of stream items", "%1: %2", Client.name, Name);
        }
        if (Name) {
            return Name;
        }
        return i18n("Stream name not found");
    }

    listIcon: {
        if (IconName.length !== 0) {
            return IconName
        }

        if (item.type === "source-output") {
            return "audio-input-microphone"
        }

        return "audio-volume-high"
    }
}
