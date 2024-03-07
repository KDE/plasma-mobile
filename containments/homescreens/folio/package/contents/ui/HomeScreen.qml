// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls as QQC2
import Qt5Compat.GraphicalEffects

import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.private.mobile.homescreen.folio 1.0 as Folio

import "./delegate"
import "./settings"

Item {
    id: root

    property real topMargin: 0
    property real bottomMargin: 0
    property real leftMargin: 0
    property real rightMargin: 0

    property bool interactive: true

    property Folio.HomeScreenState homeScreenState: Folio.HomeScreenState

    // non-widget drop animation
    readonly property bool dropAnimationRunning: delegateDragItem.dropAnimationRunning || widgetDragItem.dropAnimationRunning

    // widget that is currently being dragged (or dropped)
    readonly property Folio.FolioWidget currentlyDraggedWidget: widgetDragItem.widget

    // how much to scale out in the settings mode
    readonly property real settingsModeHomeScreenScale: 0.8

    onTopMarginChanged: Folio.HomeScreenState.viewTopPadding = root.topMargin
    onBottomMarginChanged: Folio.HomeScreenState.viewBottomPadding = root.bottomMargin
    onLeftMarginChanged: Folio.HomeScreenState.viewLeftPadding = root.leftMargin
    onRightMarginChanged: Folio.HomeScreenState.viewRightPadding = root.rightMargin

    // called by any delegates when starting drag
    // returns the mapped coordinates to be used in the home screen state
    function prepareStartDelegateDrag(delegate, item) {
        swipeArea.setSkipSwipeThreshold(true);

        if (delegate) {
            delegateDragItem.delegate = delegate;
        }
        return root.mapFromItem(item, 0, 0);
    }

    function cancelDelegateDrag() {
        homeScreenState.cancelDelegateDrag();
    }

    // sets the coordinates for the folder opening/closing animation
    function prepareFolderOpen(item) {
        return root.mapFromItem(item, 0, 0);
    }

    function openConfigure() {
        Plasmoid.internalAction("configure").trigger();
    }

    // determine how tall an app label is, for delegate measurements
    DelegateLabel {
        id: appLabelMetrics
        text: "M\nM"
        visible: false

        onHeightChanged: Folio.HomeScreenState.pageDelegateLabelHeight = appLabelMetrics.height

        Component.onCompleted: {
            Folio.HomeScreenState.pageDelegateLabelWidth = Kirigami.Units.smallSpacing;
        }
    }

    // determine screen dimensions
    Item {
        id: screenDimensions
        anchors.fill: parent

        onWidthChanged: Folio.HomeScreenState.viewWidth = width;
        onHeightChanged: Folio.HomeScreenState.viewHeight = height;
    }

    // a way of stopping focus
    FocusScope {
        id: noFocus
    }

    // favourites scrim background blur
    Item {
        id: favouritesBarBlur
        opacity: favouritesBarScrim.opacity * mainHomeScreen.opacity

        x: 0
        y: 0
        width: 100
        height: 100

        property real scaleFactor: Math.max(homeScreenState.appDrawerOpenProgress, homeScreenState.searchWidgetOpenProgress)
        property real yCalc: {
            const trueScale = 1 - (scaleFactor * 2) * 0.1;
            const baseHeight = favouritesBar.thickness + root.bottomMargin;
            const baseStart = root.height - baseHeight;
            const halfHeight = root.height / 2;
            return baseStart - (halfHeight + (baseStart - halfHeight) * trueScale);
        }

        states: [
            State {
                name: "bottom"
                when: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom
                PropertyChanges {
                    target: favouritesBarBlur
                    x: 0
                    y: root.height - height
                    width: swipeArea.width
                    height: favouritesBar.thickness + root.bottomMargin + yCalc
                }
            }, State {
                name: "left"
                when: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Left
                PropertyChanges {
                    target: favouritesBarBlur
                    x: 0
                    y: 0
                    width: favouritesBar.thickness + root.leftMargin
                    height: swipeArea.height
                }
            }, State {
                name: "right"
                when: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Right
                PropertyChanges {
                    target: favouritesBarBlur
                    x: root.width - width
                    y: 0
                    width: favouritesBar.thickness + root.rightMargin
                    height: root.height
                }
            }
        ]

        ShaderEffectSource {
            id: favouritesBarEffectSource
            sourceItem: Plasmoid.wallpaperGraphicsObject
            anchors.fill: parent
            sourceRect: Qt.rect(favouritesBarBlur.x, favouritesBarBlur.y, width, height)
        }

        FastBlur {
            radius: 50
            cached: true
            source: favouritesBarEffectSource
            anchors.fill: parent
            transparentBorder: false
        }
    }

    // area that can be swiped
    MobileShell.SwipeArea {
        id: swipeArea
        anchors.fill: parent

        interactive: root.interactive &&
            settings.homeScreenInteractive &&
            (appDrawer.flickable.contentY <= 10 || // disable the swipe area when we are swiping in the app drawer, and not in drag-and-drop
                Folio.HomeScreenState.swipeState === Folio.HomeScreenState.AwaitingDraggingDelegate ||
                Folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate ||
                Folio.HomeScreenState.swipeState === Folio.HomeScreenState.SwipingAppDrawerGrid ||
                Folio.HomeScreenState.viewState !== Folio.HomeScreenState.AppDrawerView)

        onSwipeStarted: {
            homeScreenState.swipeStarted();
        }
        onSwipeEnded: {
            homeScreenState.swipeEnded();
        }
        onSwipeMove: (totalDeltaX, totalDeltaY, deltaX, deltaY) => {
            homeScreenState.swipeMoved(totalDeltaX, totalDeltaY, deltaX, deltaY);
        }

        onPressedChanged: {
            if (pressed) {
                // ensures that components like the widget settings overlay close when swiping
                noFocus.forceActiveFocus();
            }
        }

        SettingsComponent {
            id: settings
            width: parent.width
            height: parent.height
            opacity: Folio.HomeScreenState.settingsOpenProgress
            z: 1

            // move the settings out of the way if it is not visible
            // NOTE: we do this instead of setting visible to false, because
            //       it doesn't mess with widget drag and drop
            y: (opacity > 0) ? 0 : parent.height

            settingsModeHomeScreenScale: root.settingsModeHomeScreenScale
            homeScreen: root
        }
    
        Item {
            id: mainHomeScreen
            anchors.fill: parent

            // we stop showing halfway through the animation
            opacity: 1 - Math.max(homeScreenState.appDrawerOpenProgress, homeScreenState.searchWidgetOpenProgress, homeScreenState.folderOpenProgress) * 2
            visible: opacity > 0 // prevent handlers from picking up events

            transform: [
                Scale {
                    property real scaleFactor: Math.max(homeScreenState.appDrawerOpenProgress, homeScreenState.searchWidgetOpenProgress)
                    origin.x: mainHomeScreen.width / 2
                    origin.y: mainHomeScreen.height / 2
                    yScale: 1 - (scaleFactor * 2) * 0.1
                    xScale: 1 - (scaleFactor * 2) * 0.1
                }
            ]

            HomeScreenPages {
                id: homeScreenPages
                homeScreen: root

                anchors.topMargin: root.topMargin
                anchors.leftMargin: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Left ? 0 : root.leftMargin
                anchors.rightMargin: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Right ? 0 : root.rightMargin
                anchors.bottomMargin: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom ? 0 : root.bottomMargin

                // update the model with page dimensions
                onWidthChanged: {
                    homeScreenState.pageWidth = homeScreenPages.width;
                }
                onHeightChanged: {
                    homeScreenState.pageHeight = homeScreenPages.height;
                }

                transform: [
                    Scale {
                        // animation when settings opens
                        property real scaleFactor: 1 - Folio.HomeScreenState.settingsOpenProgress * (1 - settingsModeHomeScreenScale)
                        origin.x: root.leftMargin + (root.width - root.rightMargin - root.leftMargin) / 2
                        origin.y: root.height * settingsModeHomeScreenScale / 2
                        xScale: scaleFactor
                        yScale: scaleFactor
                    }
                ]

                states: [
                    State {
                        name: "bottom"
                        when: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom
                        AnchorChanges {
                            target: homeScreenPages
                            anchors.top: parent.top
                            anchors.bottom: favouritesBar.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                        }
                    }, State {
                        name: "left"
                        when: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Left
                        AnchorChanges {
                            target: homeScreenPages
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: favouritesBar.right
                            anchors.right: parent.right
                        }
                    }, State {
                        name: "right"
                        when: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Right
                        AnchorChanges {
                            target: homeScreenPages
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: favouritesBar.left
                        }
                    }
                ]
            }

            Rectangle {
                id: favouritesBarScrim
                color: Qt.rgba(0, 0, 0, 0.2)

                // don't show in settings mode
                opacity: 1 - Folio.HomeScreenState.settingsOpenProgress
                visible: Folio.FolioSettings.showFavouritesBarBackground

                anchors.top: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom ? favouritesBar.top : parent.top
                anchors.bottom: parent.bottom
                anchors.left: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Right ? favouritesBar.left : parent.left
                anchors.right: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Left ? favouritesBar.right : parent.right

                // because of the scale animation, we need to extend the panel out a bit
                anchors.topMargin: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom ? 0 : -Kirigami.Units.gridUnit * 5
                anchors.bottomMargin: -Kirigami.Units.gridUnit * 5
                anchors.leftMargin: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Right ? 0 : -Kirigami.Units.gridUnit * 5
                anchors.rightMargin: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Left ? 0 : -Kirigami.Units.gridUnit * 5
            }

            FavouritesBar {
                id: favouritesBar
                homeScreen: root
                leftMargin: root.leftMargin
                topMargin: root.topMargin

                // don't show in settings mode
                opacity: 1 - Folio.HomeScreenState.settingsOpenProgress
                visible: opacity > 0

                readonly property real thickness: Kirigami.Units.gridUnit * 6

                // one is ignored as anchors are set
                height: thickness
                width: thickness

                anchors.topMargin: root.topMargin
                anchors.bottomMargin: root.bottomMargin
                anchors.leftMargin: root.leftMargin
                anchors.rightMargin: root.rightMargin

                states: [
                    State {
                        name: "bottom"
                        when: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom
                        AnchorChanges {
                            target: favouritesBar
                            anchors.top: undefined
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                        }
                        PropertyChanges {
                            target: favouritesBar
                            height: favouritesBar.thickness
                        }
                    }, State {
                        name: "left"
                        when: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Left
                        AnchorChanges {
                            target: favouritesBar
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: undefined
                        }
                        PropertyChanges {
                            target: favouritesBar
                            width: favouritesBar.thickness
                        }
                    }, State {
                        name: "right"
                        when: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Right
                        AnchorChanges {
                            target: favouritesBar
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: undefined
                            anchors.right: parent.right
                        }
                        PropertyChanges {
                            target: favouritesBar
                            width: favouritesBar.thickness
                        }
                    }
                ]
            }

            Item {
                id: pageIndicatorWrapper
                property bool favouritesBarAtBottom: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom

                // don't show in settings mode
                opacity: 1 - Folio.HomeScreenState.settingsOpenProgress

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: favouritesBarAtBottom ? favouritesBar.top : parent.bottom

                anchors.topMargin: root.topMargin
                anchors.leftMargin: root.leftMargin
                anchors.rightMargin: root.rightMargin
                anchors.bottomMargin: favouritesBarAtBottom ? 0 : (root.bottomMargin + Kirigami.Units.largeSpacing)

                // show page indicator if there are multiple pages
                QQC2.PageIndicator {
                    visible: count > 1
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom

                    currentIndex: Folio.HomeScreenState.currentPage
                    count: Folio.PageListModel.length

                    TapHandler {
                        onTapped: Folio.HomeScreenState.openAppDrawer()
                    }
                }

                // show arrow to open app drawer when there is 1 page
                Kirigami.Icon {
                    source: 'arrow-up'
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                    
                    implicitHeight: Kirigami.Units.iconSizes.small
                    implicitWidth: Kirigami.Units.iconSizes.small

                    visible: Folio.PageListModel.length <= 1
                    
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Kirigami.Units.smallSpacing

                    TapHandler {
                        onTapped: Folio.HomeScreenState.openAppDrawer()
                    }
                }
            }
        }

        // folder view
        FolderView {
            id: folderView
            anchors.fill: parent
            anchors.topMargin: root.topMargin
            anchors.leftMargin: root.leftMargin
            anchors.rightMargin: root.rightMargin
            anchors.bottomMargin: root.bottomMargin

            homeScreen: root
            opacity: homeScreenState.folderOpenProgress
            transform: Translate { y: folderView.opacity > 0 ? 0 : folderView.height }
        }

        // drag and drop component
        DelegateDragItem {
            id: delegateDragItem
        }

        // drag and drop for widgets
        WidgetDragItem {
            id: widgetDragItem
        }

        // bottom app drawer
        AppDrawer {
            id: appDrawer
            width: parent.width
            height: parent.height

            homeScreen: root

            // we only start showing it halfway through
            opacity: homeScreenState.appDrawerOpenProgress < 0.5 ? 0 : (homeScreenState.appDrawerOpenProgress - 0.5) * 2

            // position for animation
            property real animationY: (1 - homeScreenState.appDrawerOpenProgress) * (Kirigami.Units.gridUnit * 2)

            // move the app drawer out of the way if it is not visible
            // NOTE: we do this instead of setting visible to false, because
            //       it doesn't mess with app drag and drop from the app drawer
            y: (opacity > 0) ? animationY : parent.height

            headerHeight: Math.round(Kirigami.Units.gridUnit * 5)
            headerItem: AppDrawerHeader {}

            // account for panels
            topPadding: root.topMargin
            bottomPadding: root.bottomMargin
            leftPadding: root.leftMargin
            rightPadding: root.rightMargin

            Connections {
                target: Folio.HomeScreenState

                function onAppDrawerClosed() {
                    // reset app drawer position when closed
                    appDrawer.flickable.contentY = 0;
                }
            }
        }

        // search component
        MobileShell.KRunnerScreen {
            id: searchWidget
            anchors.fill: parent

            opacity: homeScreenState.searchWidgetOpenProgress
            visible: opacity > 0
            transform: Translate { y: (1 - homeScreenState.searchWidgetOpenProgress) * (-Kirigami.Units.gridUnit * 2) }

            onVisibleChanged: {
                if (!visible) {
                    // clear search bar when closed
                    searchWidget.clearField();
                }
            }

            // focus the search bar if it opens
            Connections {
                target: Folio.HomeScreenState

                function onSearchWidgetOpenProgressChanged() {
                    if (homeScreenState.searchWidgetOpenProgress === 1.0) {
                        searchWidget.requestFocus();
                    } else {
                        // TODO this gets called a lot, can we have a more performant way?
                        root.forceActiveFocus();
                    }
                }
            }

            onRequestedClose: {
                homeScreenState.closeSearchWidget();
            }

            anchors.topMargin: root.topMargin
            anchors.bottomMargin: root.bottomMargin
            anchors.leftMargin: root.leftMargin
            anchors.rightMargin: root.rightMargin
        }
    }
}
