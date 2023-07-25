/*
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15

import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.private.mobileshell 1.0 as MobileShell

/**
 * State object for the homescreen.
 * 
 * We expose the data necessary to make custom "swipe-down" gestures from the page view.
 */
QtObject {
    id: root
    
    // whether the homescreen elements should be interactive, or disabled
    required property bool interactive
    
    required property real totalPagesWidth
    
    required property var appDrawerFlickable 
    
    // dimensions of the homescreen area (not including top panel and task panel)
    required property real availableScreenHeight
    required property real availableScreenWidth
    
    // offset from the bottom of the screen that the app drawer starts from,
    // would be the height favourites strip
    required property real appDrawerBottomOffset
    
    // ~~ positioning ~~
    
    // xPosition:
    // We start at 0, which is the beginning x position of the row of pages (left-most side). 
    // Increasing x moves *right* toward the next page.
    //
    // yPosition:
    // Increasing y results in moving *up* in the view.
    // appDrawerOpenYPosition - The app drawer is opened (app drawer flickable is active iff it's not at the beginning).
    // pagesYPosition         - The app drawer is closed. Homescreen pages are visible, can swipe left/right between pages.
    property real xPosition: 0
    property real yPosition: pagesYPosition
    
    // direction of the movement
    property bool movingRight: false
    property bool movingUp: false
    
    // used for calculating movement direction
    property real oldXPosition: 0
    property real oldYPosition: 0
    onXPositionChanged: {
        movingRight = xPosition > oldXPosition;
        oldXPosition = xPosition;
    }
    onYPositionChanged: {
        movingUp = yPosition > oldYPosition;
        oldYPosition = yPosition;
        
        // speed up the animation
        if (currentSwipeState == HomeScreenState.SwipingAppDrawerVisibility && yPosition <= 0) {
            root.currentView = HomeScreenState.AppDrawerBeginningView;
            root.resetSwipeState();
            openDrawerAnim.stop();
        }
    }
    
    // yPosition when the homescreen pages are visible
    readonly property real pagesYPosition: availableScreenHeight - appDrawerBottomOffset
    
    // yPosition when drawer is open
    readonly property real appDrawerOpenYPosition: 0
    
    // ~~ active state ~~
    
    enum View {
        PageView, // we are viewing the horizontal row of pages
        AppDrawerBeginningView, // we are at the top of the app drawer (could either close it or scroll down)
        AppDrawerView // we are in the app drawer, and not at the top of it
    }
    
    // the current view of the homescreen
    property var currentView: HomeScreenState.PageView
    
    // number of homescreen pages
    readonly property int pagesCount: Math.floor(totalPagesWidth / pageWidth)
    
    // current homescreen page index
    readonly property int currentPageIndex: {
        let candidateIndex = Math.round(xPosition / (pageSpacing + pageWidth));        
        return Math.max(0, Math.min(pagesCount - 1, candidateIndex));
    }
    
    enum PageViewSwipeState {
        SwipingPages, // horizontal movement between pages
        SwipingAppDrawerVisibility, // opening/closing app drawer
        SwipingAppDrawerList, // scrolling app drawer
        SwipingPagesDown, // custom gesture can be implemented for swiping down on the page view
        DeterminingType
    }
    
    // when we are at the PageView view, we need to distinguish horizontal swipes (changing pages)
    // and vertical swipes (opening drawer)
    property var currentSwipeState: HomeScreenState.DeterminingType
    
    // threshold of movement in a direction before we count that as the defining SwipeState
    readonly property real horizontalSwipeStateDetermineThreshold: 2
    readonly property real verticalSwipeStateDetermineThreshold: 2
    
    // we put the offset position here when determining the swipe type, before we
    // transfer movement over to xPosition and yPosition
    property real xDetermineSwipePosition: 0
    property real yDetermineSwipePosition: 0
    
    // whether animations are currently running
    property bool animationsRunning: openDrawerAnim.running || closeDrawerAnim.running || xAnim.running
    
    // whether the app drawer flickable should be interactive
    property bool appDrawerInteractive: currentView === HomeScreenState.AppDrawerView
    
    // ~~ measurement constants ~~
    
    // dimensions of a page
    readonly property real pageHeight: availableScreenHeight
    readonly property real pageWidth: availableScreenWidth
    
    // spacing between each homescreen page
    readonly property real pageSpacing: 0
    
    // ~~ signals and functions ~~
    
    // cancel edit mode
    signal cancelEditModeForItemsRequested
    
    // cancel all animated moving, as another flick source is taking over
    signal cancelAnimations()
    onCancelAnimations: {
        openDrawerAnim.stop();
        closeDrawerAnim.stop();
        xAnim.stop();
    }
    
    // expose signals necessary to implement any behaviour for the "swipe-down" action on the page view
    signal swipeDownGestureBegin
    signal swipeDownGestureEnd
    signal swipeDownGestureOffset(real value)
    
    // be very careful when resetting the swipe state
    // ensure that we aren't in the middle of a gesture
    function resetSwipeState() {
        currentSwipeState = HomeScreenState.DeterminingType;
        xDetermineSwipePosition = 0;
        yDetermineSwipePosition = 0;
    }
    
    function openAppDrawer() {
        openDrawerAnim.restart();
    }
    
    function openAppDrawerInstantly() {
        yPosition = appDrawerOpenYPosition;
        currentView = HomeScreenState.AppDrawerBeginningView;
    }
    
    function closeAppDrawer() {
        closeDrawerAnim.restart();
    }
    
    function closeAppDrawerInstantly() {
        yPosition = pagesYPosition;
        currentView = HomeScreenState.PageView;
    }
    
    // get the xPosition where the page will be centered on the screen
    function xPositionFromPageIndex(index) {
        return index * (pageWidth + pageSpacing);
    }
    
    // instantly go to the page index
    function goToPageIndex(index) {
        xPosition = xPositionFromPageIndex(index);
    }
    
    // go to the page index, animated
    function animateGoToPageIndex(index, duration) {
        xAnim.duration = duration;
        xAnim.to = xPositionFromPageIndex(index);
        xAnim.restart();
    }
    
    // update the position using an offset
    // called by swipe provider flickable
    function updatePositionWithOffset(x, y) {
        switch (currentView) {
            case HomeScreenState.PageView: {
                switch (currentSwipeState) {
                    case HomeScreenState.DeterminingType:
                        xDetermineSwipePosition += x;
                        yDetermineSwipePosition += y;
                        
                        // check if a swipetype can be determined and started
                        if (Math.abs(xDetermineSwipePosition) >= horizontalSwipeStateDetermineThreshold) {
                            currentSwipeState = HomeScreenState.SwipingPages;
                            xDetermineSwipePosition = 0;
                            yDetermineSwipePosition = 0;
                        } else if (yDetermineSwipePosition >= verticalSwipeStateDetermineThreshold) {
                            currentSwipeState = HomeScreenState.SwipingPagesDown;
                            root.swipeDownGestureBegin();
                            xDetermineSwipePosition = 0;
                            yDetermineSwipePosition = 0;
                        } else if (-yDetermineSwipePosition >= verticalSwipeStateDetermineThreshold) {
                            currentSwipeState = HomeScreenState.SwipingAppDrawerVisibility;
                            xDetermineSwipePosition = 0;
                            yDetermineSwipePosition = 0;
                            
                            // reset app drawer position to top
                            appDrawerFlickable.contentY = 0;
                        }
                        break;
                        
                    case HomeScreenState.SwipingPages:
                        xPosition += x;
                        break;
                        
                    case HomeScreenState.SwipingPagesDown:
                        yPosition = pagesYPosition;
                        if (y !== 0) {
                            root.swipeDownGestureOffset(y);
                        }
                        break;
                        
                    case HomeScreenState.SwipingAppDrawerVisibility: 
                        yPosition = Math.max(appDrawerOpenYPosition, Math.min(pagesYPosition, yPosition + y));
                        break;
                }
                break;
            }
            
            case HomeScreenState.AppDrawerBeginningView: {
                switch (currentSwipeState) {
                    case HomeScreenState.DeterminingType:
                        xDetermineSwipePosition += x;
                        yDetermineSwipePosition += y;
                        
                        // check if a swipetype can be determined and started
                        if (yDetermineSwipePosition >= verticalSwipeStateDetermineThreshold) {
                            currentSwipeState = HomeScreenState.SwipingAppDrawerVisibility;
                            xDetermineSwipePosition = 0;
                            yDetermineSwipePosition = 0;
                        } else if (-yDetermineSwipePosition >= verticalSwipeStateDetermineThreshold) {
                            currentSwipeState = HomeScreenState.SwipingAppDrawerList;
                            yVelocityCalculator.startMeasure(appDrawerFlickable.contentY);
                            xDetermineSwipePosition = 0;
                            yDetermineSwipePosition = 0;
                        }
                        break;
                    case HomeScreenState.SwipingAppDrawerVisibility:
                        yPosition = Math.max(appDrawerOpenYPosition, Math.min(pagesYPosition, yPosition + y));
                        break;
                        
                    case HomeScreenState.SwipingAppDrawerList:
                        // app drawer scrolling
                        let candidateNewPos = appDrawerFlickable.contentY - y;
                        appDrawerFlickable.contentY = candidateNewPos;
                        // update velocity
                        yVelocityCalculator.changePosition(appDrawerFlickable.contentY);
                        break;
                }
                break;
            }
            case HomeScreenState.AppDrawerView: {
                break;
            }
        }
    }
    
    // called after a user finishes an interaction (ex. lets go of the screen)
    // called by swipe provider flickable
    function updateState() {
        cancelAnimations();
        
        // we need to always call resetSwipeState() after each interaction.
        // if we have an animation to run, we rely on the animation to call the function.
        // otherwise, we do it directly here.
        
        switch (currentView) {
            case HomeScreenState.PageView: {
                
                // update vertical position
                switch (currentSwipeState) {
                    case HomeScreenState.DeterminingType: {
                        movingUp ? closeAppDrawer() : openAppDrawer();
                        break;
                    }
                    
                    case HomeScreenState.SwipingPagesDown: {
                        root.swipeDownGestureEnd();
                        root.resetSwipeState();
                        break;
                    }
                    
                    case HomeScreenState.SwipingAppDrawerVisibility: {
                        movingUp ? closeAppDrawer() : openAppDrawer();
                        break;
                    }
                    
                    case HomeScreenState.SwipingPages: {
                        // update pages position
                        let currentPageIndexPosition = xPositionFromPageIndex(currentPageIndex);
                        let duration = Kirigami.Units.longDuration * 2;
                        
                        if (xPosition < currentPageIndexPosition) {
                            if (movingRight) {
                                animateGoToPageIndex(currentPageIndex, duration);
                            } else {
                                animateGoToPageIndex(Math.max(0, currentPageIndex - 1), duration);
                            }
                        } else {
                            if (movingRight) {
                                animateGoToPageIndex(Math.min(pagesCount - 1, currentPageIndex + 1), duration);
                            } else {
                                animateGoToPageIndex(currentPageIndex, duration);
                            }
                        }
                        break;
                    }
                    
                    default: {
                        // this shouldn't occur, but keeps consistent state if it does
                        root.resetSwipeState();
                        break;
                    }
                }
                
                break;
            }
            case HomeScreenState.AppDrawerBeginningView: {
                
                switch (currentSwipeState) {
                    case HomeScreenState.DeterminingType:
                    case HomeScreenState.SwipingAppDrawerVisibility: {
                        movingUp ? closeAppDrawer() : openAppDrawer();
                        break;
                    }
                    case HomeScreenState.SwipingAppDrawerList: {
                        currentView = HomeScreenState.AppDrawerView;
                        appDrawerFlickable.flick(0, -yVelocityCalculator.velocity);
                        root.resetSwipeState();
                        break;
                    }
                    default: {
                        // this shouldn't occur, but keeps consistent state if it does
                        root.resetSwipeState();
                        break;
                    }
                }
                
                break;
            }
            case HomeScreenState.AppDrawerView: {
                break;
            }
        }
    }
    
    // measure velocity of our swipe in the app drawer, so that we can flick
    property var yVelocityCalculator: MobileShell.VelocityCalculator {}
    
    // listen to the app drawer's flickable for if it goes to the top of the list
    // we then update our view state
    property var appDrawerFlickableListener: Connections {
        target: appDrawerFlickable
        
        function onMovementEnded() {
            if (root.currentView === HomeScreenState.AppDrawerView) {
                if (appDrawerFlickable.contentY <= 0) {
                    root.currentView = HomeScreenState.AppDrawerBeginningView;
                }
            }
        }
        
        function onDraggingChanged() {
            if (!appDrawerFlickable.dragging) {
                if (root.currentView === HomeScreenState.AppDrawerView) {
                    if (appDrawerFlickable.contentY <= 0) {
                        root.currentView = HomeScreenState.AppDrawerBeginningView;
                    }
                }
            }
        }
    }
    
    // ~~ property animators ~~
    
    property var xAnim: NumberAnimation {
        target: root
        property: "xPosition"
        easing.type: Easing.OutBack
        onFinished: {
            root.resetSwipeState();
        }
    }
    
    property var openDrawerAnim: NumberAnimation {
        target: root
        property: "yPosition"
        to: appDrawerOpenYPosition 
        duration: Kirigami.Units.longDuration * 2
        easing.type: Easing.OutCubic
        
        onFinished: {
            root.currentView = HomeScreenState.AppDrawerBeginningView;
            root.resetSwipeState();
        }
    }
        
    property var closeDrawerAnim: NumberAnimation { 
        target: root 
        property: "yPosition"
        to: pagesYPosition
        duration: Kirigami.Units.longDuration * 2
        easing.type: Easing.OutCubic
        
        onFinished: {
            root.currentView = HomeScreenState.PageView;
            root.resetSwipeState();
        }
    }
}

