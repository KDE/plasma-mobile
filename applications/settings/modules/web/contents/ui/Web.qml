// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.active.settings 0.1 as ActiveSettings

Item {
    id: webModule
    objectName: "webModule"

    width: 800; height: 500

    PlasmaCore.Theme {
        id: theme
    }

    Column {
        id: titleCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        PlasmaExtras.Title {
            text: settingsComponent.name
            opacity: 1
        }
        PlasmaComponents.Label {
            id: descriptionLabel
            text: settingsComponent.description
            opacity: .4
        }
    }

    ActiveSettings.ConfigGroup {
        id: browserConfig
        file: "active-webbrowserrc"
        group: "webbrowser"
    }

    ActiveSettings.ConfigGroup {
        id: historyConfig
        file: "active-webbrowserrc"
        group: "history"
    }

    ActiveSettings.ConfigGroup {
        id: adblockConfig
        file: "active-webbrowserrc"
        group: "adblock"
    }


    Item {
        id: fontSizeItem
        anchors { top: titleCol.bottom; left: parent.left; right: parent.right; topMargin: 32; }

        PlasmaComponents.Label {
            anchors { right: parent.horizontalCenter; verticalCenter: parent.verticalCenter; rightMargin: 12; }
            text: i18n("Text size:")
        }

        PlasmaCore.FrameSvgItem {
            id: fontPreviewFrame
            z: 100
            height: fontPreviewLabel.paintedHeight+24
            width: fontPreviewLabel.paintedWidth+54
            opacity: 0
            anchors { bottom: fontSizeSlider.top; horizontalCenter: fontSizeSlider.horizontalCenter; }
            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
            imagePath: "dialogs/background"
            PlasmaComponents.Label {
                z: 100
                anchors { centerIn: parent; leftMargin: 12; rightMargin: 12; }
                id: fontPreviewLabel
                text: i18n("Ceci n'est pas un exemple.");
                font.pointSize: theme.defaultFont.pointSize + fontSizeSlider.value
            }
            PlasmaCore.SvgItem {
                svg: PlasmaCore.Svg {
                    id: backgroundSvg
                    imagePath: "dialogs/background"
                }
                elementId: "baloon-tip-bottom"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.bottom
                    topMargin: -backgroundSvg.elementSize("hint-bottom-shadow").height

                }
                width: naturalSize.width
                height: naturalSize.height
            }
        }

        Timer {
            id: fontPreviewTimer
            interval: 2500
            running: false
            repeat: false
            onTriggered: fontPreviewFrame.opacity = 0

        }

        PlasmaComponents.Slider {
            id: fontSizeSlider
            minimumValue: -6
            maximumValue: 24
            stepSize: 1
            anchors { left: parent.horizontalCenter; right: parent.right; verticalCenter: parent.verticalCenter; }
            Component.onCompleted: {
                var fontSizeCorrection = parseFloat(browserConfig.readEntry("fontSizeCorrection"));
                if (fontSizeCorrection > 0) {
                    value = fontSizeCorrection;
                }
            }
            onValueChanged: {
                var s = theme.defaultFont.pointSize + fontSizeSlider.value;
                browserConfig.writeEntry("fontSizeCorrection", fontSizeSlider.value);
                //fontPreviewTimer.restart();
            }
            onPressedChanged: {
                if (!pressed) {
                    fontPreviewTimer.running = true;
                } else {
                    fontPreviewFrame.opacity = 1;
                    fontPreviewTimer.running = false;
                    if (settingsItem) { 
                        // when running in the webbrowser, we want to prevent clipping
                        // of the pagestack, but only as long as the preview is shown.
                        settingsItem.clip = false;
                    }
                }
                if (!pressed || (pressed && fontPreviewTimer.running)) {
                    fontPreviewTimer.restart();
                }
            }
        }
    }

    Item {
        id: startPageItem
        anchors { top: fontSizeItem.bottom; left: parent.left; right: parent.right; topMargin: 48; }

        PlasmaComponents.Label {
            anchors { right: parent.horizontalCenter; verticalCenter: parent.verticalCenter; rightMargin: 12; }
            text: i18n("Start page:")
        }

        PlasmaComponents.TextField {
            id: startPageText
            clearButtonShown: true
            placeholderText: i18n("Show dashboard")
            text: "http://plasma-active.org"
            anchors { left: parent.horizontalCenter; right: parent.right; verticalCenter: parent.verticalCenter; }
            Keys.onReturnPressed: closeSoftwareInputPanel()
            Component.onCompleted: text = browserConfig.readEntry("startPage");
            onTextChanged: startPageTimer.restart()
            Timer {
                id: startPageTimer
                interval: 1000
                running: false
                repeat: false
                onTriggered: { print("sv"); browserConfig.writeEntry("startPage", startPageText.text); }
            }
        }
    }

    Item {
        id: adblockItem
        anchors { top: startPageItem.bottom; left: parent.left; right: parent.right; topMargin: 48; }

        PlasmaComponents.Label {
            anchors { right: parent.horizontalCenter; verticalCenter: parent.verticalCenter; rightMargin: 12; }
            text: i18n("Block ads:")
        }

        PlasmaComponents.Switch {
            checked: true
            anchors { left: parent.horizontalCenter; verticalCenter: parent.verticalCenter; }
            onClicked: adblockConfig.writeEntry("adBlockEnabled", checked);
            Component.onCompleted: {
                checked = adblockConfig.readEntry("adBlockEnabled");
                print(" adblock checked: " + checked);
            }
        }

    }

    Item {
        id: pluginsItem
        anchors { top: adblockItem.bottom; left: parent.left; right: parent.right; topMargin: 48; }

        PlasmaComponents.Label {
            anchors { right: parent.horizontalCenter; verticalCenter: parent.verticalCenter; rightMargin: 12; }
            text: i18n("Enable plugins:")
        }

        PlasmaComponents.Switch {
            checked: true
            property string configKey: "pluginsEnabled"
            anchors { left: parent.horizontalCenter; verticalCenter: parent.verticalCenter; }
            onClicked: browserConfig.writeEntry(configKey, checked);
            Component.onCompleted: {
                checked = browserConfig.readEntry(configKey);
                print(" plugins enabled: " + configKey + " :: " + checked);
            }
        }

    }

    Item {
        id: mobileItem
        anchors { top: pluginsItem.bottom; left: parent.left; right: parent.right; topMargin: 48; }

        PlasmaComponents.Label {
            anchors { right: parent.horizontalCenter; verticalCenter: parent.verticalCenter; rightMargin: 12; }
            text: i18n("Prefer mobile websites:")
        }

        PlasmaComponents.Switch {
            checked: true
            property string configKey: "preferMobile"
            anchors { left: parent.horizontalCenter; verticalCenter: parent.verticalCenter; }
            onClicked: browserConfig.writeEntry(configKey, checked);
            Component.onCompleted: {
                checked = browserConfig.readEntry(configKey, true);
                print("prefer mobile websites: " + configKey + " :: " + checked);
            }
        }

    }

    PlasmaComponents.Button {
        text: i18n("Clear history")
        anchors { left: parent.horizontalCenter; top: mobileItem.bottom; topMargin: 32; }
        onClicked: historyConfig.writeEntry("history", []);
    }

    Component.onCompleted: {
        print("Web.qml done loading.");
    }
}
