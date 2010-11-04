/*
 *   Copyright 2010 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

import Qt 4.7
import com.meego 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets

import "plasmapackage:/code/utils.js" as Utils
import "plasmapackage:/code/bookkeeping.js" as BookKeeping


ListView {
    anchors.fill: parent
    model: PlasmaCore.SortFilterModel {
                id: feedListFilter
                filterRole: "feed_title"
                sourceModel: PlasmaCore.DataModel {
                    dataSource: feedSource
                    key: "sources"
                }
            }
    header: BasicListItem {
        id: feedListHeader
        title: i18n("Show All")
        Label {
            id: unreadLabelHeader
            anchors.right: feedListHeader.padding.right
            anchors.verticalCenter: feedListHeader.verticalCenter
            text: BookKeeping.totalUnreadCount
        }
        onClicked: {
            feedCategoryFilter.filterRegExp = ""
            mainWindow.nextPage(secondPage);
        }
        Connections {
            target: mainWindow
            onUnreadCountChanged: {
                unreadLabelHeader.text = BookKeeping.totalUnreadCount
            }
        }
    }

    delegate: BasicListItem {
        id: feedListItem
        title: feed_title
        image: model.icon
        Label {
            id: unreadLabel
            anchors.right: feedListItem.padding.right
            anchors.verticalCenter: feedListItem.verticalCenter
            text: BookKeeping.unreadForSource(feed_url)
        }
        onClicked: {
            feedCategoryFilter.filterRegExp = feed_url
            mainWindow.nextPage(secondPage);
        }
        Connections {
            target: mainWindow
            onUnreadCountChanged: {
                unreadLabel.text = BookKeeping.unreadForSource(feed_url)
            }
        }
    }

    PositionIndicator { }
}
