// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.1
import QtQml.Models 2.15
import QtGraphicalEffects 1.12

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 3.0 as PC3
import org.kde.draganddrop 2.0 as DragDrop

import org.kde.kirigami 2.19 as Kirigami
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.phone.homescreen.halcyon 1.0 as Halcyon

GridView {
    id: root
    property Halcyon.ApplicationFolder folder: null
    
    property string folderName: folder ? folder.name : ""
    property var folderModel: folder ? folder.applications : []
    
    // don't set anchors.margins since we want everywhere to be draggable
    required property real leftMargin
    required property real rightMargin
    required property bool twoColumn
    
    signal openConfigureRequested()
    signal closeRequested()
    
    TapHandler {
        onLongPressed: root.openConfigureRequested()
        onTapped: root.closeRequested()
    }
    
    header: MobileShell.BaseItem {
        topPadding: Math.round(root.height * 0.2)
        bottomPadding: PlasmaCore.Units.largeSpacing
        leftPadding: root.leftMargin
        rightPadding: root.rightMargin
        implicitWidth: root.width

        background: Rectangle {
            color: 'transparent'
            TapHandler { 
                onLongPressed: root.openConfigureRequested()
                onTapped: root.closeRequested()
            }
        }
        contentItem: RowLayout {
            spacing: PlasmaCore.Units.gridUnit
            Kirigami.Icon {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: PlasmaCore.Units.iconSizes.small
                Layout.preferredWidth: PlasmaCore.Units.iconSizes.small
                isMask: true
                color: 'white'
                source: 'arrow-left'

                layer.enabled: true
                layer.effect: DropShadow {
                    verticalOffset: 1
                    radius: 4
                    samples: 6
                    color: Qt.rgba(0, 0, 0, 0.5)
                }
            }
            QQC2.Label {
                Layout.fillWidth: true
                text: root.folderName
                color: "white"
                style: Text.Normal
                styleColor: "transparent"
                horizontalAlignment: Text.AlignLeft
                
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                maximumLineCount: 2

                font.weight: Font.Bold
                font.pointSize: 18
                layer.enabled: true
                layer.effect: DropShadow {
                    verticalOffset: 1
                    radius: 4
                    samples: 6
                    color: Qt.rgba(0, 0, 0, 0.5)
                }
            }
        }
    }
    
    model: DelegateModel {
        id: visualModel
        model: root.folderModel
        
        delegate: DropArea {
            id: delegateRoot
            property var application: model.application
            
            property int modelIndex
            property int visualIndex: DelegateModel.itemsIndex
            
            width: root.cellWidth
            height: root.cellHeight
            
            onEntered: (drag) => {
                let from = (drag.source as MobileShell.BaseItem).visualIndex;
                let to = appDelegate.visualIndex;
                visualModel.items.move(from, to);
                root.folder.moveEntry(from, to);
            }
            
            //onDropped: (drag) => {
                //let from = modelIndex;
                //let to = (drag.source as MobileShell.BaseItem).visualIndex
                //Halcyon.PinnedModel.moveEntry(from, to);
            //}
            
            FavoritesAppDelegate {
                id: appDelegate
                visualIndex: delegateRoot.visualIndex
                
                isFolder: false
                application: modelData
                
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
}
