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
import org.kde.plasma.mobilecomponents 0.2
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.extras 2.0 as PlasmaExtras

/**
 * A window that provides some basic features needed for all apps
 *
 * It's usually used as a root QML component for the application.
 * It's based around the PageRow component, the application will be
 * about pages adding and removal.
 */
ApplicationWindow {
    id: root

    /**
     * The first page that will be loaded when the application starts
     */
    property alias initialPage: __pageStack.initialPage

    /**
     * The stack used to allocate the pages nd to manage the transitions
     * between them.
     * It's using a PageRow, while having the same aPI as PageStack,
     * it positions the pages as adjacent columns, with as many columns
     * as can fit in the screen. An handheld device would usually have a single
     * fullscreen column, a tablet device would have many tiled columns.
     */
    property alias pageStack: __pageStack

    PlasmaExtras.PageRow {
        id: __pageStack
        anchors.fill: parent
    }

}
