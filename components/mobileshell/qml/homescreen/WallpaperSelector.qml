// SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2022-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as Controls

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.wallpapers.image 2.0 as Wallpaper
import org.kde.kquickcontrolsaddons 2.0 as Addons
import org.kde.plasma.private.mobileshell.wallpaperimageplugin as WallpaperImagePlugin

Controls.Drawer {
    id: imageWallpaperDrawer
    dragMargin: 0

    required property bool horizontal

    signal wallpaperSettingsRequested()

    onOpened: {
        wallpapersView.forceActiveFocus()
    }

    implicitWidth: Kirigami.Units.gridUnit * 10
    implicitHeight: Kirigami.Units.gridUnit * 8
    width: imageWallpaperDrawer.horizontal ? implicitWidth : parent.width
    height: imageWallpaperDrawer.horizontal ? parent.height : implicitHeight

    Wallpaper.ImageBackend {
        id: imageWallpaper
    }

    background: null

    ListView {
        id: wallpapersView
        anchors.fill: parent
        anchors.leftMargin: imageWallpaperDrawer.leftMargin
        anchors.rightMargin: imageWallpaperDrawer.rightMargin
        anchors.bottomMargin: imageWallpaperDrawer.bottomMargin
        orientation: imageWallpaperDrawer.horizontal ? ListView.Vertical : ListView.Horizontal
        keyNavigationEnabled: true
        highlightFollowsCurrentItem: true
        snapMode: ListView.SnapToItem
        model: imageWallpaper.wallpaperModel
        // onCountChanged: currentIndex =  Math.min(model.indexOf(configDialog.wallpaperConfiguration["Image"]), model.rowCount()-1)
        headerPositioning: ListView.InlineHeader

        header: Controls.ItemDelegate {
            id: openSettings
            width: imageWallpaperDrawer.horizontal ? parent.width : height * (imageWallpaperDrawer.width / imageWallpaperDrawer.Screen.height)
            height: imageWallpaperDrawer.horizontal ? width / (imageWallpaperDrawer.Screen.width / imageWallpaperDrawer.Screen.height) : parent.height
            padding: Kirigami.Units.gridUnit / 2
            leftPadding: padding
            topPadding: padding
            rightPadding: padding
            bottomPadding: padding

            background: Rectangle {
                color: Qt.rgba(255, 255, 255, (openSettings.down || openSettings.highlighted) ? 0.3 : 0.2)
                radius: Kirigami.Units.gridUnit / 4
                anchors.fill: parent
                anchors.margins: Kirigami.Units.gridUnit / 4
            }

            contentItem: Item {
                Kirigami.Icon {
                    anchors.centerIn: parent
                    implicitHeight: Kirigami.Units.iconSizes.large
                    implicitWidth: Kirigami.Units.iconSizes.large
                    source: 'list-add'
                }
            }

            onClicked: imageWallpaperDrawer.wallpaperSettingsRequested()
            Keys.onReturnPressed: clicked();
        }

        delegate: Controls.ItemDelegate {
            width: imageWallpaperDrawer.horizontal ? parent.width : height * (imageWallpaperDrawer.width / imageWallpaperDrawer.Screen.height)
            height: imageWallpaperDrawer.horizontal ? width / (imageWallpaperDrawer.Screen.width / imageWallpaperDrawer.Screen.height) : parent.height
            padding: wallpapersView.currentIndex === index ? Kirigami.Units.gridUnit / 4 : Kirigami.Units.gridUnit / 2
            leftPadding: padding
            topPadding: padding
            rightPadding: padding
            bottomPadding: padding
            Behavior on padding {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }

            property bool isCurrent: WallpaperImagePlugin.WallpaperPlugin.homescreenWallpaperPath == model.path
            onIsCurrentChanged: {
                if (isCurrent) {
                    wallpapersView.currentIndex = index;
                }
            }

            z: wallpapersView.currentIndex === index ? 2 : 0
            contentItem: Item {
                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.large
                    height: width
                    source: "view-preview"
                    visible: !walliePreview.visible
                }

                Addons.QPixmapItem {
                    id: walliePreview
                    visible: model.screenshot != null
                    anchors.fill: parent
                    smooth: true
                    pixmap: model.screenshot
                    fillMode: Image.PreserveAspectCrop
                }
            }
            onClicked: {
                WallpaperImagePlugin.WallpaperPlugin.setHomescreenWallpaper(model.path);
            }
            Keys.onReturnPressed: {
                clicked();
            }
            background: Item {
                Rectangle {
                    anchors {
                        fill: parent
                        margins: wallpapersView.currentIndex === index ? 0 : Kirigami.Units.gridUnit / 4
                        Behavior on margins {
                            NumberAnimation {
                                duration: Kirigami.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                    radius: Kirigami.Units.gridUnit / 4
                }
            }
        }
    }
}
