/*
 *   Copycontext 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.1
import QtQuick.Controls 1.3
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0

SimpleApp {
    id: root
    width: 500
    height: 800


    onGlobalDrawerOpenChanged: {
        configureButton.checked = globalDrawerOpen;
    }
    onContextDrawerOpenChanged: {
        menuButton.checked = contextDrawerOpen;
    }
    statusBar: PlasmaComponents.ToolBar {
        tools: PlasmaComponents.ToolBarLayout {
            //TODO: those buttons should support drag to open the menus as well
            PlasmaComponents.ToolButton {
                id: configureButton
                iconSource: "configure"
                checkable: true
                onCheckedChanged: {
                    globalDrawerOpen = checked
                    if (checked) {
                        contextDrawerOpen = false;
                    }
                }
            }
            PlasmaComponents.ToolButton {
                id: menuButton
                iconSource: "applications-other"
                checkable: true
                onCheckedChanged: {
                    contextDrawerOpen = checked
                    if (checked) {
                        globalDrawerOpen = false;
                    }
                }
            }
        }
    }

    globalDrawer: PlasmaExtras.ScrollArea {
        ListView {
            id: optionMenu
            model: 5
            verticalLayoutDirection: ListView.BottomToTop

            delegate: PlasmaComponents.ListItem {
                PlasmaComponents.Label {
                    enabled: true
                    text: "Option " + modelData
                }
            }
        }
    }
    contextDrawer: PlasmaExtras.ScrollArea {
        ListView {
            model: 6
            delegate: PlasmaComponents.ListItem {
                PlasmaComponents.Label {
                    enabled: true
                    text: "Menu Item " + modelData
                }
            }
        }
    }

    //Main app content
    PlasmaExtras.ScrollArea {
        ListView {
            model: 30
            delegate: PlasmaComponents.ListItem {
                PlasmaComponents.Label {
                    enabled: true
                    text: "Item " + modelData
                }
            }
        }
    }
}
