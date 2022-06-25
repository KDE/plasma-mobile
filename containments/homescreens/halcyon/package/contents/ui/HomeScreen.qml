// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 3.0 as PC3
import org.kde.draganddrop 2.0 as DragDrop

import org.kde.kirigami 2.19 as Kirigami
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.phone.homescreen.halcyon 1.0 as Halcyon

Item {
    id: root
    
    property bool interactive: true
    property var searchWidget
    
    property alias page: swipeView.currentIndex
    
    function triggerHomescreen() {
        swipeView.setCurrentIndex(0);
        favouritesList.contentY = favouritesList.originY;
    }
    
    function openConfigure() {
        console.log('triggered')
        plasmoid.action("configure").trigger();
        plasmoid.editMode = false;
    }
    
    QQC2.SwipeView {
        id: swipeView
        opacity: 1 - searchWidget.openFactor
        interactive: root.interactive
        
        anchors.fill: parent
        anchors.topMargin: MobileShell.Shell.topMargin
        anchors.bottomMargin: MobileShell.Shell.bottomMargin
        anchors.leftMargin: MobileShell.Shell.leftMargin
        anchors.rightMargin: MobileShell.Shell.rightMargin
        
        Item {
            height: swipeView.height
            width: swipeView.width
            
            // open wallpaper menu when held on click
            TapHandler {
                onLongPressed: root.openConfigure()
            }
                    
            ListView {
                id: favouritesList
                clip: true
                interactive: root.interactive
                anchors.fill: parent
                
                // don't set anchors.margins since we want everywhere to be draggable
                readonly property real leftMargin: Math.round(parent.width * 0.1)
                readonly property real rightMargin: Math.round(parent.width * 0.1)
                readonly property real delegateHeight: PlasmaCore.Units.gridUnit * 3
                                
                // search widget open gesture
                property bool openingSearchWidget: false
                property real oldVerticalOvershoot: verticalOvershoot
                onVerticalOvershootChanged: {
                    if (dragging && verticalOvershoot < 0) {
                        if (!openingSearchWidget) {
                            if (oldVerticalOvershoot === 0) {
                                openingSearchWidget = true;
                                root.searchWidget.startGesture();
                            }
                        } else {
                            let offset = -(verticalOvershoot - oldVerticalOvershoot);
                            root.searchWidget.updateGestureOffset(-offset);
                        }
                    }
                    oldVerticalOvershoot = verticalOvershoot;
                }
                onDraggingChanged: {
                    if (!dragging && openingSearchWidget) {
                        openingSearchWidget = false;
                        root.searchWidget.endGesture();
                    }
                }
                
                model: Halcyon.PinnedModel
                header: MobileShell.BaseItem {
                    topPadding: Math.round(swipeView.height * 0.2)
                    bottomPadding: PlasmaCore.Units.largeSpacing
                    leftPadding: favouritesList.leftMargin
                    rightPadding: favouritesList.rightMargin
                    implicitWidth: favouritesList.width

                    background: Rectangle {
                        color: 'transparent'
                        TapHandler { onLongPressed: root.openConfigure() } // open wallpaper menu when held on click
                    }
                    contentItem: Clock {}
                }
                
                delegate: MobileShell.BaseItem {
                    leftPadding: favouritesList.leftMargin
                    rightPadding: favouritesList.rightMargin
                    
                    contentItem: DrawerListDelegate {
                        implicitWidth: favouritesList.width - favouritesList.leftMargin - favouritesList.rightMargin
                        implicitHeight: visible ? favouritesList.delegateHeight : 0
                    }
                }
                
                // open wallpaper menu when held on click
                TapHandler {
                    onLongPressed: root.openConfigure()
                }
                
                ColumnLayout {
                    id: placeholder
                    spacing: PlasmaCore.Units.gridUnit
                    visible: favouritesList.count == 0
                    opacity: 0.9
                    
                    anchors.fill: parent
                    anchors.topMargin: Math.round(swipeView.height * 0.2) - (favouritesList.contentY - favouritesList.originY)
                    anchors.leftMargin: favouritesList.leftMargin
                    anchors.rightMargin: favouritesList.rightMargin
                    
                    Kirigami.Icon {
                        id: icon
                        Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                        implicitWidth: PlasmaCore.Units.iconSizes.large
                        implicitHeight: width
                        source: "emblem-favorite"
                        color: "white"
                    }
                    
                    PlasmaExtras.Heading {
                        Layout.fillWidth: true
                        Layout.maximumWidth: placeholder.width * 0.75
                        Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                        color: "white"
                        level: 3
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                        text: i18n("Add applications to your favourites so they show up here.")
                    }
                }
            }
        }
        
        ColumnLayout {
            id: column 
            height: swipeView.height
            width: swipeView.width
            
            property real horizontalMargin: Math.max(Kirigami.Units.largeSpacing, root.width * 0.1 / 2)
            
            GridAppList {
                interactive: root.interactive
                leftMargin: column.horizontalMargin
                rightMargin: column.horizontalMargin
                effectiveContentWidth: swipeView.width - leftMargin - rightMargin
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}
