// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.1
import QtQml.Models 2.15
import QtGraphicalEffects 1.12

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 3.0 as PC3
import org.kde.draganddrop 2.0 as DragDrop

import org.kde.kirigami 2.19 as Kirigami
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.phone.homescreen.halcyon 1.0 as Halcyon

MobileShell.GridView {
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
    
    property bool inFolderTitleEditMode: false
    
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
        
        Component {
            id: folderTitleEdit
            
            TextEdit {
                text: root.folderName
                color: "white"
                selectByMouse: true
                wrapMode: TextEdit.Wrap
                
                Component.onCompleted: forceActiveFocus()
                
                font.weight: Font.Bold
                font.pointSize: 18
                layer.enabled: true
                layer.effect: DropShadow {
                    verticalOffset: 1
                    radius: 4
                    samples: 6
                    color: Qt.rgba(0, 0, 0, 0.5)
                }
                
                onTextChanged: {
                    if (text.includes('\n')) {
                        // exit text edit mode when new line is entered
                        root.inFolderTitleEditMode = false;
                    } else {
                        root.folder.name = text;
                    }
                }
                onEditingFinished: root.inFolderTitleEditMode = false
            }
        }
        
        Component {
            id: folderTitleLabel
            
            QQC2.Label {
                text: root.folderName
                color: "white"
                style: Text.Normal
                styleColor: "transparent"
                horizontalAlignment: Text.AlignLeft
                textFormat: Text.MarkdownText
                
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
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.inFolderTitleEditMode = true
                }
            }
        }
        
        contentItem: RowLayout {
            id: rowLayout
            spacing: PlasmaCore.Units.smallSpacing * 2
            
            // close folder button
            MouseArea {
                id: button
                Layout.alignment: Qt.AlignVCenter
                implicitHeight: PlasmaCore.Units.iconSizes.small + PlasmaCore.Units.largeSpacing
                implicitWidth: PlasmaCore.Units.iconSizes.small + PlasmaCore.Units.largeSpacing
                
                cursorShape: Qt.PointingHandCursor
                onClicked: root.closeRequested()
                
                // button background
                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(255, 255, 255, button.pressed ? 0.2 : 0)
                    radius: button.width / 2
                }
                
                // button icon
                Kirigami.Icon {
                    anchors.centerIn: parent
                    implicitHeight: PlasmaCore.Units.iconSizes.small
                    implicitWidth: PlasmaCore.Units.iconSizes.small
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
            }
            
            // folder title
            Loader {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                Layout.maximumWidth: rowLayout.width - button.width - rowLayout.spacing
                sourceComponent: root.inFolderTitleEditMode ? folderTitleEdit : folderTitleLabel
            }
        }
    }
    
    model: DelegateModel {
        id: visualModel
        model: root.folderModel
        
        delegate: Item {
            id: delegateRoot
            width: root.cellWidth
            height: root.cellHeight
            
            property int visualIndex: DelegateModel.itemsIndex
            
            DropArea {
                anchors.fill: parent
                onEntered: (drag) => {
                    let from = drag.source.visualIndex;
                    let to = appDelegate.visualIndex;
                    visualModel.items.move(from, to);
                    root.folder.moveEntry(from, to);
                }
            }
            
            FavoritesAppDelegate {
                id: appDelegate
                visualIndex: delegateRoot.visualIndex
                
                isFolder: false
                application: model.application
                
                menuActions: [
                    Kirigami.Action {
                        iconName: "emblem-favorite"
                        text: i18n("Remove from favourites")
                        onTriggered: root.folder.removeApp(model.index)
                    },
                    Kirigami.Action {
                        iconName: "document-open-folder"
                        text: i18n("Move out of folder")
                        onTriggered: root.folder.moveAppOut(model.index)
                    }
                ]
                
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
