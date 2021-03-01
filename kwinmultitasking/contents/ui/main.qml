/*
 This file is part of the KDE project.

SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kwin 2.0;

Item {
    id: root

    function peekWindowList(amount) {

        switcher.view.contentY = amount;
        switcher.visible = true;
        //panelLoader.item.raise();
    }

    function showWindowList() {
        switcher.open();
        //panelLoader.item.raise();
    }

    function closeWindowList() {
        switcher.close();
    }

    Switcher {
        id: switcher
    }

    Connections {
        target: workspace
        onCurrentDesktopChanged: {
            if (!switcher) {
                mainItemLoader.source = "switcher.qml";
            }
            switcher.visible = true;
        }
    }

    Loader {
        id: panelLoader
    }

    Component.onCompleted: {
        panelLoader.source = "panel.qml"
    }
}


