// SPDX-FileCopyrightText: 2022 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as Controls
import QtGraphicalEffects 1.6

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState
import org.kde.phone.homescreen.halcyon 1.0 as Halcyon

import org.kde.kirigami 2.19 as Kirigami

Item {
    id: delegate
    property int visualIndex: 0
    
    property real leftPadding
    property real rightPadding
    
    property real dragFolderAnimationProgress: 0
    
    property list<Kirigami.Action> menuActions
    
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
    
    property alias drag: mouseArea.drag
    Drag.active: delegate.drag.active
    Drag.source: delegate
    Drag.hotSpot.x: delegate.width / 2
    Drag.hotSpot.y: delegate.height / 2
    
    // close context menu if drag move
    onXChanged: {
        if (dialogLoader.item) {
            dialogLoader.item.close()
        }
    }
    onYChanged: {
        if (dialogLoader.item) {
            dialogLoader.item.close()
        }
    }
    
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
            MobileShellState.Shell.openAppLaunchAnimation(
                    source,
                    title,
                    iconLoader.Kirigami.ScenePosition.x + iconLoader.width/2,
                    iconLoader.Kirigami.ScenePosition.y + iconLoader.height/2,
                    Math.min(iconLoader.width, iconLoader.height));
        }

        application.setMinimizedDelegate(delegate);
        MobileShell.ShellUtil.launchApp(application.storageId);
    }
    
    Loader {
        id: dialogLoader
        active: false
        
        sourceComponent: PlasmaComponents.Menu {
            id: menu
            title: label.text
            closePolicy: PlasmaComponents.Menu.CloseOnReleaseOutside | PlasmaComponents.Menu.CloseOnEscape
            
            Repeater {
                model: menuActions
                delegate: PlasmaComponents.MenuItem {
                    icon.name: modelData.iconName
                    text: modelData.text
                    onClicked: modelData.triggered()
                }
            }
            
            onClosed: dialogLoader.active = false
        }
    }
    
    MouseArea {
        id: mouseArea
        
        anchors.fill: parent
        anchors.leftMargin: delegate.leftPadding
        anchors.rightMargin: delegate.rightPadding
        
        property bool inDrag: false
    
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onReleased: {
            delegate.Drag.drop();
            inDrag = false;
        }
        onPressAndHold: { inDrag = true; openContextMenu() }
        drag.target: inDrag ? delegate : undefined
        
        // grow/shrink animation
        property real zoomScale: 1
        transform: Scale { 
            origin.x: mouseArea.width / 2; 
            origin.y: mouseArea.height / 2; 
            xScale: mouseArea.zoomScale
            yScale: mouseArea.zoomScale
        }
        
        property bool launchAppRequested: false
        
        NumberAnimation on zoomScale {
            id: shrinkAnim
            running: false
            duration: MobileShell.MobileShellSettings.animationsEnabled ? 80 : 1
            to: MobileShell.MobileShellSettings.animationsEnabled ? 0.95 : 1
            onFinished: {
                if (!mouseArea.pressed) {
                    growAnim.restart();
                }
            }
        }
        
        NumberAnimation on zoomScale {
            id: growAnim
            running: false
            duration: MobileShell.MobileShellSettings.animationsEnabled ? 80 : 1
            to: 1
            onFinished: {
                if (mouseArea.launchAppRequested) {
                    delegate.launch();
                    mouseArea.launchAppRequested = false;
                }
            }
        }
        
        onPressedChanged: {
            if (pressed) {
                growAnim.stop();
                shrinkAnim.restart();
            } else if (!pressed && !shrinkAnim.running) {
                growAnim.restart();
            }
        }
        
        // launch app handled by press animation
        onClicked: (mouse.button === Qt.RightButton) ? openContextMenu() : launchAppRequested = true;
        
        HoverHandler {
            id: hoverHandler
            acceptedDevices: PointerDevice.Mouse
            acceptedPointerTypes: PointerDevice.GenericPointer
        }
        
        Rectangle {
            anchors.fill: parent
            radius: height / 2        
            color: mouseArea.pressed ? Qt.rgba(255, 255, 255, 0.2) : "transparent"
        }
        
        RowLayout {
            id: rowLayout
            anchors {
                fill: parent
                leftMargin: PlasmaCore.Units.smallSpacing * 2
                topMargin: PlasmaCore.Units.smallSpacing
                rightMargin: PlasmaCore.Units.smallSpacing * 2
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
                textFormat: Text.MarkdownText

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
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                Layout.preferredHeight: Kirigami.Units.iconSizes.small

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
        
        Item {
            Rectangle {
                anchors.fill: parent
                anchors.margins: PlasmaCore.Units.smallSpacing
                color: Qt.rgba(255, 255, 255, 0.2)
                radius: PlasmaCore.Units.smallSpacing
                opacity: delegate.dragFolderAnimationProgress
            }
            
            PlasmaCore.IconItem {
                id: icon
                anchors.fill: parent
                usesPlasmaTheme: false
                source: delegate.isFolder ? 'document-open-folder' : delegate.applicationIcon
                
                transform: Scale { 
                    origin.x: icon.width / 2 
                    origin.y: icon.height / 2
                    xScale: 1 - delegate.dragFolderAnimationProgress * 0.5
                    yScale: 1 - delegate.dragFolderAnimationProgress * 0.5
                }

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
    }
    
    Component {
        id: folderIconComponent
        
        Item {
            Rectangle {
                id: rect
                anchors.fill: parent
                anchors.margins: PlasmaCore.Units.smallSpacing
                color: Qt.rgba(255, 255, 255, 0.2)
                radius: PlasmaCore.Units.smallSpacing
                
                transform: Scale { 
                    origin.x: rect.width / 2 
                    origin.y: rect.height / 2
                    xScale: 1 + delegate.dragFolderAnimationProgress * 0.5
                    yScale: 1 + delegate.dragFolderAnimationProgress * 0.5
                }
            }
            
            Grid {
                id: grid
                anchors.fill: parent
                anchors.margins: PlasmaCore.Units.smallSpacing * 2
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



