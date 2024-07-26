// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.private.mobile.homescreen.folio 1.0 as Folio

import '../delegate'

Item {
    id: root
    property Folio.HomeScreen folio

    property var homeScreen
    property real settingsModeHomeScreenScale

    readonly property bool homeScreenInteractive: !appletListViewer.open

    Connections {
        target: folio.HomeScreenState

        // Close applet viewer when settings view closes
        function onViewStateChanged() {
            if (folio.HomeScreenState.viewState !== Folio.HomeScreenState.SettingsView) {
                appletListViewer.requestClose();
            }
        }
    }

    MouseArea {
        id: closeSettings

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: settingsBar.top

        onClicked: {
            folio.HomeScreenState.closeSettingsView();
        }
    }

    Item {
        id: settingsBar

        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Kirigami.Units.largeSpacing
        height: root.height * (1 - settingsModeHomeScreenScale)

        RowLayout {
            id: settingsOptions
            anchors.centerIn: parent
            spacing: Kirigami.Units.largeSpacing

            PC3.ToolButton {
                opacity: 0.9
                implicitHeight: Kirigami.Units.gridUnit * 4
                implicitWidth: Kirigami.Units.gridUnit * 5

                contentItem: ColumnLayout {
                    spacing: Kirigami.Units.largeSpacing

                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                        implicitWidth: Kirigami.Units.iconSizes.smallMedium
                        implicitHeight: Kirigami.Units.iconSizes.smallMedium
                        source: 'edit-image'
                    }

                    QQC2.Label {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                        text: i18n('Wallpapers')
                        font.bold: true
                    }
                }

                onClicked: {
                    wallpaperSelectorLoader.active = true;
                    folio.HomeScreenState.closeSettingsView();
                }
            }

            PC3.ToolButton {
                opacity: 0.9
                implicitHeight: Kirigami.Units.gridUnit * 4
                implicitWidth: Kirigami.Units.gridUnit * 5

                contentItem: ColumnLayout {
                    spacing: Kirigami.Units.largeSpacing

                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                        implicitWidth: Kirigami.Units.iconSizes.smallMedium
                        implicitHeight: Kirigami.Units.iconSizes.smallMedium
                        source: 'settings-configure'
                    }

                    QQC2.Label {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                        text: i18n('Settings')
                        font.bold: true
                    }
                }

                onClicked: {
                    // ensure that if the window is already opened, it gets raised to the top
                    settingsWindow.hide();
                    settingsWindow.showMaximized();
                }
            }

            PC3.ToolButton {
                opacity: 0.9
                implicitHeight: Kirigami.Units.gridUnit * 4
                implicitWidth: Kirigami.Units.gridUnit * 5

                contentItem: ColumnLayout {
                    spacing: Kirigami.Units.largeSpacing

                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                        implicitWidth: Kirigami.Units.iconSizes.smallMedium
                        implicitHeight: Kirigami.Units.iconSizes.smallMedium
                        source: 'widget-alternatives'
                    }

                    QQC2.Label {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                        text: i18n('Widgets')
                        font.bold: true
                    }
                }

                onClicked: {
                    appletListViewer.open = true;
                }
            }
        }
    }

    AppletListViewer {
        id: appletListViewer
        folio: root.folio
        width: parent.width
        height: parent.height

        property bool open: false
        onRequestClose: open = false

        opacity: open ? 1 : 0

        // move the settings out of the way if it is not visible
        // NOTE: we do this instead of setting visible to false, because
        //       it doesn't mess with widget drag and drop
        y: (opacity === 0) ? appletListViewer.height : 0

        homeScreen: root.homeScreen

        Behavior on opacity {
            NumberAnimation { duration: Kirigami.Units.shortDuration }
        }
    }

    SettingsWindow {
        id: settingsWindow
        folio: root.folio
        visible: false

        onRequestConfigureMenu: {
            homeScreen.openConfigure()
        }
    }

    Loader {
        id: wallpaperSelectorLoader
        asynchronous: true
        active: false

        onLoaded: {
            wallpaperSelectorLoader.item.open();
        }

        sourceComponent: MobileShell.WallpaperSelector {
            horizontal: root.width > root.height
            edge: horizontal ? Qt.LeftEdge : Qt.BottomEdge
            bottomMargin: root.homeScreen.bottomMargin
            leftMargin: root.homeScreen.leftMargin
            rightMargin: root.homeScreen.rightMargin
            onClosed: {
                wallpaperSelectorLoader.active = false;
            }

            onWallpaperSettingsRequested: {
                close();
                homeScreen.openConfigure();
            }
        }
    }
}
