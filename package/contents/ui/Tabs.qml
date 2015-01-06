/***************************************************************************
 *                                                                         *
 *   Copyright 2014-2015 Sebastian Kügler <sebas@kde.org>                  *
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
 *                                                                         *
 ***************************************************************************/

import QtQuick 2.3
//import QtQuick.Controls 1.0

//import QtWebEngine 1.0

import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
// import org.kde.plasma.components 2.0 as PlasmaComponents
// import org.kde.plasma.extras 2.0 as PlasmaExtras


Item {

    id: tabsRoot

    property int itemHeight: Math.round(itemWidth/ 3 * 2)
    property int itemWidth: (width / 2) - units.gridUnit

    //Rectangle { anchors.fill: parent; color: "brown"; opacity: 0.5; }

    GridView {
        //columns: 2
        anchors.fill: parent
        //model: tabs.count +
        model: tabs.model
        //model: 4
        cellWidth: itemWidth
        cellHeight: itemHeight

        delegate: Item {
            id: tabItem
            width: itemWidth
            height: itemHeight
            ShaderEffectSource {
                id: shaderItem

                //live: true
                anchors.fill: parent
                anchors.margins: units.gridUnit / 2

                sourceRect: Qt.rect(0, 0, width * 2, height * 2)

                sourceItem: {
                    tabs.itemAt(tabs.pageWidth * index, 0);
                }
                //opacity: tabs.currentIndex == index ? 1 : 0.0


                Behavior on height {
                    SequentialAnimation {
                        ScriptAction {
                            script: {
                                print("Animation start");
                                // switch to tabs
                            }
                        }
                        NumberAnimation { duration: units.longDuration; easing.type: Easing.InOutQuad }
                        NumberAnimation { duration: units.longDuration; easing.type: Easing.InOutQuad; target: contentView; property: opacity }
                        ScriptAction {
                            script: {
                                print("Animation done");
                                contentView.state = "hidden"
                            }
                        }
                    }
                }

                Behavior on width {
                    NumberAnimation { duration: units.longDuration; easing.type: Easing.InOutQuad}

                }

            }
            Rectangle {
                anchors.fill: parent;
                anchors.margins: units.gridUnit / 4;
                border.color: theme.textColor;
                border.width: webBrowser.borderWidth
                color: "transparent"
                opacity: 0.3;

            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    print("Switch from " + tabs.currentIndex + "  to tab " + index);

                    tabs.currentIndex = index;
                    tabs.positionViewAtIndex(index, ListView.Beginning);
                    //tabs.positionViewAtEnd();
                    contentView.state = "hidden"
                    return;

                    if (tabItem.width < tabsRoot.width) {
//                         tabItem.width = currentWebView.width
//                         tabItem.height = currentWebView.height
                    } else {
                        tabItem.width = itemWidth
                        tabItem.height = itemHeight
                    }
                }

            }
        }

        footer: Rectangle {
            color: "white"
            width: itemWidth
            height: itemHeight
            PlasmaCore.IconItem {
                anchors.fill: parent
                anchors.margins: Math.round(itemHeight / 4)
                source: "list-add"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    tabs.newTab("")
                    //addressBar.forceActiveFocus();
                    //addressBar.selectAll();
                    tabs.currentIndex = tabs.count - 1;
                    contentView.state = "bookmarks"
                }

            }
        }


    }

}
