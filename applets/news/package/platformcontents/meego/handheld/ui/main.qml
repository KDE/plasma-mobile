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

Window {
    id: mainWindow

    property string currentTitle;
    property string currentBody;
    property string currentUrl;

    signal unreadCountChanged();

    Component.onCompleted: {
        BookKeeping.mainWindow = mainWindow
        BookKeeping.loadReadArticles();
        plasmoid.addEventListener('ConfigChanged', configChanged);
        spinner.visible = true
        mainWindow.nextPage(firstPage)
    }

    function configChanged()
    {
        source = plasmoid.readConfig("feeds")
        var sourceString = new String(source)
        print("Configuration changed: " + source);
        feedSource.source = source
    }

    PlasmaCore.DataSource {
        id: feedSource
        engine: "rss"
        interval: 50000
        onDataChanged: {
            spinner.visible = false;
            BookKeeping.updateUnreadCount(data.items)
        }
    }

    PlasmaCore.SortFilterModel {
        id: postTitleFilter
        filterRole: "title"
        sortRole: "time"
        sortOrder: "DescendingOrder"
        sourceModel: PlasmaCore.SortFilterModel {
            id: feedCategoryFilter
            filterRole: "feed_url"
            sourceModel: PlasmaCore.DataModel {
                dataSource: feedSource
                key: "items"
            }
        }
    }


    property Component firstPage: FeedList {}

    property Component secondPage: PostsList {}

    property Component thirdPage: BrowserPage {}

    Spinner {
        id: spinner
        unknownDuration: true
        visible: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
}