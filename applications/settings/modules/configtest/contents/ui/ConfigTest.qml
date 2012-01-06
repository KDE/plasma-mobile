// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2012 Sebastian Kügler <mart@kde.org>
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

import QtQuick 1.0
import org.kde.plasma.components 0.1 as PlasmaComponents

Item {
    PlasmaComponents.TabBar {
        id: tabs
        anchors { top: parent.top; left: parent.left; right: parent.right; }

        PlasmaComponents.TabButton {
            text: "Types"
            onClicked: stack.replace(typesComponent);
        }

        Component {
            id: typesComponent
            TypeTest { }
        }

        PlasmaComponents.TabButton {
            text: "Nesting"
            onClicked: stack.replace(nestingComponent);
        }

        Component {
            id: nestingComponent
            NestingTest { }
        }

        PlasmaComponents.TabButton {
            text: "Config List"
            onClicked: stack.replace(listComponent);
        }

        Component {
            id: listComponent
            ConfigList {}
        }
    }
    PlasmaComponents.PageStack {
        id: stack
        anchors { top: tabs.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; }
        Component.onCompleted: replace(typesComponent);
    }
}
