/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons  2.0

OverlayDrawer {
    id: root

    property string title

    //This can be any type of object that a ListView can accept as model. It expects items compatible with either QAction or QQC Action
    property alias actions: internalActions.data

    Item {
        id: internalActions
    }

    drawer: QtControls.ScrollView {

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
                Heading {
                    id: heading
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: units.largeSpacing
                    }
                    elide: Text.ElideRight
                    level: 2
                    text: root.title
                }
            }
            delegate: ListItem {
                enabled: true
                Row {
                    anchors {
                        left: parent.left
                        margins: units.largeSpacing
                    }
                    Icon {
                        height: parent.height
                        width: height
                        source: modelData.iconName
                    }
                    Label {
                        text: model ? model.text : modelData.text
                    }
                }
                onClicked: {
                    if (modelData && modelData.trigger !== undefined) {
                        modelData.trigger();
                    // assume the model is a list of QAction or Action
                    } else if (menu.model.length > index) {
                        menu.model[index].trigger();
                    } else {
                        console.warning("Don't know how to trigger the action")
                    }
                }
            }
        }
    }
}
