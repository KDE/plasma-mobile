// SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.0
import QtQuick.Window 2.15
import QtQuick.Controls 2.3 as Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.configuration 2.0

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.wallpapers.image 2.0 as Wallpaper
import org.kde.kquickcontrolsaddons 2.0 as Addons
import org.kde.kcmutils as KCM

Controls.Drawer {
    id: imageWallpaperDrawer
    dragMargin: 0
    
    required property bool horizontal

    onClosed: {
        if (!root.appComponent.visible) {
            configDialog.close()
        }
    }
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
        orientation: imageWallpaperDrawer.horizontal ? ListView.Vertical : ListView.Horizontal
        keyNavigationEnabled: true
        highlightFollowsCurrentItem: true
        snapMode: ListView.SnapToItem
        model: imageWallpaper.slidePaths
        // onCountChanged: currentIndex =  Math.min(model.indexOf(configDialog.wallpaperConfiguration["Image"]), model.rowCount()-1)
        headerPositioning: ListView.PullBackHeader

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

            property bool isCurrent: configDialog.wallpaperConfiguration["Image"] == model.path
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
                configDialog.currentWallpaper = "org.kde.image";
                configDialog.wallpaperConfiguration["Image"] = model.path;
                configDialog.applyWallpaper()
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
