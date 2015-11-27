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

Rectangle {
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
     * Defines the contextual actions for the page:
     * an easy way to assign actions in the right sliding panel
     */
    property alias contextualActions: internalContextualActions.data

    Item {
        id: internalContextualActions
    }

    color: "transparent"

    QtObject {
        id: internal
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
    }
    Connections {
        target: internal.flickable
        property real oldContentY: internal.flickable.contentY
        onContentYChanged: {
            print(internal.flickable.contentY+" "+actionButton.transform[0] )
            if (internal.flickable.atYBeginning || internal.flickable.atYEnd) {
                return;
            }
            actionButton.transform[0].y = Math.min(actionButton.height, Math.max(0, actionButton.transform[0].y + (internal.flickable.contentY - oldContentY)));

            oldContentY = internal.flickable.contentY;
        }
    }
}
