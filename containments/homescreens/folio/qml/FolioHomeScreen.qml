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
import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio

import "./delegate"
import "./settings"

Item {
    id: root
    property Folio.HomeScreen folio
    property MobileShell.MaskManager maskManager
    property Folio.HomeScreenState homeScreenState: folio.HomeScreenState

    property real topMargin: 0
    property real bottomMargin: 0
    property real leftMargin: 0
    property real rightMargin: 0

    property bool interactive: true

    // non-widget drop animation
    readonly property bool dropAnimationRunning: delegateDragItem.dropAnimationRunning || widgetDragItem.dropAnimationRunning

    // widget that is currently being dragged (or dropped)
    readonly property Folio.FolioWidget currentlyDraggedWidget: widgetDragItem.widget

    // how much to scale out in the settings mode
    readonly property real settingsModeHomeScreenScale: 0.8

    onTopMarginChanged: folio.HomeScreenState.viewTopPadding = root.topMargin
    onBottomMarginChanged: folio.HomeScreenState.viewBottomPadding = root.bottomMargin
    onLeftMarginChanged: folio.HomeScreenState.viewLeftPadding = root.leftMargin
    onRightMarginChanged: folio.HomeScreenState.viewRightPadding = root.rightMargin
    onWidthChanged: folio.HomeScreenState.viewWidth = width
    onHeightChanged: folio.HomeScreenState.viewHeight = height

    signal wallpaperSelectorTriggered()

    // called by any delegates when starting drag
    // returns the mapped coordinates to be used in the home screen state
    function prepareStartDelegateDrag(delegate, item, skipSwipeThreshold) {

        // If the user is prompted with a context menu, they may want to let go, and so we keep the detect swipe threshold.
        // Otherwise, we want to skip detecting a swipe because we know we immediately go into delegate dragging.
        if (skipSwipeThreshold) {
            swipeArea.setSkipSwipeThreshold(true);
        }

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

    Keys.onPressed: (event) => {
        // The root is focused when we aren't in key navigation mode
        // Begin key navigation when arrow keys are pressed
        if (event.key === Qt.Key_Up || event.key === Qt.Key_Down
            || event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
            homeScreenPages.forceActiveFocus();
            event.accepted = true;
        }
    }

    // determine how tall an app label is, for delegate measurements
    DelegateLabel {
        id: appLabelMetrics
        text: "M\nM"
        visible: false

        onHeightChanged: folio.HomeScreenState.pageDelegateLabelHeight = appLabelMetrics.height

        Component.onCompleted: {
            folio.HomeScreenState.pageDelegateLabelWidth = Kirigami.Units.smallSpacing;
        }
    }

    // a way of stopping focus
    FocusScope {
        id: noFocus
    }

    // Listen to view changes
    Connections {
        target: folio.HomeScreenState

        function onViewStateChanged() {
            if (folio.HomeScreenState.viewState === Folio.HomeScreenState.PageView) {
                // Focus root when on page view
                root.forceActiveFocus();
            }
        }
    }

    // area that can be swiped
    MobileShell.SwipeArea {
        id: swipeArea
        anchors.fill: parent

        interactive: root.interactive &&
            settingsLoader.homeScreenInteractive &&
            (appDrawer.flickable.atYBeginning || // there are cases where contentY > 0 but atYBeginning is true
            appDrawer.flickable.contentY <= 10 ||
            // disable the swipe area when we are swiping in the app drawer, and not in drag-and-drop
            folio.HomeScreenState.swipeState === Folio.HomeScreenState.AwaitingDraggingDelegate ||
            folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate ||
            folio.HomeScreenState.swipeState === Folio.HomeScreenState.SwipingAppDrawerGrid ||
            folio.HomeScreenState.viewState !== Folio.HomeScreenState.AppDrawerView)

        onSwipeStarted: (currentPos, startPos) => {
            const deltaX = currentPos.x - startPos.x;
            const deltaY = currentPos.y - startPos.y;
            homeScreenState.swipeStarted(deltaX, deltaY);
        }
        onSwipeEnded: {
            homeScreenState.swipeEnded();
        }
        onSwipeMove: (totalDeltaX, totalDeltaY, deltaX, deltaY) => {
            // cancel swipe when settings component is opening to prevent conflicts
            if (folio.HomeScreenState.settingsOpenProgress && folio.HomeScreenState.viewState !== Folio.HomeScreenState.SettingsView) {
                homeScreenState.swipeCancelled();
                return;
            }
            homeScreenState.swipeMoved(totalDeltaX, totalDeltaY, deltaX, deltaY);
        }

        onTouchpadScrollStarted: homeScreenState.swipeStarted(0, 0);
        onTouchpadScrollEnded: homeScreenState.swipeEnded();
        onTouchpadScrollMove: (totalDeltaX, totalDeltaY, deltaX, deltaY) => homeScreenState.swipeMoved(totalDeltaX, totalDeltaY, deltaX, deltaY);

        onPressedChanged: {
            if (pressed) {
                // ensures that components like the widget settings overlay close when swiping
                noFocus.forceActiveFocus();
            }
        }

        Loader {
            id: settingsLoader
            asynchronous: true
            active: true

            // Don't anchor, since we set y
            width: parent.width
            height: parent.height
            opacity: folio.HomeScreenState.settingsOpenProgress

            // move the settings out of the way if it is not visible
            // NOTE: we do this instead of setting visible to false, because
            //       it doesn't mess with widget drag and drop
            y: (opacity > 0) ? 0 : parent.height
            z: 1

            readonly property bool homeScreenInteractive: item ? item.homeScreenInteractive : true

            sourceComponent: SettingsComponent {
                id: settings
                folio: root.folio

                bottomMargin: root.bottomMargin
                leftMargin: root.leftMargin
                rightMargin: root.rightMargin

                settingsModeHomeScreenScale: root.settingsModeHomeScreenScale
                homeScreen: root
            }
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
                folio: root.folio
                maskManager: root.maskManager
                homeScreen: root

                anchors.topMargin: root.topMargin
                anchors.leftMargin: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Left ? 0 : root.leftMargin
                anchors.rightMargin: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Right ? 0 : root.rightMargin
                anchors.bottomMargin: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom ? 0 : root.bottomMargin

                // update the model with page dimensions
                onWidthChanged: {
                    homeScreenState.pageWidth = homeScreenPages.width;
                }
                onHeightChanged: {
                    homeScreenState.pageHeight = homeScreenPages.height;
                }

                // Keyboard navigation from pages
                Keys.onPressed: (event) => {
                    switch (event.key) {
                    case Qt.Key_Up:
                        // Open search widget when going up
                        folio.HomeScreenState.openSearchWidget();
                        event.accepted = true;
                        break;
                    case Qt.Key_Down:
                        // Focus on favorites bar or app drawer, depending on its physical location
                        if (folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom) {
                            favouritesBar.forceActiveFocus();
                        } else {
                            folio.HomeScreenState.openAppDrawer();
                        }
                        event.accepted = true;
                        break;
                    case Qt.Key_Left:
                        if (folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Left) {
                            // If favorites bar is on the left, navigate to it
                            favouritesBar.forceActiveFocus();
                        } else {
                            // Otherwise go to page on the left
                            folio.HomeScreenState.goToPage(folio.HomeScreenState.currentPage - 1, false);
                            homeScreenPages.focusCurrentPageForKeyboardNav();
                        }
                        event.accepted = true;
                        break;
                    case Qt.Key_Right:
                        if (folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Right) {
                            // If favorites bar is on the right, navigate to it
                            favouritesBar.forceActiveFocus();
                        } else {
                            // Otherwise go to page on the right
                            folio.HomeScreenState.goToPage(folio.HomeScreenState.currentPage + 1, false);
                            homeScreenPages.focusCurrentPageForKeyboardNav();
                        }
                        event.accepted = true;
                        break;
                    default:
                        break;
                    }
                }

                transform: [
                    Scale {
                        // animation when settings opens
                        property real scaleFactor: 1 - folio.HomeScreenState.settingsOpenProgress * (1 - settingsModeHomeScreenScale)
                        origin.x: root.leftMargin + (root.width - root.rightMargin - root.leftMargin) / 2
                        origin.y: root.height * settingsModeHomeScreenScale / 2
                        xScale: scaleFactor
                        yScale: scaleFactor
                    }
                ]

                states: [
                    State {
                        name: "bottom"
                        when: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom
                        AnchorChanges {
                            target: homeScreenPages
                            anchors.top: parent.top
                            anchors.bottom: favouritesBar.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                        }
                    }, State {
                        name: "left"
                        when: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Left
                        AnchorChanges {
                            target: homeScreenPages
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: favouritesBar.right
                            anchors.right: parent.right
                        }
                    }, State {
                        name: "right"
                        when: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Right
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

                Component.onCompleted: maskManager.assignToMask(this)

                // don't show in settings mode
                opacity: 1 - folio.HomeScreenState.settingsOpenProgress
                visible: folio.FolioSettings.showFavouritesBarBackground

                anchors.top: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom ? favouritesBar.top : parent.top
                anchors.bottom: parent.bottom
                anchors.left: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Right ? favouritesBar.left : parent.left
                anchors.right: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Left ? favouritesBar.right : parent.right

                // because of the scale animation, we need to extend the panel out a bit
                anchors.topMargin: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom ? 0 : -Kirigami.Units.gridUnit * 5
                anchors.bottomMargin: -Kirigami.Units.gridUnit * 5
                anchors.leftMargin: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Right ? 0 : -Kirigami.Units.gridUnit * 5
                anchors.rightMargin: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Left ? 0 : -Kirigami.Units.gridUnit * 5
            }

            FavouritesBar {
                id: favouritesBar
                folio: root.folio
                maskManager: root.maskManager
                homeScreen: root

                // don't show in settings mode
                opacity: 1 - folio.HomeScreenState.settingsOpenProgress
                visible: opacity > 0

                // one is ignored as anchors are set
                height: Kirigami.Units.gridUnit * 6
                width: Kirigami.Units.gridUnit * 6

                anchors.topMargin: root.topMargin
                anchors.bottomMargin: root.bottomMargin
                anchors.leftMargin: root.leftMargin
                anchors.rightMargin: root.rightMargin

                // Keyboard navigation on favorites bar
                Keys.onPressed: (event) => {
                    switch (event.key) {
                    case Qt.Key_Up:
                        // Focus on homescreen pages or search widget depending on physical position
                        if (folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom) {
                            homeScreenPages.forceActiveFocus();
                        } else {
                            folio.HomeScreenState.openSearchWidget();
                        }
                        event.accepted = true;
                        break;
                    case Qt.Key_Down:
                        // Open app drawer
                        folio.HomeScreenState.openAppDrawer();
                        event.accepted = true;
                        break;
                    case Qt.Key_Left:
                        if (folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Left) {
                            // Go to left page if mounted on the left
                            folio.HomeScreenState.goToPage(folio.HomeScreenState.currentPage - 1, false);
                            event.accepted = true;
                        }
                        break;
                    case Qt.Key_Right:
                        if (folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Right) {
                            // Go to right page if mounted on the right
                            folio.HomeScreenState.goToPage(folio.HomeScreenState.currentPage + 1, false);
                            event.accepted = true;
                        }
                        break;
                    default:
                        break;
                    }
                }

                states: [
                    State {
                        name: "bottom"
                        when: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom
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
                        when: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Left
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
                        when: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Right
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
                property bool favouritesBarAtBottom: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom

                // don't show in settings mode
                opacity: 1 - folio.HomeScreenState.settingsOpenProgress

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

                    currentIndex: folio.HomeScreenState.currentPage
                    count: folio.PageListModel.length

                    TapHandler {
                        onTapped: folio.HomeScreenState.openAppDrawer()
                    }
                }

                // show arrow to open app drawer when there is 1 page
                Kirigami.Icon {
                    source: 'arrow-up'
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

                    implicitHeight: Kirigami.Units.iconSizes.small
                    implicitWidth: Kirigami.Units.iconSizes.small

                    visible: folio.PageListModel.length <= 1

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Kirigami.Units.smallSpacing

                    TapHandler {
                        onTapped: folio.HomeScreenState.openAppDrawer()
                    }
                }
            }
        }

        // folder view
        FolderView {
            id: folderView
            folio: root.folio
            anchors.fill: parent
            anchors.topMargin: root.topMargin
            anchors.leftMargin: root.leftMargin
            anchors.rightMargin: root.rightMargin
            anchors.bottomMargin: root.bottomMargin

            homeScreen: root
            opacity: homeScreenState.folderOpenProgress
            transform: Translate { y: folderView.opacity > 0 ? 0 : folderView.height }
        }

        // bottom app drawer
        AppDrawer {
            id: appDrawer
            folio: root.folio
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

            headerHeight: Math.round(Kirigami.Units.gridUnit * 4)
            headerItem: AppDrawerHeader {
                id: appDrawerHeader
                folio: root.folio

                onReleaseFocusRequested: appDrawer.forceActiveFocus()
            }

            // Account for panels
            topPadding: root.topMargin
            bottomPadding: root.bottomMargin
            leftPadding: root.leftMargin
            rightPadding: root.rightMargin

            // Forward keyboard text to the search bar
            Keys.onPressed: (event) => {
                if (event.text.trim().length > 0) {
                    appDrawerHeader.addSearchText(event.text);
                    appDrawerHeader.forceActiveFocus();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Right || event.key === Qt.Key_Up || event.key === Qt.Key_Down) {
                    appDrawerHeader.forceActiveFocus();
                    event.accepted = true;
                }
            }

            Connections {
                target: folio.HomeScreenState

                function onAppDrawerOpened() {
                    appDrawer.forceActiveFocus();
                }

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
                target: folio.HomeScreenState

                function onSearchWidgetOpenProgressChanged() {
                    if (homeScreenState.searchWidgetOpenProgress === 1.0) {
                        searchWidget.requestFocus();
                    }
                }
            }

            onRequestedClose: (triggeredByKeyEvent) => {
                homeScreenState.closeSearchWidget();
            }

            anchors.topMargin: root.topMargin
            anchors.bottomMargin: root.bottomMargin
            anchors.leftMargin: root.leftMargin
            anchors.rightMargin: root.rightMargin
        }
    }
}
