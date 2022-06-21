/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

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

MobileShell.ExtendedAbstractButton {
    id: delegate
    width: GridView.view.cellWidth
    height: GridView.view.cellHeight

    property int reservedSpaceForLabel
    property alias iconItem: icon

    signal launch(int x, int y, var source, string title, string storageId)
    signal dragStarted(string imageSource, int x, int y, string mimeData)

    function launchApp() {
        // launch app
        if (model.applicationRunning) {
            delegate.launch(0, 0, "", model.applicationName, model.applicationStorageId);
        } else {
            delegate.launch(delegate.x + (PlasmaCore.Units.smallSpacing * 2), delegate.y + (PlasmaCore.Units.smallSpacing * 2), icon.source, model.applicationName, model.applicationStorageId);
        }
    }
    
    onPressAndHold: {
        delegate.grabToImage(function(result) {
            delegate.Drag.imageSource = result.url
            dragStarted(result.url, width/2, height/2, model.applicationStorageId)
        })
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

    //preventStealing: true
    ColumnLayout {
        anchors {
            fill: parent
            leftMargin: PlasmaCore.Units.smallSpacing * 2
            topMargin: PlasmaCore.Units.smallSpacing * 2
            rightMargin: PlasmaCore.Units.smallSpacing * 2
            bottomMargin: PlasmaCore.Units.smallSpacing * 2
        }
        spacing: 0

        PlasmaCore.IconItem {
            id: icon

            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillWidth: true
            Layout.minimumHeight: parent.height - delegate.reservedSpaceForLabel
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
            
            // darken effect when hovered/pressed
            layer {
                enabled: delegate.pressed || delegate.hovered
                effect: ColorOverlay {
                    color: Qt.rgba(0, 0, 0, 0.3)
                }
            }
        }

        PlasmaComponents.Label {
            id: label
            visible: text.length > 0

            Layout.fillWidth: true
            Layout.preferredHeight: delegate.reservedSpaceForLabel
            Layout.topMargin: PlasmaCore.Units.smallSpacing
            Layout.leftMargin: -parent.anchors.leftMargin + PlasmaCore.Units.smallSpacing * 2
            Layout.rightMargin: -parent.anchors.rightMargin + PlasmaCore.Units.smallSpacing * 2
            
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            elide: Text.ElideRight

            text:  model.applicationName

            font.pointSize: theme.defaultFont.pointSize * 0.8
            font.weight: Font.Bold
            color: "white"
        }
    }
}

