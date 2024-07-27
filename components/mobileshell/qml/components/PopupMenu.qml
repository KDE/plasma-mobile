/*
 *  SPDX-FileCopyrightText: 2023 Yari Polla <skilvingr@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell as NanoShell

import org.kde.kirigami as Kirigami

/*
 * A context popup menu closable by tapping outside it.
 * Being it a FullScreenOverlay, no event is delivered to underlying components until it's closed.
 *
 * - property relatedTo:     Item to which the popup is related; the popup will spawn either above or below it, depending on its y value.
 *                           If no item is supplied, the popup will spawn at the center of the screen.
 * - property title:         The title for the menu.
 * - property menuActions:   The menu will be composed of these actions.
 * - function showOverlay(): Spawns the popup.
 */
NanoShell.FullScreenOverlay {
    id: overlay
    visible: false
    color: "transparent"

    property point mappedGlobalCoordinates
    property Item relatedTo: null
    property string title
    property list<Kirigami.Action> menuActions

    function showOverlay() {
        if (!overlay.visible) {
            overlay.visible = true;
            menu.open();
        }
    }


    Item {
        id: containerItem
        height: menu.implicitHeight
        width: menu.implicitWidth

        readonly property point coordinates: {
            if (relatedTo) { // Place next to Item
                return mapFromGlobal(mappedGlobalCoordinates.x, mappedGlobalCoordinates.y);
            } else { // Place at the center of the screen
                return Qt.point((overlay.width - width) / 2, (overlay.height - height) / 2);
            }
        }

        x: coordinates.x
        y: coordinates.y

        transform: Translate {
            x: 0
            y: (containerItem.coordinates.y <= overlay.height/2 ? relatedTo.height : -containerItem.height) - Constants.topPanelHeight
        }

        PlasmaComponents.Menu {
            id: menu
            title: overlay.title
            closePolicy: PlasmaComponents.Menu.CloseOnReleaseOutside | PlasmaComponents.Menu.CloseOnEscape

            onClosed: overlay.close()

            Component.onCompleted: {
                for (var i = 0; i < menuActions.length; i++) {
                    appendItem(menuActions[i]);
                }
            }

            function appendItem(button) {
                menu.addItem(menuItem.createObject(
                                 menu,
                                 {
                                     iconName: button.iconName,
                                     text: i18n(button.text),
                                     callback: button.triggered
                                 }));
            }
            Component {
                id: menuItem

                PlasmaComponents.MenuItem {
                    property string iconName: ""
                    property var callback: () => {}

                    icon.name: iconName
                    onClicked: callback()
                }
            }
        }
    }

}
