/*
Copyright (C) 2020 Devin Lin <espidev@gmail.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.12
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.12
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.notificationmanager 1.1 as Notifications
import "../components"

Item {
    property alias notificationListHeight: notificationListView.contentHeight
    property int count: notificationListView.count
    
    ListView {
        id: notificationListView
        model: notifModel
        
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: Math.min(contentHeight, parent.height) // don't take up the entire screen for notification list view

        interactive: contentHeight > parent.height // only allow scrolling on notifications list if it is long enough
        clip: true
        opacity: 1 - (passwordFlickable.contentY / passwordFlickable.columnHeight)
        spacing: units.gridUnit
        
        delegate: Column {
            width: notificationListView.width
            spacing: units.smallSpacing
            
            // insert application heading here once application grouping is implemented
            
            SimpleNotification {
                notification: model
            }
        }
    }
}
