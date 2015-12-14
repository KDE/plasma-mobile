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
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.2
import org.kde.plasma.mobilecomponents 0.2

ScrollView {
    id: root
    property bool requestingRefresh: false
    signal refreshRequested
    property alias header: listView.header
    property alias footer: listView.footer
    property alias model: listView.model
    property alias delegate: listView.delegate
    property ListView listView: listView

    property alias contentY: listView.contentY
    children: [
        Item {
            z: 99
            y: -listView.contentY-height
            width: listView.width
            height: Units.gridUnit * 3
            BusyIndicator {
                anchors.centerIn: parent
                running: root.requestingRefresh
                opacity: root.requestingRefresh ? 1 : (listView.originY - listView.contentY) / (Units.gridUnit * 3)
                rotation: root.requestingRefresh ? 0 : 360 * opacity
            }
        }]
    Component.onCompleted: {
        listView.topMargin = 500
        listView.bottomMargin = 500
    }
    ListView {
        id: listView
        onContentYChanged: {
            if (contentY < originY - Units.gridUnit * 3 && !root.requestingRefresh) {
                root.requestingRefresh = true;
                root.refreshRequested();
            }
        }
    }
}