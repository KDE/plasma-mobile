/*
    SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <Aix.m@outlook.com>
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.private.volume 0.1 as VolumeLib
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell as MobileShell

/**
 * This imports the volume OSD and also sets up keyboard/hardware button bindings.
 */
QtObject {
    id: component

    function showVolumeOverlay() {
        if (!osd.visible) {
            vcp.showOverlay();
        }
    }

    Component.onCompleted: {
        MobileShell.AudioInfo.volumeChanged.connect(showVolumeOverlay);
    }

    property var apiListener: Connections {
        target: MobileShellState.ShellDBusClient

        function onShowVolumeOSDRequested() {
            osd.showOverlay();
            vcp.close();
        }
    }

    property var osd: VolumeOSD {}
    property var vcp: VolumeChangedPopup {}
}
