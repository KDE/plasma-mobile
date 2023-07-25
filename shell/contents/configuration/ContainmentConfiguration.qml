// SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2
import QtQuick.Controls 2.15 as Controls

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.configuration 2.0

AppletConfiguration {
    id: root
    isContainment: true
    loadApp: false

    readonly property bool horizontal: root.width > root.height

    onAppLoaded: {
        app.width = root.width < root.height ? root.width : Math.min(root.width, Math.max(app.implicitWidth, Kirigami.Units.gridUnit * 45));
        app.height = Math.min(root.height, Math.max(app.implicitHeight, Kirigami.Units.gridUnit * 29));
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
            edge: root.horizontal ? Qt.LeftEdge : Qt.BottomEdge
            onClosed: configDialog.close()
        }
    }
    
    MouseArea {
        z: -1
        anchors.fill: parent
        onClicked: configDialog.close()
        
        Controls.Control {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: Kirigami.Units.gridUnit
            
            leftPadding: Kirigami.Units.gridUnit
            rightPadding: Kirigami.Units.gridUnit
            topPadding: Kirigami.Units.gridUnit
            bottomPadding: Kirigami.Units.gridUnit
            
            NumberAnimation on opacity {
                id: opacityAnim
                running: true
                from: 0
                to: 1
                duration: Kirigami.Units.longDuration
            }
            
            background: KSvg.FrameSvgItem {
                enabledBorders: PlasmaCore.FrameSvg.AllBorders
                imagePath: "widgets/background"
            }
            
            contentItem: RowLayout {
                PlasmaComponents3.Button {
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 8
                    
                    display: PlasmaComponents3.ToolButton.TextUnderIcon
                    icon.name: "viewimage"
                    icon.width: Kirigami.Units.iconSizes.medium
                    icon.height: Kirigami.Units.iconSizes.medium
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
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 8
                    
                    display: PlasmaComponents3.ToolButton.TextUnderIcon
                    icon.name: "configure"
                    icon.width: Kirigami.Units.iconSizes.medium
                    icon.height: Kirigami.Units.iconSizes.medium
                    text: i18n("Configure")
                    onClicked: {
                        root.loadApp = true;
                    }
                }
            }
        }
    }
}
