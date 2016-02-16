/*
 *   Copyright 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
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
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.plasma.private.mobileshell 2.0

IconGrid {
    id: commonList
    property int currentIndex: 0
    signal closeRequested()
    property bool isApplicationExplorer: false
    onCloseRequested: main.closed()

    onCurrentIndexChanged: {
        currentPage = Math.max(0, Math.floor(currentIndex/pageSize))
    }

    delegateWidth: Math.floor(commonList.width / Math.max(Math.floor(commonList.width / (units.gridUnit*12)), 3))
    delegateHeight: delegateWidth / 1.6

    anchors.fill: parent
    model: isApplicationExplorer ? applicationsModel : widgetExplorer.widgetsModel
    delegate: CommonDelegate {}
}
