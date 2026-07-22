// SPDX-FileCopyrightText: 2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: root

    required property int phoneWidth
    required property int phoneHeight

    Layout.preferredWidth: phoneWidth
    Layout.preferredHeight: phoneHeight

    property int fingerSize: 20
    property int _endTimeout: 2000
    property bool _gesturesTutorial: true
    property int _activeIndex: 0

    function playTutorial(gestureMode: bool, index: int): void {
        _gesturesTutorial = gestureMode;
        stopAllAnimations(gestureMode);

        if (_gesturesTutorial) {
            playGestureTutorial(index);
        } else {
            playButtonTutorial(index);
        }
    }

    function stopAllAnimations(gestureMode: bool): void {
        _gesturesTutorial = gestureMode;

        switcherAnimation.finished.disconnect(loopCurrentAnimation);
        flickAnimation.finished.disconnect(loopCurrentAnimation);
        scrubAnimation.finished.disconnect(loopCurrentAnimation);
        buttonsTaskSwitcherAnimation.finished.disconnect(loopCurrentAnimation);
        buttonsHomeAnimation.finished.disconnect(loopCurrentAnimation);
        buttonsCloseAnimation.finished.disconnect(loopCurrentAnimation);

        switcherAnimation.stop();
        windowSwitcherAnimation.stop();
        flickAnimation.stop();
        windowFlickAnimation.stop();
        scrubAnimation.stop();
        windowScrubAnimation.stop();
        buttonsTaskSwitcherAnimation.stop();
        buttonsHomeAnimation.stop();
        buttonsCloseAnimation.stop();

        touchOnAnim.stop();
        touchOffAnim.stop();
        homeScreenBackgroundOpacityAnimation.stop();
        homeScreenBackgroundScaleAnimation.stop();

        navigationBar.stopAnimations();

        switcherAnimation.reset();
        windowSwitcherAnimation.reset();
        flickAnimation.reset();
        windowFlickAnimation.reset();
        scrubAnimation.reset();
        windowScrubAnimation.reset();
        buttonsTaskSwitcherAnimation.reset();
        buttonsHomeAnimation.reset();
        buttonsCloseAnimation.reset();
    }

    function loopCurrentAnimation(): void {
        playTutorial(_gesturesTutorial, _activeIndex);
    }

    function playGestureTutorial(index: int): void {
        _activeIndex = index;
        if (index === 0) {
            switcherAnimation.finished.connect(loopCurrentAnimation);
            switcherAnimation.start();
            windowSwitcherAnimation.start();
        } else if (index === 1) {
            flickAnimation.finished.connect(loopCurrentAnimation);
            flickAnimation.start();
            windowFlickAnimation.start();
        } else if (index === 2) {
            scrubAnimation.finished.connect(loopCurrentAnimation);
            scrubAnimation.start();
            windowScrubAnimation.start();
        }
    }

    function playButtonTutorial(index: int): void {
        _activeIndex = index;

        if (index === 0) {
            buttonsTaskSwitcherAnimation.finished.connect(loopCurrentAnimation);
            buttonsTaskSwitcherAnimation.start();
        } else if (index === 1) {
            buttonsHomeAnimation.finished.connect(loopCurrentAnimation);
            buttonsHomeAnimation.start();
        } else if (index === 2) {
            buttonsCloseAnimation.finished.connect(loopCurrentAnimation);
            buttonsCloseAnimation.start();
        }
    }

    Rectangle {
        id: phone
        width: root.phoneWidth
        height: root.phoneHeight

        border.color: {
            let color = Kirigami.Theme.textColor
            // note: luminance calculation from https://en.wikipedia.org/wiki/Relative_luminance
            let luminance = (0.2126*color.r + 0.7152*color.g + 0.0722*color.b);
            if (luminance > 0.5) {
                return Qt.darker(color);
            }
            return Qt.lighter(color);
        }
        border.width: 2
        color: Qt.darker(Kirigami.Theme.backgroundColor)
        radius: Kirigami.Units.largeSpacing

        Kirigami.Icon {
            id: homeScreenBackground
            opacity: 0

            source: "start-here-kde"
            smooth: true

            anchors.verticalCenter: phone.verticalCenter
            anchors.horizontalCenter: phone.horizontalCenter

            NumberAnimation {
                id: homeScreenBackgroundOpacityAnimation
                target: homeScreenBackground
                property: "opacity"
                from: 0
                to: 1
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }

            NumberAnimation {
                id: homeScreenBackgroundScaleAnimation
                target: homeScreenBackground
                property: "scale"
                from: 1.5
                to: 1
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }

            function homeScreenBackgroundAnimation() {
                homeScreenBackgroundOpacityAnimation.restart();
                homeScreenBackgroundScaleAnimation.restart();
            }
        }

        Item {
            id: phoneContent
            clip: true
            anchors.centerIn: parent
            width: phone.width - phone.border.width * 2
            height: phone.height - phone.border.width * 2

            DummyWindow {
                id: dummyWindow
                imageSource: "images/konqi_kde.png"
                baseWidth: phoneContent.width
                baseHeight: phoneContent.height
                phoneRadius: phone.radius
                phoneBorderWidth: phone.border.width

                anchors.verticalCenter: phoneContent.verticalCenter
                anchors.horizontalCenter: phoneContent.horizontalCenter
                anchors.horizontalCenterOffset: Math.round(phoneContent.width * offset)
            }

            DummyWindow {
                id: dummyWindow2
                windowScale: dummyWindow.windowScale
                offset: 0.5
                imageSource: "images/katie.png"
                baseWidth: phoneContent.width
                baseHeight: phoneContent.height
                phoneRadius: phone.radius
                phoneBorderWidth: phone.border.width

                anchors.verticalCenter: phoneContent.verticalCenter
                anchors.horizontalCenter: phoneContent.horizontalCenter
                anchors.horizontalCenterOffset: phoneContent.width * (-offset - 0.6 + dummyWindow.offset)
            }

            DummyWindow {
                id: dummyWindow3
                windowScale: dummyWindow.windowScale
                offset: 1.2
                imageSource: "images/Mascot_konqi-base-plasma.png"
                baseWidth: phoneContent.width
                baseHeight: phoneContent.height
                phoneRadius: phone.radius
                phoneBorderWidth: phone.border.width

                anchors.verticalCenter: phoneContent.verticalCenter
                anchors.horizontalCenter: phoneContent.horizontalCenter
                anchors.horizontalCenterOffset: phoneContent.width * (-offset + dummyWindow.offset - dummyWindow2.offset)
            }

            NavigationBar {
                id: navigationBar
                anchors.fill: parent
                visible: !root._gesturesTutorial
                phoneRadius: phone.radius
                phoneBorderWidth: phone.border.width
            }

            // phone border to overlay over any imperfections
            Rectangle {
                anchors.fill: parent
                anchors.margins: -phone.border.width

                border.color: phone.border.color
                border.width: phone.border.width
                color: "transparent"
                radius: Kirigami.Units.largeSpacing
            }
        }

        Rectangle {
            id: touchPoint
            property int size: root.fingerSize
            property real yPosition: 0
            property real xPosition: 0

            width: size
            height: size
            radius: size / 2

            anchors.verticalCenter: phone.bottom
            anchors.verticalCenterOffset: Math.round(-yPosition * root.phoneHeight / 6)
            anchors.horizontalCenter: phone.horizontalCenter
            anchors.horizontalCenterOffset: Math.round(xPosition * root.phoneWidth * 0.3)

            color: Qt.lighter(Kirigami.Theme.focusColor)
            border.width: 1
            border.color: Qt.darker(Kirigami.Theme.backgroundColor)
        }
    }

    // gestures - into task switcher animation
    AnimationHandler {
        id: switcherAnimation

        endTimeout: root._endTimeout

        function reset(): void {
            touchPoint.yPosition = 0;
            touchPoint.xPosition = 0;
            touchPoint.visible = true;
        }

        animations: [
            NumberAnimation {
                target: touchPoint
                property: "yPosition"
                from: 0
                to: 1
                duration: 1500
                easing.type: Easing.InOutQuad

                onStarted: {
                    switcherAnimation.reset();
                    root.touchOnAnim.start();
                }
            },
            NumberAnimation {
                target: touchPoint
                property: "size"
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InQuad
            },
            NumberAnimation {
                target: touchPoint
                property: "xPosition"
                from: 0
                to: 1.5
                duration: 500
                easing.type: Easing.InOutQuad

                onStarted: {
                    touchPoint.yPosition = 2;
                    root.touchOnAnim.start();
                }
            },
            NumberAnimation {
                target: touchPoint
                property: "size"
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InQuad
            }
        ]
        delays: [
            500,
            500,
            -Kirigami.Units.longDuration * 2
        ]
    }

    AnimationHandler {
        id: windowSwitcherAnimation
        endTimeout: root._endTimeout
        function reset(): void {
            dummyWindow.offset = 0;
            dummyWindow.windowScale = 1;
            dummyWindow2.offset = 0.5;
            homeScreenBackground.opacity = 0;
        }

        animations: [
            NumberAnimation {
                target: dummyWindow
                property: "windowScale"
                from: 1
                to: 0.5
                duration: switcherAnimation.animations[0].duration
                easing.type: switcherAnimation.animations[0].easing.type

                onStarted: {
                    windowSwitcherAnimation.reset();
                }
            },
            NumberAnimation {
                target: dummyWindow
                property: "windowScale"
                to: 0.55
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            },
            NumberAnimation {
                target: dummyWindow2
                property: "offset"
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            },
            NumberAnimation {
                target: dummyWindow
                property: "offset"
                to: 0.6
                duration: switcherAnimation.animations[2].duration
                easing.type: switcherAnimation.animations[2].easing.type
            }
        ]
        delays: [
            switcherAnimation.delays[0],
            immediate,
            switcherAnimation.delays[1]
        ]
    }

    // gestures - flick to home animation
    AnimationHandler {
        id: flickAnimation
        endTimeout: root._endTimeout
        function reset(): void {
            touchPoint.yPosition = 0;
            touchPoint.visible = true;
        }

        animations: [
            NumberAnimation {
                target: touchPoint
                property: "yPosition"
                from: 0
                to: 1
                duration: 900
                easing.type: Easing.InQuart

                onStarted: {
                    flickAnimation.reset();
                    root.touchOnAnim.start();
                }
            },
            NumberAnimation {
                target: touchPoint
                property: "size"
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InQuad
            }
        ]
        delays: [
            -Kirigami.Units.longDuration
        ]
    }

    AnimationHandler {
        id: windowFlickAnimation
        endTimeout: root._endTimeout
        function reset(): void {
            dummyWindow.offset = 0;
            dummyWindow.opacity = 1;
            dummyWindow.windowScale = 1;
            homeScreenBackground.opacity = 0;
        }

        animations: [
            NumberAnimation {
                target: dummyWindow
                property: "windowScale"
                from: 1
                to: 0.5
                duration: flickAnimation.animations[0].duration
                easing.type: flickAnimation.animations[0].easing.type

                onStarted: {
                    windowFlickAnimation.reset();
                    dummyWindow2.offset = 0.5;
                }
            },
            NumberAnimation {
                target: dummyWindow
                property: "windowScale"
                to: 0.1
                duration: 300
                easing.type: Easing.InQuad

                onFinished: {
                    homeScreenBackground.homeScreenBackgroundAnimation();
                }
            },
            NumberAnimation {
                target: dummyWindow
                property: "opacity"
                to: 0
                duration: 300
                easing.type: Easing.Linear
            }
        ]
        delays: [
            1, // for some reason setting this to 0 creates a runtime error
            immediate
        ]
    }

    // gestures - scrub animation
    AnimationHandler {
        id: scrubAnimation
        endTimeout: root._endTimeout
        function reset(): void {
            touchPoint.yPosition = 0;
            touchPoint.xPosition = 0;
            touchPoint.visible = true;
        }

        animations: [
            NumberAnimation {
                target: touchPoint
                property: "yPosition"
                from: 0
                to: 0.2
                duration: 900
                easing.type: Easing.InOutQuart

                onStarted: {
                    scrubAnimation.reset();
                    root.touchOnAnim.start();
                }
            },
            NumberAnimation {
                target: touchPoint
                property: "xPosition"
                from: 0
                to: 1
                duration: 1500
                easing.type: Easing.InOutQuart
            },
            NumberAnimation {
                target: touchPoint
                property: "xPosition"
                to: 0.5
                duration: 700
                easing.type: Easing.InOutCubic
            },
            NumberAnimation {
                target: touchPoint
                property: "size"
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InQuad
            }
        ]
        delays: [
            0,
            0,
            500
        ]
    }

    AnimationHandler {
        id: windowScrubAnimation
        endTimeout: root._endTimeout
        function reset(): void {
            dummyWindow.windowScale = 1;
            dummyWindow.offset = 0;
            dummyWindow2.offset = 0.5
            dummyWindow3.offset = 1.2;
            homeScreenBackground.opacity = 0;
        }

        animations: [
            NumberAnimation {
                // this is just to add some delay at the start when starting at the same time as the touch point animation
                target: dummyWindow
                property: "opacity"
                to: 1
                duration: 0

                onStarted: {
                    windowScrubAnimation.reset();
                }
            },
            NumberAnimation {
                target: dummyWindow
                property: "windowScale"
                to: 0.55
                duration: 300
                easing.type: Easing.InOutQuad
            },
            NumberAnimation {
                target: dummyWindow2
                property: "offset"
                to: 0
                duration: 300
                easing.type: Easing.InOutQuad
            },
            NumberAnimation {
                target: dummyWindow
                property: "offset"
                to: 1.2
                duration: scrubAnimation.animations[1].duration
                easing.type: Easing.InOutQuint
            },
            NumberAnimation {
                target: dummyWindow
                property: "offset"
                to: 0.6
                duration: scrubAnimation.animations[2].duration
                easing.type: Easing.InOutQuart
            },
            NumberAnimation {
                target: dummyWindow
                property: "windowScale"
                to: 1
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            },
            NumberAnimation { // move leftmost window out of the way, otherwise it overlaps
                target: dummyWindow3
                property: "offset"
                to: 1.8
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            },
            NumberAnimation { // move middle window (that's to be focused) a bit to the side to counteract moving of the first window
                target: dummyWindow2
                property: "offset"
                to: 0.4
                duration: Kirigami.Units.longDuration
                easing.type: Easing.Linear
            },
            NumberAnimation { // move first (rightmost) window to get a bit more space between it and the middle one during the animation
                target: dummyWindow
                property: "offset"
                to: 1
                duration: Kirigami.Units.longDuration
                easing.type: Easing.Linear
            }
        ]
        delays: [
            400,
            immediate,
            scrubAnimation.animations[0].duration - 300 - 400,
            scrubAnimation.delays[1],
            scrubAnimation.delays[2],
            immediate,
            immediate,
            immediate
        ]
    }

    NumberAnimation {
        id: touchOffAnim
        target: touchPoint
        property: "size"
        to: 0
        duration: Kirigami.Units.longDuration
        easing.type: Easing.InQuad
    }

    property var touchOnAnim: NumberAnimation {
        target: touchPoint
        property: "size"
        to: root.fingerSize
        duration: Kirigami.Units.longDuration
        easing.type: Easing.OutQuad
    }

    // buttons - open task switcher animation
    AnimationHandler {
        id: buttonsTaskSwitcherAnimation
        endTimeout: root._endTimeout
        function reset(): void {
            dummyWindow.windowScale = 1;
            dummyWindow.offset = 0;
            dummyWindow2.offset = 0.5
            dummyWindow3.offset = 1.2;
            homeScreenBackground.opacity = 0;
            navigationBar.taskSwitcher = false;
            touchPoint.visible = false;
        }

        animations: [
            NumberAnimation {
                // this is just to add some delay at the start when starting at the same time as the touch point animation
                target: dummyWindow
                property: "opacity"
                to: 1
                duration: 0

                onStarted: {
                    buttonsTaskSwitcherAnimation.reset();
                }
            },
            NumberAnimation {
                target: dummyWindow
                property: "windowScale"
                to: 0.55
                duration: 300
                easing.type: Easing.InOutQuad

                onStarted: {
                    navigationBar.taskSwitcher = true;
                    navigationBar.animateTaskSwitcher();

                }
            },
            NumberAnimation {
                target: dummyWindow2
                property: "offset"
                to: 0
                duration: 300
                easing.type: Easing.InOutQuad
            },
            NumberAnimation {
                target: dummyWindow
                property: "offset"
                to: 0.6
                duration: 700
                easing.type: Easing.InOutQuint
            },
            NumberAnimation {
                target: dummyWindow
                property: "offset"
                to: 0
                duration: 700
                easing.type: Easing.InOutQuart
            },
            NumberAnimation {
                target: dummyWindow
                property: "windowScale"
                to: 1
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad

                onFinished: {
                    navigationBar.taskSwitcher = false;
                }
            },
            NumberAnimation {
                target: dummyWindow3
                property: "offset"
                to: 1.2
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            },
            NumberAnimation {
                target: dummyWindow2
                property: "offset"
                to: 0.5
                duration: Kirigami.Units.longDuration
                easing.type: Easing.Linear
            },
            NumberAnimation {
                target: dummyWindow
                property: "offset"
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.Linear
            }
        ]
        delays: [
            400,
            immediate,
            200,
            700,
            700,
            immediate,
            immediate,
            immediate
        ]
    }

    // buttons - return home animation
    AnimationHandler {
        id: buttonsHomeAnimation
        endTimeout: root._endTimeout
        function reset(): void {
            dummyWindow.offset = 0;
            dummyWindow.opacity = 1;
            dummyWindow.windowScale = 1;
            homeScreenBackground.opacity = 0;
            navigationBar.taskSwitcher = false;
            touchPoint.visible = false;
        }

        animations: [
            NumberAnimation {
                // this is just to add some delay at the start when starting at the same time as the touch point animation
                target: dummyWindow
                property: "opacity"
                to: 1
                duration: 0

                onStarted: {
                    buttonsHomeAnimation.reset();
                }
            },
            NumberAnimation {
                target: dummyWindow
                property: "opacity"
                to: 0
                duration: 0

                onStarted: {
                    navigationBar.animateHome();
                    homeScreenBackground.homeScreenBackgroundAnimation();
                }
            }
        ]
        delays: [
            500
        ]
    }

    // buttons - close app animation
    AnimationHandler {
        id: buttonsCloseAnimation
        endTimeout: root._endTimeout
        function reset(): void {
            dummyWindow.offset = 0;
            dummyWindow.opacity = 1;
            dummyWindow.windowScale = 1;
            homeScreenBackground.opacity = 0;
            navigationBar.taskSwitcher = false;
            touchPoint.visible = false;
        }

        animations: [
            NumberAnimation {
                // this is just to add some delay at the start when starting at the same time as the touch point animation
                target: dummyWindow
                property: "opacity"
                to: 1
                duration: 0

                onStarted: {
                    buttonsCloseAnimation.reset();
                }
            },
            NumberAnimation {
                target: dummyWindow
                property: "opacity"
                to: 0
                duration: 0

                onStarted: {
                    navigationBar.animateClose();
                    homeScreenBackground.homeScreenBackgroundAnimation();
                }
            }
        ]
        delays: [
            500
        ]
    }
}
