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
    //this is used to perfectly align the filter field and delegates
    property int cellWidth: theme.mSize(theme.defaultFont).width * 10

    property int minimumWidth: theme.mSize(theme.defaultFont).width * 12
    property int minimumHeight: 800
    property alias containment: widgetExplorer.containment

    //external drop events can cause a raise event causing us to lose focus and
    //therefore get deleted whilst we are still in a drag exec()
    //this is a clue to the owning dialog that hideOnWindowDeactivate should be deleted
    //See https://bugs.kde.org/show_bug.cgi?id=332733
    property bool preventWindowHide: false
    signal closed()

    WidgetExplorer {
        id: widgetExplorer
    }

    ColumnLayout {
        anchors.fill: parent

        PlasmaExtras.Title {
            id: heading
            text: "Widgets"
            elide: Text.ElideRight
            anchors.horizontalCenter: parent.horizontalCenter
        }

        MobileComponents.IconGrid {
            id: list
            property int currentIndex: 0
            signal closeRequested()

            onCloseRequested: main.closed()

            onCurrentIndexChanged: {
                currentPage = Math.max(0, Math.floor(currentIndex/pageSize))
            }
            property int delegateWidth: Math.floor(list.width / Math.max(Math.floor(list.width / (units.gridUnit*12)), 3))
            property int delegateHeight: delegateWidth / 1.6

            anchors {
                top: heading.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            model: widgetExplorer.widgetsModel
            delegate: AppletDelegate {}
        }
    }
}
