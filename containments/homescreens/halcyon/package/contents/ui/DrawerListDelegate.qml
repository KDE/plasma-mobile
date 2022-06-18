// SPDX-FileCopyrightText: 2022 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.4
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
    
    property alias iconItem: icon
    property Halcyon.Application application: model.application
    
    readonly property string applicationName: application ? application.name : ""
    readonly property string applicationStorageId: application ? application.storageId : ""
    readonly property string applicationIcon: application ? application.icon : ""
    
    signal launch(int x, int y, var source, string title, string storageId)
    signal dragStarted(string imageSource, int x, int y, string mimeData)

    onLaunch: {
         if (icon !== "") {
            MobileShell.HomeScreenControls.openAppLaunchAnimation(
                    icon,
                    title,
                    delegate.iconItem.Kirigami.ScenePosition.x + delegate.iconItem.width/2,
                    delegate.iconItem.Kirigami.ScenePosition.y + delegate.iconItem.height/2,
                    Math.min(delegate.iconItem.width, delegate.iconItem.height));
        }

        application.setMinimizedDelegate(delegate);
        application.runApplication();
    }
    
    onPressAndHold: {
        dialogLoader.active = true;
        dialogLoader.item.open();
    }

    onClicked: {
        // launch app
        if (application.running) {
            delegate.launch(0, 0, "", applicationName, applicationStorageId);
        } else {
            delegate.launch(delegate.x + (PlasmaCore.Units.smallSpacing * 2), delegate.y + (PlasmaCore.Units.smallSpacing * 2), icon.source, applicationName, applicationStorageId);
        }
    }
    hoverEnabled: true
    
    Loader {
        id: dialogLoader
        active: false
        
        sourceComponent: PlasmaComponents.Menu {
            title: label.text
            
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
    
    Rectangle {
        anchors.fill: parent
        
        radius: height / 2
        
        color: delegate.pressed ? Qt.rgba(255, 255, 255, 0.2) : (delegate.containsMouse ? Qt.rgba(255, 255, 255, 0.1) : "transparent")
    }
    
    RowLayout {
        anchors {
            fill: parent
            leftMargin: PlasmaCore.Units.smallSpacing * 2
            topMargin: PlasmaCore.Units.smallSpacing
            rightMargin: PlasmaCore.Units.smallSpacing * 2
            bottomMargin: PlasmaCore.Units.smallSpacing
        }
        spacing: 0

        PlasmaCore.IconItem {
            id: icon

            Layout.alignment: Qt.AlignLeft
            Layout.minimumWidth: Layout.minimumHeight
            Layout.preferredWidth: Layout.minimumHeight
            Layout.minimumHeight: parent.height
            Layout.preferredHeight: Layout.minimumHeight

            usesPlasmaTheme: false
            source: applicationIcon

            Rectangle {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }
                visible: application.running
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

        PlasmaComponents.Label {
            id: label
            visible: text.length > 0

            Layout.fillWidth: true
            Layout.leftMargin: PlasmaCore.Units.smallSpacing * 2
            Layout.rightMargin: PlasmaCore.Units.largeSpacing
            wrapMode: Text.WordWrap
            maximumLineCount: 1
            elide: Text.ElideRight

            text: applicationName

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
    }
}



