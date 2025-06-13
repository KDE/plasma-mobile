// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.private.mobile.homescreen.folio 1.0 as Folio
import org.kde.plasma.private.mobileshell.windowplugin as WindowPlugin
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

ContainmentItem {
    id: root
    property Folio.HomeScreen folio: root.plasmoid

    // blur properties, the wallpaperBlurEffect setting must not be set to none to make an effect
    readonly property int fastBlurRadius: 24
    readonly property real blurTextureQuality: 0.1 // gets multiplied against the screen size to set the texture size

    Component.onCompleted: {
        folio.FolioSettings.load();
        folio.FavouritesModel.load();
        folio.PageListModel.load();

        // ensure the gestures work immediately on load
        forceActiveFocus();
    }

    Loader {
        id: wallpaperBlurLoader
        active: folio.FolioSettings.wallpaperBlurEffect
        visible: active
        asynchronous: true
        anchors.fill: parent

        sourceComponent: Item {
            id: wallpaper
            anchors.fill: parent

            // this value is used to switch between blurring the whole wallpaper or just behind the mask areas
            property real fullBlur: Math.min(1,
                Math.max(0,
                1 - homeScreen.contentOpacity,
                folio.HomeScreenState.appDrawerOpenProgress * 2, // blur faster during swipe
                folio.HomeScreenState.searchWidgetOpenProgress * 1.5, // blur faster during swipe
                folio.HomeScreenState.folderOpenProgress
            ))

            // only take samples from wallpaper when we need the blur for performance
            ShaderEffectSource {
                id: controlledWallpaperSource
                anchors.fill: parent

                // this layer will be blurred, so it looks fine to have a lower texture quality to help with performance
                textureSize: Qt.size(Math.round(root.width * root.blurTextureQuality), Math.round(root.height * root.blurTextureQuality))

                live: wallpaperBlurLoader.active
                hideSource: false
                opacity: wallpaper.fullBlur

                // wallpaper blur
                // we attempted to use MultiEffect in the past, but it had very poor performance on the PinePhone
                sourceItem: FastBlur {
                    height: Math.round(root.height * root.blurTextureQuality)
                    width: Math.round(root.width * root.blurTextureQuality)

                    cached: true
                    radius: root.fastBlurRadius

                    source: ShaderEffectSource{
                        anchors.fill: parent

                        textureSize: Qt.size(Math.round(root.width * root.blurTextureQuality), Math.round(root.height * root.blurTextureQuality))

                        sourceItem: Plasmoid.wallpaperGraphicsObject
                        hideSource: false
                    }
                }
            }

            // load in the layer mask so we can utilize it with the OpacityMask
            Item {
                id: blurMask
                anchors.fill: parent
                layer.enabled: true
                layer.smooth: true
                opacity: 0

                Loader {
                    asynchronous: true
                    active: wallpaper.fullBlur != 1 && folio.FolioSettings.wallpaperBlurEffect > 1
                    anchors.fill: parent

                    sourceComponent: folioHomeScreen.maskComponent
                }
            }

            // here we utilize the mask on the blur layer so we can blur behind the folders and favorites bar
            OpacityMask {
                anchors.fill: parent
                source: controlledWallpaperSource
                maskSource: blurMask
                opacity: 1 - Math.max(folio.HomeScreenState.settingsOpenProgress, wallpaper.fullBlur)
                visible: (folio.FolioSettings.wallpaperBlurEffect > 1) && opacity > 0
            }
        }
    }

    WindowPlugin.WindowMaximizedTracker {
        id: windowMaximizedTracker
        screenGeometry: Plasmoid.containment.screenGeometry
    }

    function homeAction() {
        const isInWindow = (!WindowPlugin.WindowUtil.isShowingDesktop && windowMaximizedTracker.showingWindow);

        // Always close action drawer
        if (MobileShellState.ShellDBusClient.isActionDrawerOpen) {
            MobileShellState.ShellDBusClient.closeActionDrawer();
        }

        if (isInWindow) {
            // Only minimize windows and go to homescreen when not in docked mode
            if (!ShellSettings.Settings.convergenceModeEnabled) {
                folio.HomeScreenState.closeFolder();
                folio.HomeScreenState.closeSearchWidget();
                folio.HomeScreenState.closeAppDrawer();
                folio.HomeScreenState.goToPage(0, false);

                WindowPlugin.WindowUtil.minimizeAll();
            }

            // Always ensure settings view is closed
            if (folio.HomeScreenState.viewState == Folio.HomeScreenState.SettingsView) {
                folio.HomeScreenState.closeSettingsView();
            }

        } else { // If we are already on the homescreen
            switch (folio.HomeScreenState.viewState) {
                case Folio.HomeScreenState.PageView:
                    if (folio.HomeScreenState.currentPage === 0) {
                        folio.HomeScreenState.openAppDrawer();
                    } else {
                        folio.HomeScreenState.goToPage(0, false);
                    }
                    break;
                case Folio.HomeScreenState.AppDrawerView:
                    folio.HomeScreenState.closeAppDrawer();
                    break;
                case Folio.HomeScreenState.SearchWidgetView:
                    folio.HomeScreenState.closeSearchWidget();
                    break;
                case Folio.HomeScreenState.FolderView:
                    folio.HomeScreenState.closeFolder();
                    break;
                case Folio.HomeScreenState.SettingsView:
                    folio.HomeScreenState.closeSettingsView();
                    break;
            }
        }
    }

    Plasmoid.onActivated: homeAction()

    Rectangle {
        id: appDrawerBackground
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)

        opacity: folio.HomeScreenState.appDrawerOpenProgress
    }

    Rectangle {
        id: searchWidgetBackground
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.3)

        opacity: folio.HomeScreenState.searchWidgetOpenProgress
    }

    Rectangle {
        id: settingsViewBackground
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.3)

        opacity: folio.HomeScreenState.settingsOpenProgress
    }

    MobileShell.HomeScreen {
        id: homeScreen
        anchors.fill: parent

        plasmoidItem: root
        onResetHomeScreenPosition: {
            // NOTE: empty, because this is handled by homeAction()
        }

        onHomeTriggered: root.homeAction()

        contentItem: Item {

            // homescreen component
            HomeScreen {
                id: folioHomeScreen
                folio: root.folio
                anchors.fill: parent

                zoomScale: homeScreen.zoomScale

                topMargin: homeScreen.topMargin
                bottomMargin: homeScreen.bottomMargin
                leftMargin: homeScreen.leftMargin
                rightMargin: homeScreen.rightMargin
            }
        }
    }

    // create mask layer for the drag and drop item so we can blur behind it
    property Component dragMaskComponent: Item {
        id: maskComponent
        anchors.fill: parent

        component FolderMask : ColumnLayout {
            id: folderMask
            required property Item item
            spacing: 0

            width: item.width
            height: item.height

            x: item.x
            y: item.y

            function setXBinding() {
                x = Qt.binding(() => item.x);
            }
            function setYBinding() {
                y = Qt.binding(() => item.y);
            }

            // animate drop x
            XAnimator on x {
                id: dragXAnim
                running: false
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
                onFinished: {
                    folderMask.setXBinding();
                }
            }

            // animate drop y
            YAnimator on y {
                id: dragYAnim
                running: false
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
                onFinished: {
                    folderMask.setYBinding();
                }
            }

            Connections {
                target: item

                function onAnimateDrop() {
                    dragXAnim.to = item.snapPositionX;
                    dragYAnim.to = item.snapPositionY;
                    dragXAnim.restart();
                    dragYAnim.restart();
                }
            }

            Rectangle {
                Layout.minimumWidth: folio.FolioSettings.delegateIconSize
                Layout.minimumHeight: folio.FolioSettings.delegateIconSize
                Layout.preferredHeight: Layout.minimumHeight

                radius: Kirigami.Units.cornerRadius

                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            }

            Item {
                Layout.preferredHeight: folio.HomeScreenState.pageDelegateLabelHeight
                Layout.topMargin: folio.HomeScreenState.pageDelegateLabelSpacing
            }
        }

        FolderMask {
            item: delegateDragItem
        }
    }

    // drag and drop blur layer
    Loader {
        id: dragDropBlurLoader
        // only take samples from wallpaper and homescreen when we need the blur for performance
        active: folio.FolioSettings.wallpaperBlurEffect > 1 && delegateDragItem.visible && folio.HomeScreenState.dragState.dropDelegate.type === Folio.FolioDelegate.Folder
        visible: active
        asynchronous: true
        anchors.fill: parent

        sourceComponent: Item {
            id: frontLayer
            anchors.fill: parent

            ShaderEffectSource {
                id: blur
                anchors.fill: parent

                // this layer will be blurred, so it looks fine to have a lower texture quality to help with performance
                textureSize: Qt.size(Math.round(root.width * root.blurTextureQuality), Math.round(root.height * root.blurTextureQuality))

                live: dragDropBlurLoader.active
                visible: dragDropBlurLoader.active
                hideSource: true

                opacity: 0

                // we attempted to use MultiEffect in the past, but it had very poor performance on the PinePhone
                sourceItem: FastBlur {
                    height: Math.round(root.height * root.blurTextureQuality)
                    width: Math.round(root.width * root.blurTextureQuality)

                    cached: true
                    radius: root.fastBlurRadius

                    source: homeScreenLayer

                    // stacking both wallpaper and homescreen layers so we can blur them in one pass
                    Item {
                        id: homeScreenLayer
                        anchors.fill: parent

                        layer.enabled: true
                        layer.smooth: true

                        opacity: 0

                        // wallpaper blur
                        ShaderEffectSource {
                            anchors.fill: parent

                            textureSize: Qt.size(Math.round(root.width * root.blurTextureQuality), Math.round(root.height * root.blurTextureQuality))

                            sourceItem: Plasmoid.wallpaperGraphicsObject
                            hideSource: false
                        }

                        // homescreen blur
                        ShaderEffectSource {
                            anchors.fill: parent

                            sourceItem: homeScreen
                            textureSize: Qt.size(Math.round(root.width * root.blurTextureQuality), Math.round(root.height * root.blurTextureQuality))
                            hideSource: false
                        }
                    }
                }
            }

            // load in the drag and drop mask layer so we can utilize it with the ThresholdMask
            Item {
                id: dragMask
                anchors.fill: parent
                layer.enabled: true
                layer.smooth: true
                opacity: 0

                Loader {
                    asynchronous: true
                    active: frontLayer.fullBlur != 1 && folio.FolioSettings.wallpaperBlurEffect > 1 && dragDropBlurLoader.active
                    anchors.fill: parent

                    sourceComponent: root.dragMaskComponent
                }
            }

            // here we use the dragMask on the blur layer to blur behind folders when they are being dragged
            ThresholdMask {
                anchors.fill: parent
                source: blur
                maskSource: dragMask
                threshold: 0.5
                visible: folio.FolioSettings.wallpaperBlurEffect > 1 && dragDropBlurLoader.active
            }
        }
    }

    // drag and drop component
    DelegateDragItem {
        id: delegateDragItem
        folio: root.folio
    }

    // drag and drop for widgets
    WidgetDragItem {
        id: widgetDragItem
        folio: root.folio
    }
}

