/*
    Copyright 2010 Marco Martin <notmart@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Item {
    width: 800
    height: 480

    MobileComponents.IconGrid {
        model: myModel
        delegate: Component {
            MobileComponents.IconDelegate {
                icon: decoration
                text: display
                onClicked: {
                    appsView.clicked(url)
                }
            }
        }

        anchors.fill: parent
        anchors.topMargin: 32
        anchors.bottomMargin: 128
        anchors.leftMargin: 4
        anchors.rightMargin: 4

        onSearchQueryChanged: {
            if (searchQuery == "") {
                myModel.setQuery(myModel.defaultQuery)
            } else {
                myModel.setQuery(searchQuery)
            }
        }
    }
}


