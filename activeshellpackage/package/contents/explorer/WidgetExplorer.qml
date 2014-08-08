/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.private.shell 2.0
import QtQuick.Layouts 1.0

Item {
    id: main

    property int minimumWidth: theme.mSize(theme.defaultFont).width * 12
    property int minimumHeight: 800
    property alias containment: widgetExplorer.containment
    property int iconWidth: theme.mSize(theme.defaultFont).width * 14
    property int iconHeight: theme.mSize(theme.defaultFont).width * 14

    //external drop events can cause a raise event causing us to lose focus and
    //therefore get deleted whilst we are still in a drag exec()
    //this is a clue to the owning dialog that hideOnWindowDeactivate should be deleted
    //See https://bugs.kde.org/show_bug.cgi?id=332733
    property bool preventWindowHide: false
    signal closed()

    WidgetExplorer {
        id: widgetExplorer
    }

    MenuTabBar {
        id: tabBar
    }

    PlasmaComponents.PageStack {
        id: stack
        clip: true
        anchors {
            left: parent.left
            right: parent.right
            top: tabBar.bottom
            bottom: parent.bottom
        }
        initialPage: tabBar.startComponent
    }
}
