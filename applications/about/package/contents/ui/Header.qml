/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
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

import QtQuick 1.0
import org.kde.qtextracomponents 0.1 as QtExtra
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

PlasmaCore.FrameSvgItem {
    id: header

    height: childrenRect.height + margins.bottom + 8


    imagePath: "widgets/frame"
    prefix: "raised"
    enabledBorders: "BottomBorder"


    x: 0
    y: aboutApp.webView.contentY < 0 ? -aboutApp.webView.contentY : webView.contentY > height ? -height : -aboutApp.webView.contentY


    Item {
        width: parent.width
        height: 60
        Item {
            width: tabBar.width
            height: 22
            anchors.centerIn: parent
            PlasmaWidgets.TabBar {
                id: tabBar
                width: 300
                Component.onCompleted: {
                    addTab(i18n("about"))
                    addTab(i18n("authors"))
                    addTab(i18n("license"))
                }
                onCurrentChanged: {
                    view.currentIndex = currentIndex
                }
            }
        }
    }
}
