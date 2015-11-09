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
import QtQuick.Layouts 1.3
import org.kde.plasma.mobilecomponents 0.2
import "private"

Item {
    id: root

    /**
     * type:PageStack
     * The page stack that this page is owned by.
     */
    property Item pageStack

    /**
     * Defines the toolbar contents for the page. If the page stack is set up
     * using a toolbar instance, it automatically shows the currently active
     * page's toolbar contents in the toolbar.
     *
     * The default value is null resulting in the page's toolbar to be
     * invisible when the page is active.
     */
    property Item tools: null

    /**
     * Defines the actions for the page: at most 4 buttons will
     * contain the actions at the bottom of the page, if the main
     * item of the page is a Flickable or a ScrllArea, it will
     * control the visibility of the actions.
     */
    property alias actions: internalActions.data

    Item {
        id: internalActions
    }

    RowLayout {
        id: internalButtons
        z:99
        anchors.horizontalCenter: parent.horizontalCenter
        Layout.fillWidth: false
        height: units.iconSizes.large
        property Item flickable: {
            if (root.children[root.children.length-1]) {
                if (root.children[root.children.length-1].contentY) {
                    return root.children[root.children.length-1];
                } else if (root.children[root.children.length-1].flickableItem) {
                    return root.children[root.children.length-1].flickableItem;
                }
            }
            return null;
        }
        Connections {
            target: internalButtons.flickable
            property real oldContentY: internalButtons.flickable.contentY
            onContentYChanged: {
                if (internalButtons.flickable.atYBeginning || internalButtons.flickable.atYEnd) {
                    return;
                }
                internalButtons.y = Math.max(internalButtons.flickable.height - internalButtons.height - Units.smallSpacing, Math.min(internalButtons.flickable.height, internalButtons.y + internalButtons.flickable.contentY - oldContentY));
                oldContentY = internalButtons.flickable.contentY;
            }
        }
        y: parent.height - height - Units.smallSpacing
        Repeater {
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
            delegate: ActionButton {
                Layout.fillHeight: true
                iconSource: modelData.iconName
                onClicked: {
                    if (modelData && modelData.trigger !== undefined) {
                        modelData.trigger();
                    // assume the model is a list of QAction or Action
                    } else if (toolbar.model.length > index) {
                        toolbar.model[index].trigger();
                    } else {
                        console.log("Don't know how to trigger the action")
                    }
                }
            }
        }
        onChildrenChanged: {
            var flexibleFound = false;
            for (var i = 0; i < children.length; ++i) {
                if (children[i].Layout.fillWidth) {
                    flexibleFound = true;
                    break;
                }
            }
            Layout.fillWidth = flexibleFound;
        }
    }
}
