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
import QtQuick.Layouts 1.4
import QtQuick.Window 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kwin 2.0

PlasmaCore.Dialog {
    id: panel
    y: workspace.virtualScreenSize.height - height
    flags: Qt.X11BypassWindowManagerHint
    type: PlasmaCore.Dialog.Dock
    backgroundHints: PlasmaCore.Dialog.NoBackground

    mainItem: MouseArea {
        width: workspace.virtualScreenSize.width
        height: units.iconSizes.medium
        property int startY
        property bool dragging

        onPressed: {
            startY = mouse.y;
            dragging = false
        }
        onPositionChanged: {
            if (Math.abs(mouse.y - startY) > height) {
                dragging = true;
            }
            if (dragging) {
                root.peekWindowList(-workspace.virtualScreenSize.height - mouse.y);
            }
        }
        onReleased: {
            if (dragging) {
                if (mouse.y < -workspace.virtualScreenSize.height/2) {
                    root.showWindowList();
                } else {
                    root.closeWindowList();
                }
                return;
            }
            var button = layout.childAt(mouse.x, mouse.y);
            if (button) {
                button.click();
            }
        }

        Rectangle {
            anchors.fill: parent
            color: theme.backgroundColor
        }

        RowLayout {
            id: layout
            anchors.fill: parent
            PlasmaCore.IconItem {
                Layout.fillWidth: true
                Layout.fillHeight: true
                source: "box"
                function click() { root.showWindowList();}
            }

            PlasmaCore.IconItem {
                Layout.fillWidth: true
                Layout.fillHeight: true
                source: "start-here-kde"
                function click() {
                    root.closeWindowList();
                    workspace.slotToggleShowDesktop();
                }
            }
            
            PlasmaCore.IconItem {
                Layout.fillWidth: true
                Layout.fillHeight: true
                source: "paint-none"
                enabled: workspace.activeClient
                function click() { workspace.activeClient.closeWindow();}
            }
        }
    }
    Component.onCompleted: {
        KWin.registerWindow(panel);
        panel.visible = true;

        panel.y = workspace.virtualScreenSize.height - height
    }
}
