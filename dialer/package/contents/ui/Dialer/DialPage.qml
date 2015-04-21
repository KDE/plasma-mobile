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

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Column {
    spacing: 0
    PlasmaComponents.TabGroup {
        anchors {
            left: parent.left
            right: parent.right
        }
        height: parent.height - tabbar.height
        History {
            id: history
        }
        Contacts {
            id: contacts
        }
        Dialer {
            id: dialer
        }
    }
    PlasmaComponents.TabBar {
        id: tabbar
        height: units.gridUnit * 5
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        tabPosition: Qt.BottomEdge
        PlasmaComponents.TabButton {
            iconSource: "view-history"
            text: i18n("History")
            tab: history
        }
        PlasmaComponents.TabButton {
            iconSource: "view-pim-contacts"
            text: i18n("Contacts")
            tab: contacts
        }
        PlasmaComponents.TabButton {
            iconSource: "input-keyboard"
            text: i18n("Dialpad")
            tab: dialer
        }
    }
}