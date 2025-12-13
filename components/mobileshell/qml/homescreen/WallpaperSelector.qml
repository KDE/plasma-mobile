// SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2022-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as Controls

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.wallpapers.image 2.0 as Wallpaper
import org.kde.plasma.private.mobileshell.wallpaperimageplugin as WallpaperImagePlugin
import org.kde.plasma.private.mobileshell as MobileShell

Controls.Drawer {
    id: imageWallpaperDrawer
    dragMargin: 0

    property MobileShell.MaskManager maskManager

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
        headerPositioning: ListView.InlineHeader

        header: Controls.ItemDelegate {
            id: openSettings
            width: imageWallpaperDrawer.horizontal ? wallpapersView.width : height * (imageWallpaperDrawer.width / imageWallpaperDrawer.Screen.height)
            height: imageWallpaperDrawer.horizontal ? width / (imageWallpaperDrawer.Screen.width / imageWallpaperDrawer.Screen.height) : wallpapersView.height
            padding: Kirigami.Units.gridUnit / 2
            leftPadding: padding
            topPadding: padding
            rightPadding: padding
            bottomPadding: padding

            background: Rectangle {
                radius: Kirigami.Units.cornerRadius
                color: Qt.rgba(255, 255, 255, (openSettings.down || openSettings.highlighted) ? 0.3 : 0.2)

                Component.onCompleted: {
                    if (maskManager) {
                        maskManager.assignToMask(this)
                    }
                }
            }

            contentItem: Item {
                Kirigami.Icon {
                    anchors.centerIn: parent
                    implicitHeight: Kirigami.Units.iconSizes.large
                    implicitWidth: Kirigami.Units.iconSizes.large
                    source: 'list-add'
                    color: 'white'
                }
            }

            onClicked: imageWallpaperDrawer.wallpaperSettingsRequested()
            Keys.onReturnPressed: clicked();
        }

        delegate: Controls.ItemDelegate {
            id: delegate

            width: imageWallpaperDrawer.horizontal ? wallpapersView.width : height * (imageWallpaperDrawer.width / imageWallpaperDrawer.Screen.height)
            height: imageWallpaperDrawer.horizontal ? width / (imageWallpaperDrawer.Screen.width / imageWallpaperDrawer.Screen.height) : (wallpapersView ? wallpapersView.height : 0)
            padding: Kirigami.Units.largeSpacing - (wallpapersView.currentIndex === index ? Kirigami.Units.smallSpacing : 0)
            property real scaleAmount: wallpapersView.currentIndex === index ? 0 : Kirigami.Units.smallSpacing
            Behavior on scaleAmount {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on padding {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }

            leftPadding: padding
            topPadding: padding
            rightPadding: padding
            bottomPadding: padding
            topInset: scaleAmount
            bottomInset: scaleAmount
            leftInset: scaleAmount
            rightInset: scaleAmount

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

                Image {
                    id: walliePreview
                    anchors.fill: parent
                    visible: model.source != null
                    asynchronous: true
                    cache: false
                    fillMode: Image.PreserveAspectCrop
                    source: model.preview
                    sourceSize: Qt.size(width * 3, height * 3)
                }
            }
            onClicked: {
                WallpaperImagePlugin.WallpaperPlugin.setHomescreenWallpaper(model.source);
            }
            Keys.onReturnPressed: {
                clicked();
            }

            background: Rectangle {
                color: Qt.rgba(255, 255, 255, (delegate.down || delegate.highlighted) ? 0.4 : 0.2)
                radius: Kirigami.Units.cornerRadius

                Component.onCompleted: {
                    if (maskManager) {
                        maskManager.assignToMask(this)
                    }
                }
            }
        }
    }
}
