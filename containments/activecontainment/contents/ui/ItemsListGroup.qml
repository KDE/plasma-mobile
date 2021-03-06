/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *   Copyright 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
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

ItemGroup {
    id: itemGroup
    property alias categoryCount: itemsList.count
    title: i18n("%1 (%2)", itemGroup.category, itemsList.count)
    scale: itemsList.count>0?1:0
    canResizeHeight: true
    enabled: itemsList.count>0
    onEnabledChanged: {
        layoutTimer.restart()
    }
    imagePath: "widgets/translucentbackground"

    ItemsList {
        id: itemsList
        width: parent.width
        height: parent.height
    }
}
