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
import QtQuick.Layouts 1.2
import org.kde.plasma.mobilecomponents 0.2
import "private"

/**
 * Page is a container for all the app pages: everything pushed to the
 * ApplicationWindow stackView should be a Page instabnce
 */
Rectangle {
    id: root

    /**
     * contextualActions: list<QtObject>
     * Defines the contextual actions for the page:
     * an easy way to assign actions in the right sliding panel
     *
     * Example usage:
     * @code
     * import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
     *
     * MobileComponents.ApplicationWindow {
     *  [...]
     *     contextDrawer: MobileComponents.ContextDrawer {
     *         id: contextDrawer
     *     }
     *  [...]
     * }
     * @endcode
     *
     * @code
     * import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
     *
     * MobileComponents.Page {
     *   [...]
     *     contextualActions: [
     *         MobileComponents.Action {
     *             iconName: "edit"
     *             text: "Action text"
     *             onTriggered: {
     *                 // do stuff
     *             }
     *         },
     *         MobileComponents.Action {
     *             iconName: "edit"
     *             text: "Action text"
     *             onTriggered: {
     *                 // do stuff
     *             }
     *         }
     *     ]
     *   [...]
     * }
     * @endcode
     */
    property list<QtObject> contextualActions

    /**
     * mainAction: Action
     * An optional single action for the action button.
     * it can be a MobileComponents.Action or a QAction
     *
     * Example usage:
     *
     * @code
     * import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
     * MobileComponents.Page {
     *     mainAction: MobileComponents.Action {
     *         iconName: "edit"
     *         onTriggered: {
     *             // do stuff
     *         }
     *     }
     * }
     * @endcode
     */
    property QtObject mainAction

    Layout.fillWidth: true
    color: "transparent"
}
