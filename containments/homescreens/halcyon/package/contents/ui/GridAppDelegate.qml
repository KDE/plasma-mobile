/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as Controls
import QtGraphicalEffects 1.6

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import org.kde.kirigami 2.19 as Kirigami

MouseArea {
    id: delegate
    width: GridView.view.cellWidth
    height: GridView.view.cellHeight

    property int reservedSpaceForLabel
    property alias iconItem: icon

    readonly property real margins: Math.floor(width * 0.2)

    signal launch(int x, int y, var source, string title, string storageId)
    
    onPressAndHold: {
        dialogLoader.active = true;
        dialogLoader.item.open();
    }
    
    function launchApp() {
        // launch app
        if (model.applicationRunning) {
            delegate.launch(0, 0, "", model.applicationName, model.applicationStorageId);
        } else {
            delegate.launch(delegate.x + (PlasmaCore.Units.smallSpacing * 2), delegate.y + (PlasmaCore.Units.smallSpacing * 2), icon.source, model.applicationName, model.applicationStorageId);
        }
    }
    
    Loader {
        id: dialogLoader
        active: false
        
        sourceComponent: PlasmaComponents.Menu {
            title: label.text
            
            PlasmaComponents.MenuItem {
                icon.name: "emblem-favorite"
                text: i18n("Add to favourites")
                onClicked: {
                    MobileShell.FavoritesModel.addFavorite(model.applicationStorageId, 0, MobileShell.ApplicationListModel.Favorites);
                }
            }
            onClosed: dialogLoader.active = false
        }
    }

    // grow/shrink animation
    property real zoomScale: 1
    transform: Scale { 
        origin.x: delegate.width / 2; 
        origin.y: delegate.height / 2; 
        xScale: delegate.zoomScale
        yScale: delegate.zoomScale
    }
    
    property bool launchAppRequested: false
    
    NumberAnimation on zoomScale {
        id: shrinkAnim
        running: false
        duration: MobileShell.MobileShellSettings.animationsEnabled ? 80 : 1
        to: MobileShell.MobileShellSettings.animationsEnabled ? 0.8 : 1
        onFinished: {
            if (!delegate.pressed) {
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
            if (delegate.launchAppRequested) {
                delegate.launchApp();
                delegate.launchAppRequested = false;
            }
        }
    }
    
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true
    onPressedChanged: {
        if (pressed) {
            growAnim.stop();
            shrinkAnim.restart();
        } else if (!pressed && !shrinkAnim.running) {
            growAnim.restart();
        }
    }
    // launch app handled by press animation
    onClicked: launchAppRequested = true;
    
    ColumnLayout {
        anchors {
            fill: parent
            leftMargin: margins
            topMargin: margins
            rightMargin: margins
            bottomMargin: margins
        }
        spacing: 0

        PlasmaCore.IconItem {
            id: icon

            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillWidth: true
            Layout.minimumHeight: Math.floor(parent.height - delegate.reservedSpaceForLabel)
            Layout.preferredHeight: Layout.minimumHeight

            usesPlasmaTheme: false
            source: model.applicationIcon

            Rectangle {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }
                visible: model.applicationRunning
                radius: width
                width: PlasmaCore.Units.smallSpacing
                height: width
                color: theme.highlightColor
            }
        }

        PlasmaComponents.Label {
            id: label
            visible: text.length > 0

            Layout.fillWidth: true
            Layout.topMargin: PlasmaCore.Units.smallSpacing
            Layout.preferredHeight: delegate.reservedSpaceForLabel
            wrapMode: Text.WordWrap
            Layout.leftMargin: -parent.anchors.leftMargin + PlasmaCore.Units.smallSpacing
            Layout.rightMargin: -parent.anchors.rightMargin + PlasmaCore.Units.smallSpacing
            maximumLineCount: 2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            elide: Text.ElideRight

            text: model.applicationName

            font.pointSize: theme.defaultFont.pointSize * 0.85
            font.weight: Font.Bold
            color: "white"
        }
    }
}


