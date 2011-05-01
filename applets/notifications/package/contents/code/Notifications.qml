/***************************************************************************
 *   Copyright 2011 Davide Bettio <davide.bettio@kdemail.net>              *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets

Item {
    
    ListModel {
        id: notifications;
    }
    
    PlasmaCore.DataSource {
        id: notificationsSource
        engine: "notifications"
        interval: 0

        onSourceAdded: {
            connectSource(source);
        }
        
        onNewData: {
            notifications.append({"appIcon" : notificationsSource.data[sourceName]["appIcon"],
                                "appName" : notificationsSource.data[sourceName]["appName"],
                                "summary" : notificationsSource.data[sourceName]["summary"],
                                "body" : notificationsSource.data[sourceName]["body"],
                                "expireTimeout" : notificationsSource.data[sourceName]["expireTimeout"],
                                "urgency": notificationsSource.data[sourceName]["urgency"]});
        }
    }
    
    ListView {
        model: notifications
        anchors.fill: parent
        delegate: Component {
             Row {
                PlasmaWidgets.IconWidget {
                    icon: QIcon(appIcon)
                }
                Column {
                    Text {
                        text: appName + ": " + body
                    }
                    Text {
                        text: body
                    }
                }
            }
        }
    }
}
