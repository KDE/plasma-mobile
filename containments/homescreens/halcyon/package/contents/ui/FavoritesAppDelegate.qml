// SPDX-FileCopyrightText: 2022 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as Controls
import QtGraphicalEffects 1.6

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.phone.homescreen.halcyon 1.0 as Halcyon

import org.kde.kirigami 2.19 as Kirigami

MouseArea {
    id: delegate
    property int visualIndex: 0
    
    property real leftPadding
    property real rightPadding
    
    // whether this delegate is a folder
    property bool isFolder
    
    // folder object
    property var folder
    readonly property string folderName: folder ? folder.name : ""
    
    // app object
    property var application
    readonly property string applicationName: application ? application.name : ""
    readonly property string applicationStorageId: application ? application.storageId : ""
    readonly property string applicationIcon: application ? application.icon : ""
    
    signal folderOpenRequested()
    
    function openContextMenu() {
        dialogLoader.active = true;
        dialogLoader.item.open();
    }
    
    function launch() {
        if (isFolder) {
            folderOpenRequested();
        } else {
            if (application.running) {
                launchAppWithAnim(0, 0, "", applicationName, applicationStorageId);
            } else {
                launchAppWithAnim(delegate.x + (PlasmaCore.Units.smallSpacing * 2), delegate.y + (PlasmaCore.Units.smallSpacing * 2), iconLoader.source, applicationName, applicationStorageId);
            }
        }
    }
    
    function launchAppWithAnim(x: int, y: int, source, title: string, storageId: string) {
         if (source !== "") {
            MobileShell.HomeScreenControls.openAppLaunchAnimation(
                    source,
                    title,
                    iconLoader.Kirigami.ScenePosition.x + iconLoader.width/2,
                    iconLoader.Kirigami.ScenePosition.y + iconLoader.height/2,
                    Math.min(iconLoader.width, iconLoader.height));
        }

        application.setMinimizedDelegate(delegate);
        application.runApplication();
    }
    
    property bool inDrag: false
    
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: (mouse.button === Qt.RightButton) ? openContextMenu() : launch();
    onReleased: {
        parent.Drag.drop();
        inDrag = false;
    }
    onPressAndHold: { inDrag = true; openContextMenu() }
    
    drag.target: inDrag ? delegate : undefined
    Drag.active: delegate.drag.active
    Drag.source: delegate
    Drag.hotSpot.x: delegate.width / 2
    Drag.hotSpot.y: delegate.height / 2
    
    HoverHandler {
        id: hoverHandler
        acceptedDevices: PointerDevice.Mouse
        acceptedPointerTypes: PointerDevice.GenericPointer
    }
    
    Loader {
        id: dialogLoader
        active: false
        
        sourceComponent: PlasmaComponents.Menu {
            title: label.text
            closePolicy: PlasmaComponents.Menu.CloseOnReleaseOutside | PlasmaComponents.Menu.CloseOnEscape
            
            PlasmaComponents.MenuItem {
                icon.name: "emblem-favorite"
                text: i18n("Remove from favourites")
                onClicked: {
                    Halcyon.PinnedModel.removeApp(model.index);
                }
            }
            onClosed: dialogLoader.active = false
        }
    }
    
    Item {
        id: baseItem
        anchors.fill: parent
        
        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: delegate.leftPadding
            anchors.rightMargin: delegate.rightPadding
            radius: height / 2        
            color: delegate.pressed ? Qt.rgba(255, 255, 255, 0.2) : (hoverHandler.hovered ? Qt.rgba(255, 255, 255, 0.1) : "transparent")
        }
        
        RowLayout {
            id: rowLayout
            anchors {
                fill: parent
                leftMargin: PlasmaCore.Units.smallSpacing * 2 + delegate.leftPadding
                topMargin: PlasmaCore.Units.smallSpacing
                rightMargin: PlasmaCore.Units.smallSpacing * 2 + delegate.rightPadding
                bottomMargin: PlasmaCore.Units.smallSpacing
            }
            spacing: 0

            Loader {
                id: iconLoader
                Layout.alignment: Qt.AlignLeft
                Layout.minimumWidth: Layout.minimumHeight
                Layout.preferredWidth: Layout.minimumHeight
                Layout.minimumHeight: parent.height
                Layout.preferredHeight: Layout.minimumHeight

                sourceComponent: delegate.isFolder ? folderIconComponent : appIconComponent
            }

            PlasmaComponents.Label {
                id: label
                visible: text.length > 0

                Layout.fillWidth: true
                Layout.leftMargin: PlasmaCore.Units.smallSpacing * 2
                Layout.rightMargin: PlasmaCore.Units.largeSpacing
                wrapMode: Text.WordWrap
                maximumLineCount: 1
                elide: Text.ElideRight

                text: delegate.isFolder ? delegate.folderName : delegate.applicationName

                font.pointSize: PlasmaCore.Theme.defaultFont.pointSize
                font.weight: Font.Bold
                color: "white"
                
                layer.enabled: true
                layer.effect: DropShadow {
                    verticalOffset: 1
                    radius: 4
                    samples: 6
                    color: Qt.rgba(0, 0, 0, 0.5)
                }
            }
            
            Kirigami.Icon {
                Layout.alignment: Qt.AlignRight
                Layout.minimumWidth: Layout.minimumHeight
                Layout.preferredWidth: Layout.minimumHeight
                Layout.minimumHeight: Math.round(parent.height * 0.5)
                Layout.preferredHeight: Layout.minimumHeight

                isMask: true
                color: 'white'
                source: 'arrow-right'
                visible: delegate.isFolder

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
    
    Component {
        id: appIconComponent
        
        PlasmaCore.IconItem {
            usesPlasmaTheme: false
            source: delegate.isFolder ? 'document-open-folder' : delegate.applicationIcon

            Rectangle {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }
                visible: application ? application.running : false
                radius: width
                width: PlasmaCore.Units.smallSpacing
                height: width
                color: PlasmaCore.Theme.highlightColor
            }
            
            layer.enabled: true
            layer.effect: DropShadow {
                verticalOffset: 1
                radius: 4
                samples: 6
                color: Qt.rgba(0, 0, 0, 0.5)
            }
        }
    }
    
    Component {
        id: folderIconComponent
        
        Item {
            Rectangle {
                anchors.fill: parent
                anchors.margins: PlasmaCore.Units.smallSpacing
                color: Qt.rgba(255, 255, 255, 0.2)
                radius: PlasmaCore.Units.smallSpacing
                
                Grid {
                    id: grid
                    anchors.fill: parent
                    anchors.margins: PlasmaCore.Units.smallSpacing
                    columns: 2
                    spacing: PlasmaCore.Units.smallSpacing
                    
                    property var previews: model.folder.appPreviews
                    
                    Repeater {
                        model: grid.previews
                        delegate: Kirigami.Icon {
                            implicitWidth: (grid.width - PlasmaCore.Units.smallSpacing) / 2
                            implicitHeight: (grid.width - PlasmaCore.Units.smallSpacing) / 2
                            source: modelData.icon
                            
                            layer.enabled: true
                            layer.effect: DropShadow {
                                verticalOffset: 1
                                radius: 4
                                samples: 3
                                color: Qt.rgba(0, 0, 0, 0.5)
                            }
                        }
                    }
                }
            }
        }
    }
}



