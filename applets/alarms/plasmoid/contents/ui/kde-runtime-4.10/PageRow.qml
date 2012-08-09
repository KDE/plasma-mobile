/****************************************************************************
**
** Copyright (C) 2012 Marco Martin  <mart@kde.org>
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the Qt Components project.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
**     the names of its contributors may be used to endorse or promote
**     products derived from this software without specific prior written
**     permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 1.1
import org.kde.plasma.components 0.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.extras 0.1 as PlasmaExtras

import "PageStack.js" as Engine

Item {
    id: actualRoot

    width: parent ? parent.width : 0
    height: parent ? parent.height : 0


    property int depth: Engine.getDepth()
    property Item currentPage: null
    property ToolBar toolBar
    property variant initialPage
    //A column is wide enough for 30 characters
    property int columnWidth: Math.round(parent.width/(theme.defaultFont.mSize.width*30)) > 0 ? parent.width/Math.round(parent.width/(theme.defaultFont.mSize.width*30)) : width
    property alias clip: scrollArea.clip

    // Indicates whether there is an ongoing page transition.
    property bool busy: internal.ongoingTransitionCount > 0

    // Pushes a page on the stack.
    // The page can be defined as a component, item or string.
    // If an item is used then the page will get re-parented.
    // If a string is used then it is interpreted as a url that is used to load a page component.
    //
    // The page can also be given as an array of pages. In this case all those pages will be pushed
    // onto the stack. The items in the stack can be components, items or strings just like for single
    // pages. Additionally an object can be used, which specifies a page and an optional properties
    // property. This can be used to push multiple pages while still giving each of them properties.
    // When an array is used the transition animation will only be to the last page.
    //
    // The properties argument is optional and allows defining a map of properties to set on the page.
    // If the immediate argument is true then no transition animation is performed.
    // Returns the page instance.
    function push(page, properties, immediate)
    {
        var item = Engine.push(page, properties, false, immediate)
        scrollToLevel(depth)
        return item
    }

    // Pops a page off the stack.
    // If page is specified then the stack is unwound to that page, to unwind to the first page specify
    // page as null. If the immediate argument is true then no transition animation is performed.
    // Returns the page instance that was popped off the stack.
    function pop(page, immediate)
    {
        return Engine.pop(page, immediate);
    }

    // Replaces a page on the stack.
    // See push() for details.
    function replace(page, properties, immediate)
    {
        return Engine.push(page, properties, true, immediate);
    }

    // Clears the page stack.
    function clear()
    {
        return Engine.clear();
    }

    // Iterates through all pages (top to bottom) and invokes the specified function.
    // If the specified function returns true the search stops and the find function
    // returns the page that the iteration stopped at. If the search doesn't result
    // in any page being found then null is returned.
    function find(func)
    {
        return Engine.find(func);
    }

    // Scroll the view to have the page of the given level as first item
    function scrollToLevel(level)
    {
        if (level < 0 || level > depth || root.width < width) {
            return
        }

        scrollAnimation.to = Math.max(0, Math.min(Math.max(0, columnWidth * level - columnWidth), columnWidth*depth- mainFlickable.width))
        scrollAnimation.running = true
    }

    NumberAnimation {
        id: scrollAnimation
        target: mainFlickable
        properties: "contentX"
        duration: internal.transitionDuration
        easing.type: Easing.InOutQuad
    }

    // Called when the page stack visibility changes.
    onVisibleChanged: {
        if (currentPage) {
            internal.setPageStatus(currentPage, visible ? PageStatus.Active : PageStatus.Inactive);
            if (visible)
                currentPage.visible = currentPage.parent.visible = true;
        }
    }

    onInitialPageChanged: {
        if (!internal.completed) {
            return
        }

        if (initialPage) {
            if (depth == 0) {
                push(initialPage, null, true)
            } else if (depth == 1) {
                replace(initialPage, null, true)
            } else {
                console.log("Cannot update PageStack.initialPage")
            }
        }
    }

    Component.onCompleted: {
        internal.completed = true
        if (initialPage && depth == 0)
            push(initialPage, null, true)
    }

    QtObject {
        id: internal

        // The number of ongoing transitions.
        property int ongoingTransitionCount: 0

        //FIXME: there should be a way to access to theh without storing it in an ugly way
        property bool completed: false

        // Duration of transition animation (in ms)
        property int transitionDuration: 250

        // Sets the page status.
        function setPageStatus(page, status)
        {
            if (page != null) {
                if (page.status !== undefined) {
                    if (status == PageStatus.Active && page.status == PageStatus.Inactive)
                        page.status = PageStatus.Activating;
                    else if (status == PageStatus.Inactive && page.status == PageStatus.Active)
                        page.status = PageStatus.Deactivating;

                    page.status = status;
                }
            }
        }
    }

    PlasmaExtras.ScrollArea {
        id: scrollArea
        anchors.fill: parent
        Flickable {
            id: mainFlickable
            anchors.fill: parent
            interactive: root.width > width
            boundsBehavior: Flickable.StopAtBounds
            contentWidth: root.width
            contentHeight: height
            Row {
                id: root
                spacing: -100
                width: columnWidth*depth
                height: parent.height
                Behavior on width {
                    NumberAnimation {
                        duration: internal.transitionDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
            onMovementEnded: {print(Math.round(contentX/columnWidth))
                scrollToLevel(Math.round(contentX/columnWidth)+1)
            }
        }
    }

    Component {
        id: svgShadowComponent
        PlasmaCore.SvgItem {
            property Item container
            z: 800
            svg: PlasmaCore.Svg {imagePath: "widgets/scrollwidget"}
            elementId: "border-left"
            width: naturalSize.width
            opacity: container.pageDepth == actualRoot.depth ? 1 : 0.7
            anchors {
                left: container.pageParent.right
                top: container.pageParent.top
                bottom: container.pageParent.bottom
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: internal.transitionDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    // Component for page containers.
    Component {
        id: containerComponent

        Item {
            id: container

            width: columnWidth + 100
            height: parent ? parent.height : 0

            x: 0

            // The actual parent of page: page will anchor to that
            property Item pageParent: actualContainer

            property int pageDepth: 0
            Component.onCompleted: {
                pageDepth = Engine.getDepth() + 1
                container.z = -Engine.getDepth()
            }

            // The states correspond to the different possible positions of the container.
            state: "Hidden"

            // The page held by this container.
            property Item page: null

            // The owner of the page.
            property Item owner: null

            // The width of the longer stack dimension
            property int stackWidth: Math.max(actualRoot.width, actualRoot.height)


            // Flag that indicates the container should be cleaned up after the transition has ended.
            property bool cleanupAfterTransition: false

            // Flag that indicates if page transition animation is running
            property bool transitionAnimationRunning: false

            // State to be set after previous state change animation has finished
            property string pendingState: "none"

            // Ensures that transition finish actions are executed
            // in case the object is destroyed before reaching the
            // end state of an ongoing transition
            Component.onDestruction: {
                if (transitionAnimationRunning)
                    transitionEnded();
            }

            Item {
                id: actualContainer

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                    rightMargin: 100
                }
                width: columnWidth
            }

            Image {
                z: 800
                source: "image://appbackgrounds/shadow-right"
                fillMode: Image.TileVertically
                opacity: container.pageDepth == actualRoot.depth ? 1 : 0.7
                anchors {
                    left: actualContainer.right
                    top: actualContainer.top
                    bottom: actualContainer.bottom
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: internal.transitionDuration
                        easing.type: Easing.InOutQuad
                    }
                }
                onStatusChanged: {
                    if (status == Image.Error) {
                        var shadow = svgShadowComponent.createObject(container)
                        shadow.container = container
                        destroy()
                    }
                }
            }

            // Sets pending state as current if state change is delayed
            onTransitionAnimationRunningChanged: {
                if (!transitionAnimationRunning && pendingState != "none") {
                    state = pendingState;
                    pendingState = "none";
                }
            }

            // Handles state change depening on transition animation status
            function setState(newState)
            {
                if (transitionAnimationRunning)
                    pendingState = newState;
                else
                    state = newState;
            }

            // Performs a push enter transition.
            function pushEnter(immediate, orientationChanges)
            {
                if (!immediate) {
                    setState("Right");
                }
                setState("");
                page.visible = true;
                if (actualRoot.visible && immediate)
                    internal.setPageStatus(page, PageStatus.Active);
            }

            // Performs a push exit transition.
            function pushExit(replace, immediate, orientationChanges)
            {
                if (actualRoot.visible && immediate)
                    internal.setPageStatus(page, PageStatus.Inactive);
                if (replace) {
                    if (immediate)
                        cleanup();
                    else
                        cleanupAfterTransition = true;
                }
            }

            // Performs a pop enter transition.
            function popEnter(immediate, orientationChanges)
            {
                setState("");
                page.visible = true;
                if (actualRoot.visible && immediate)
                    internal.setPageStatus(page, PageStatus.Active);
            }

            // Performs a pop exit transition.
            function popExit(immediate, orientationChanges)
            {
                setState(immediate ? "Hidden" : "Left");

                if (actualRoot.visible && immediate)
                    internal.setPageStatus(page, PageStatus.Inactive);
                if (immediate)
                    cleanup();
                else
                    cleanupAfterTransition = true;
            }

            // Called when a transition has started.
            function transitionStarted()
            {
                container.clip = true
                transitionAnimationRunning = true;
                internal.ongoingTransitionCount++;
                if (actualRoot.visible) {
                    internal.setPageStatus(page, (state == "") ? PageStatus.Activating : PageStatus.Deactivating);
                }
            }

            // Called when a transition has ended.
            function transitionEnded()
            {
                container.clip = false
                if (state != "")
                    state = "Hidden";
                if (actualRoot.visible)
                    internal.setPageStatus(page, (state == "") ? PageStatus.Active : PageStatus.Inactive);

                internal.ongoingTransitionCount--;
                transitionAnimationRunning = false;

                if (cleanupAfterTransition) {
                    cleanup();
                }
            }

            states: [
                // Explicit properties for default state.
                State {
                    name: ""
                    PropertyChanges { target: container; visible: true; opacity: 1 }
                    PropertyChanges { target: container; width: columnWidth+100}
                },
                // Start state for pop entry, end state for push exit.
                State {
                    name: "Left"
                    PropertyChanges { target: container; opacity: 0 }
                    PropertyChanges { target: container; width: 100}
                },
                // Start state for push entry, end state for pop exit.
                State {
                    name: "Right"
                    PropertyChanges { target: container; opacity: 0 }
                    PropertyChanges { target: container; width: 100}
                },
                // Inactive state.
                State {
                    name: "Hidden"
                    PropertyChanges { target: container; visible: false }
                    PropertyChanges { target: container; width: columnWidth+100}
                }
            ]

            transitions: [
                // Push exit transition
                Transition {
                    from: ""; to: "Left"
                    SequentialAnimation {
                        ScriptAction { script: transitionStarted() }
                        ParallelAnimation {
                            PropertyAnimation { properties: "width"; easing.type: Easing.InQuad; duration: internal.transitionDuration }
                            PropertyAnimation { properties: "opacity"; easing.type: Easing.InQuad; duration: internal.transitionDuration }
                        }
                        ScriptAction { script: transitionEnded() }
                    }
                },
                // Pop entry transition
                Transition {
                    from: "Left"; to: ""
                    SequentialAnimation {
                        ScriptAction { script: transitionStarted() }
                        ParallelAnimation {
                            PropertyAnimation { properties: "width"; easing.type: Easing.OutQuad; duration: internal.transitionDuration }
                            PropertyAnimation { properties: "opacity"; easing.type: Easing.InQuad; duration: internal.transitionDuration }
                        }
                        ScriptAction { script: transitionEnded() }
                    }
                },
                // Pop exit transition
                Transition {
                    from: ""; to: "Right"
                    SequentialAnimation {
                        ScriptAction { script: transitionStarted() }
                        ParallelAnimation {
                            PropertyAnimation { properties: "width"; easing.type: Easing.InQuad; duration: internal.transitionDuration }
                            PropertyAnimation { properties: "opacity"; easing.type: Easing.InQuad; duration: internal.transitionDuration }
                        }
                        // Workaround for transition animation bug causing ghost view with page pop transition animation
                        // TODO: Root cause still unknown
                        PropertyAnimation {}
                        ScriptAction { script: transitionEnded() }
                    }
                },
                // Push entry transition
                Transition {
                    from: "Right"; to: ""
                    SequentialAnimation {
                        ScriptAction { script: transitionStarted() }
                        ParallelAnimation {
                            PropertyAnimation { properties: "width"; easing.type: Easing.OutQuad; duration: internal.transitionDuration }
                            PropertyAnimation { properties: "opacity"; easing.type: Easing.InQuad; duration: internal.transitionDuration }
                        }
                        ScriptAction { script: transitionEnded() }
                    }
                }
            ]

            // Cleans up the container and then destroys it.
            function cleanup()
            {
                if (page != null) {
                    if (page.status == PageStatus.Active) {
                        internal.setPageStatus(page, PageStatus.Inactive)
                    }
                    if (owner != container) {
                        // container is not the owner of the page - re-parent back to original owner
                        page.visible = false;
                        page.anchors.fill = undefined
                        page.parent = owner;
                    }
                }

                container.destroy();
            }
        }
    }
}
