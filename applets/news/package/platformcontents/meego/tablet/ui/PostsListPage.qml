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

import "../../generic/ui/"

Page {
    title: feedSource.data['title'];

    actions: [
        Action {
            item: Item {
                height: 60 // ###
                width: postListSearchBox.width
                LineEdit {
                    id: postListSearchBox
                    styleType: "toolbar"
                    anchors.verticalCenter: parent.verticalCenter
                    onTextChanged: {
                        postListSearchTimer.running = true
                    }
                }
            }
        }
    ]

    Timer {
        id: postListSearchTimer
        interval: 500;
        running: false
        repeat: false
        onTriggered: {
            postTitleFilter.filterRegExp = ".*"+postListSearchBox.text+".*";
        }
    }

    Rectangle {
        id:feedList
        anchors.fill: parent
        anchors.rightMargin: 2*(parent.width/3)
        color: "white"
        FeedList {
            anchors.fill: parent
            onClicked: {
                feedCategoryFilter.filterRegExp = url
            }
        }
    }
    PostsList {
        anchors.fill: parent
        anchors.leftMargin: parent.width/3
    }

}
