// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls as QQC2

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

    readonly property bool dropAnimationRunning: delegateDragItem.dropAnimationRunning

    readonly property real settingsModeHomeScreenScale: 0.8

    onTopMarginChanged: Folio.HomeScreenState.viewTopPadding = root.topMargin
    onBottomMarginChanged: Folio.HomeScreenState.viewBottomPadding = root.bottomMargin
    onLeftMarginChanged: Folio.HomeScreenState.viewLeftPadding = root.leftMargin
    onRightMarginChanged: Folio.HomeScreenState.viewRightPadding = root.rightMargin

    // called by any delegates when starting drag
    // returns the mapped coordinates to be used in the home screen state
    function prepareStartDelegateDrag(delegate, item) {
        swipeArea.setSkipSwipeThreshold(true);

        delegateDragItem.delegate = delegate;
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

    // area that can be swiped
    MobileShell.SwipeArea {
        id: swipeArea
        anchors.fill: parent

        interactive: root.interactive &&
            !appDrawer.flickable.moving &&
            (appDrawer.flickable.atYBeginning || // disable the swipe area when we are swiping in the app drawer, and not in drag-and-drop
                Folio.HomeScreenState.swipeState === Folio.HomeScreenState.AwaitingDraggingDelegate ||
                Folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate ||
                Folio.HomeScreenState.swipeState === Folio.HomeScreenState.SwipingAppDrawerGrid)

        onSwipeStarted: {
            homeScreenState.swipeStarted();
        }
        onSwipeEnded: {
            homeScreenState.swipeEnded();
        }
        onSwipeMove: (totalDeltaX, totalDeltaY, deltaX, deltaY) => {
            homeScreenState.swipeMoved(totalDeltaX, totalDeltaY, deltaX, deltaY);
        }

        SettingsComponent {
            id: settings
            anchors.fill: parent
            opacity: Folio.HomeScreenState.settingsOpenProgress
            visible: opacity > 0
            z: 1

            settingsModeHomeScreenScale: root.settingsModeHomeScreenScale
            homeScreen: root

            onRequestLeaveSettingsMode: root.leaveSettingsMode();
        }

        Item {
            id: mainHomeScreen
            anchors.fill: parent

            // we stop showing halfway through the animation
            opacity: 1 - Math.max(homeScreenState.appDrawerOpenProgress, homeScreenState.searchWidgetOpenProgress, homeScreenState.folderOpenProgress) * 2
            visible: opacity > 0 // prevent handlers from picking up events

            transform: [
                Scale {
                    origin.x: mainHomeScreen.width / 2
                    origin.y: mainHomeScreen.height / 2
                    yScale: 1 - (homeScreenState.appDrawerOpenProgress * 2) * 0.1
                    xScale: 1 - (homeScreenState.appDrawerOpenProgress * 2) * 0.1
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
                color: Qt.rgba(255, 255, 255, 0.2)

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

                // one is ignored as anchors are set
                height: Kirigami.Units.gridUnit * 6
                width: Kirigami.Units.gridUnit * 6

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
                            height: Kirigami.Units.gridUnit * 6
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
                            width: Kirigami.Units.gridUnit * 6
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
                            width: Kirigami.Units.gridUnit * 6
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

                QQC2.PageIndicator {
                    visible: count > 1
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom

                    currentIndex: Folio.HomeScreenState.currentPage
                    count: Folio.PageListModel.length
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
