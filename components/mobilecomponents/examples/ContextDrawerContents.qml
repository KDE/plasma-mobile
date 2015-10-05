/*
 *   Copyright 2012 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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
import QtQuick.Controls 1.0 as QtControls
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons  2.0


QtControls.ScrollView {
    id: root
    property var actions
    property string title

    ListView {
        id: menu
        model: {
            if (root.actions.length == 0) {
                return null;
            } else {
                return root.actions[0].text !== undefined &&
                    root.actions[0].trigger !== undefined ?
                        root.actions :
                        root.actions[0];
            }
        }
        header: Item {
            height: heading.height
            PlasmaExtras.Heading {
                id: heading
                anchors {
                    left: parent.left
                    margins: units.largeSpacing
                }
                level: 2
                text: root.title
            }
        }
        delegate: PlasmaComponents.ListItem {
            enabled: true
            Row {
                anchors {
                    left: parent.left
                    margins: units.largeSpacing
                }
                PlasmaComponents.Label {
                    enabled: true
                    text: "Menu Item " + model ? model.text : modelData.text
                }
            }
            onClicked: {
                if (modelData && modelData.trigger !== undefined) {
                    modelData.trigger();
                // assume the model is a list of QAction or Action
                } else if (menu.model.length > index) {
                    menu.model[index].trigger();
                } else {
                    console.log("Don't know how to trigger the action")
                }
            }
        }
    }
}

