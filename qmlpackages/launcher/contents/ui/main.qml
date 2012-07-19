/*
    Copyright 2010 Marco Martin <notmart@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

import QtQuick 1.0
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.plasma.slccomponents 0.1 as SlcComponents
import org.kde.runnermodel 0.1 as RunnerModels

MouseArea {
    id: main
    width: 400
    height: 150

    //just to hide the keyboard
    onClicked: main.forceActiveFocus()

    signal itemLaunched

    function resetStatus()
    {
        searchField.searchQuery = ""
        appGrid.currentPage = 0
    }

    Image {
        id: background
        width: parent.width * 1.5
        height:parent.height
        source: "image://appbackgrounds/contextarea"
        fillMode: Image.Tile
        x: -((width-parent.width) * (appGrid.currentPage / appGrid.pagesCount))
        Behavior on x {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    }

    PlasmaExtras.ResourceInstance {
        id: resourceInstance
    }

    SlcComponents.SlcMenu {
        id: contextMenu
    }

    PlasmaCore.Theme {
        id: theme
    }

    RunnerModels.RunnerModel {
        id: runnerModel
    }

    MobileComponents.ViewSearch {
        id: searchField
        // we have this property because RunnerManager does a fair amount of
        // bookeeping when setting runners; normally not a big issues, but this
        // lets us avoid it as much as possible
        property bool listingApps: true

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: 8
        }

        onSearchQueryChanged: {
            if (searchQuery.length < 3) {
                if (!listingApps) {
                    runnerModel.runners = [ "org.kde.active.apps" ]
                    listingApps = true;
                }

                runnerModel.query = '';
            } else {
                if (listingApps) {
                    runnerModel.runners = [ "org.kde.active.apps", "nepomuksearch", "recentdocuments", "desktopsessions" , "PowerDevil", "calculator" ]
                    listingApps = false;
                }

                runnerModel.query = searchQuery
            }
        }
        busy: runnerModel.running && (searchQuery.length >= 3)

        Component.onCompleted: {
            delay = 10
        }
    }

    MobileComponents.IconGrid {
        id: appGrid
        model: runnerModel
        onCurrentPageChanged: resourceInstance.uri = ""

        delegate: Component {
            MobileComponents.ResourceDelegate {
                id: launcherDelegate
                width: appGrid.delegateWidth
                height: appGrid.delegateHeight
                className: "FileDataObject"
                genericClassName: "FileDataObject"
                property string label: model["name"] ? model["name"] : model["label"]
                //property string mimeType: model["mimeType"] ? model["mimeType"] : "application/x-desktop"
                onPressAndHold: ParallelAnimation {
                    PlasmaExtras.ReleasedAnimation { targetItem: launcherDelegate }
                    ScriptAction { script: {
                            resourceInstance.uri = model["resourceUri"] ? model["resourceUri"] : model["entryPath"]
                            resourceInstance.title = model["name"] ? model["name"] : model["text"]
                        }
                    }
                }
                onClicked: {
                    runnerModel.run(appGrid.currentPage*appGrid.pageSize+index)
                    resetStatus()
                    itemLaunched()
                }
                onPressed: PlasmaExtras.PressedAnimation { targetItem: launcherDelegate }
                onReleased: PlasmaExtras.ReleasedAnimation { targetItem: launcherDelegate }
            }
        }

        anchors {
            left: parent.left
            right: parent.right
            top: searchField.bottom
            bottom: parent.bottom
            topMargin: 6
            bottomMargin: 4
        }
    }

    Component.onCompleted: { runnerModel.runners =  [ "org.kde.active.apps" ] }
}


