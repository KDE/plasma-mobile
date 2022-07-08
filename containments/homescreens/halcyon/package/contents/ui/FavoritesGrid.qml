// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.1
import QtQml.Models 2.15

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 3.0 as PC3
import org.kde.draganddrop 2.0 as DragDrop

import org.kde.kirigami 2.19 as Kirigami
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.phone.homescreen.halcyon 1.0 as Halcyon

MobileShell.GridView {
    id: root
    required property var searchWidget
    
    signal openConfigureRequested()
    signal requestOpenFolder(Halcyon.ApplicationFolder folder)
    
    // don't set anchors.margins since we want everywhere to be draggable
    required property real leftMargin
    required property real rightMargin
    required property bool twoColumn
                    
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
    
    // open wallpaper menu when held on click
    TapHandler {
        onLongPressed: root.openConfigureRequested()
    }
    
    header: MobileShell.BaseItem {
        topPadding: Math.round(root.height * 0.2)
        bottomPadding: PlasmaCore.Units.largeSpacing
        leftPadding: root.leftMargin
        rightPadding: root.rightMargin
        implicitWidth: root.width

        background: Rectangle {
            color: 'transparent'
            TapHandler { onLongPressed: root.openConfigureRequested() } // open wallpaper menu when held on click
        }
        contentItem: Clock {}
    }
    
    model: DelegateModel {
        id: visualModel
        model: Halcyon.PinnedModel
        
        delegate: DropArea {
            id: delegateRoot
            property int modelIndex
            property int visualIndex: DelegateModel.itemsIndex
            
            width: root.cellWidth
            height: root.cellHeight
            
            onEntered: (drag) => {
                let from = (drag.source as MobileShell.BaseItem).visualIndex;
                let to = appDelegate.visualIndex;
                visualModel.items.move(from, to);
                Halcyon.PinnedModel.moveEntry(from, to);
            }
            
            //onDropped: (drag) => {
                //let from = modelIndex;
                //let to = (drag.source as MobileShell.BaseItem).visualIndex
                //Halcyon.PinnedModel.moveEntry(from, to);
            //}
            
            FavoritesAppDelegate {
                id: appDelegate
                visualIndex: delegateRoot.visualIndex
                
                isFolder: model.isFolder
                folder: model.folder
                application: model.application
                
                onFolderOpenRequested: root.requestOpenFolder(model.folder)
                
                readonly property bool isLeftColumn: !root.twoColumn || ((visualIndex % 2) === 0)
                readonly property bool isRightColumn: !root.twoColumn || ((visualIndex % 2) !== 0)
                leftPadding: isLeftColumn ? root.leftMargin : 0
                rightPadding: isRightColumn ? root.rightMargin : 0
                
                implicitWidth: root.cellWidth
                implicitHeight: visible ? root.cellHeight : 0
                
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                
                states: [
                    State {
                        when: appDelegate.drag.active
                        ParentChange {
                            target: appDelegate
                            parent: root
                        }
                        
                        AnchorChanges {
                            target: appDelegate
                            anchors.horizontalCenter: undefined
                            anchors.verticalCenter: undefined
                        }
                    }
                ]
            }
        }
    }
    
    // animations
    displaced: Transition {
        NumberAnimation {
            properties: "x,y"
            easing.type: Easing.OutQuad
        }
    }
    
    ColumnLayout {
        id: placeholder
        spacing: PlasmaCore.Units.gridUnit
        visible: root.count == 0
        opacity: 0.9
        
        anchors.fill: parent
        anchors.topMargin: Math.round(swipeView.height * 0.2) - (root.contentY - root.originY)
        anchors.leftMargin: root.leftMargin
        anchors.rightMargin: root.rightMargin
        
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
