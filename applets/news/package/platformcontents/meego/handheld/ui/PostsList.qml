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

    ListView {
        id: postList
        anchors.fill: parent
        model: postTitleFilter
        section.property: "feed_title"
        section.criteria: ViewSection.FullString
        section.delegate: Rectangle {
            width: postList.width
            height: childrenRect.height
            gradient: Gradient {
                GradientStop { position: 0.0; color: "white" }
                GradientStop { position: 1.0; color: Qt.rgba(0.6, 0.6, 0.6, 1) }
            }
            Column {
                Item {
                    width: 5
                    height: 5
                }
                Label {
                    x: 5
                    text: section
                    font.bold: true
                }
                Item {
                    width: 5
                    height: 5
                }
            }
        }
        delegate: BasicListItem {
            title: model.title
            subtitle: Utils.date(model.time);
            onClicked: {
                BookKeeping.setArticleRead(link, feed_url);
                opacity = 0.5;

                currentBody = "<body style=\"background:#fff;\">"+model.description+"</body>";
                currentTitle = model.title
                currentUrl = model.link
                mainWindow.nextPage(thirdPage);
            }
            Component.onCompleted: {
                if (BookKeeping.isArticleRead(link)) {
                    opacity = 0.5
                } else {
                    opacity = 1
                }
            }
        }

        PositionIndicator { }
    }
}
