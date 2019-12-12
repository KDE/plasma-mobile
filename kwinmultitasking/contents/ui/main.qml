/********************************************************************
 This file is part of the KDE project.

Copyright (C) 2015 Marco MArtin <mart@kde.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*********************************************************************/
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


