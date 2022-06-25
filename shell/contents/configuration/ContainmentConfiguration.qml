// SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2
import QtQuick.Controls 2.15 as Controls

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.configuration 2.0

AppletConfiguration {
    id: root
    isContainment: true
    loadApp: false

    readonly property bool horizontal: root.width > root.height

    onAppLoaded: {
        app.width = root.width < root.height ? root.width : Math.min(root.width, Math.max(app.implicitWidth, PlasmaCore.Units.gridUnit * 45));
        app.height = Math.min(root.height, Math.max(app.implicitHeight, PlasmaCore.Units.gridUnit * 29));
    }
    
//BEGIN model
    globalConfigModel: globalContainmentConfigModel

    ConfigModel {
        id: globalContainmentConfigModel
        ConfigCategory {
            name: i18nd("plasma_shell_org.kde.plasma.desktop", "Wallpaper")
            icon: "preferences-desktop-wallpaper"
            source: "ConfigurationContainmentAppearance.qml"
        }
    }
//END model

    // the wallpaper selector is quite heavy, so only load it when needed
    Loader {
        id: wallpaperSelectorLoader
        asynchronous: true
        active: false
        
        onLoaded: {
            wallpaperSelectorLoader.item.open();
        }
        
        sourceComponent: WallpaperSelector {
            visible: false
            horizontal: root.horizontal
        }
    }
    
    MouseArea {
        z: -1
        anchors.fill: parent
        onClicked: configDialog.close()
        
        Controls.Control {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: PlasmaCore.Units.largeSpacing
            
            leftPadding: PlasmaCore.Units.largeSpacing
            rightPadding: PlasmaCore.Units.largeSpacing
            topPadding: PlasmaCore.Units.largeSpacing
            bottomPadding: PlasmaCore.Units.largeSpacing
            
            NumberAnimation on opacity {
                id: opacityAnim
                running: true
                from: 0
                to: 1
                duration: PlasmaCore.Units.longDuration
            }
            
            background: PlasmaCore.FrameSvgItem {
                enabledBorders: PlasmaCore.FrameSvg.AllBorders
                imagePath: "widgets/background"
            }
            
            contentItem: RowLayout {
                PlasmaComponents3.Button {
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredHeight: PlasmaCore.Units.gridUnit * 4
                    Layout.preferredWidth: PlasmaCore.Units.gridUnit * 8
                    
                    display: PlasmaComponents3.ToolButton.TextUnderIcon
                    icon.name: "viewimage"
                    icon.width: PlasmaCore.Units.iconSizes.medium
                    icon.height: PlasmaCore.Units.iconSizes.medium
                    text: i18n("Change Wallpaper")
                    onClicked: {
                        opacityAnim.from = 1;
                        opacityAnim.to = 0;
                        opacityAnim.restart();
                        wallpaperSelectorLoader.active = true;
                    }
                }
                
                PlasmaComponents3.Button {
                    Layout.alignment: Qt.AlignLeft
                    Layout.preferredHeight: PlasmaCore.Units.gridUnit * 4
                    Layout.preferredWidth: PlasmaCore.Units.gridUnit * 8
                    
                    display: PlasmaComponents3.ToolButton.TextUnderIcon
                    icon.name: "configure"
                    icon.width: PlasmaCore.Units.iconSizes.medium
                    icon.height: PlasmaCore.Units.iconSizes.medium
                    text: i18n("Configure")
                    onClicked: {
                        root.loadApp = true;
                    }
                }
            }
        }
    }
}
