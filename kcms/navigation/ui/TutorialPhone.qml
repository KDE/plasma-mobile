// SPDX-FileCopyrightText: 2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.19 as Kirigami

Item {
    id: root

    required property int phoneWidth
    required property int phoneHeight

    Layout.preferredWidth: phoneWidth
    Layout.preferredHeight: phoneHeight

    property bool showBackground: true
    property int fingerSize: 20
    property int _endTimeout: 2000

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
            visible: root.showBackground

            source: "start-here-kde"
            smooth: true

            anchors.verticalCenter: phone.verticalCenter
            anchors.horizontalCenter: phone.horizontalCenter
        }

        Item {
            id: phoneContent

            clip: true

            anchors.horizontalCenter: phone.horizontalCenter
            anchors.verticalCenter: phone.verticalCenter

            width: phone.width - phone.border.width * 2
            height: phone.height - phone.border.width * 2

            Rectangle {
                id: dummyWindow

                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.Window

                property real scale: 1
                property real offset: 0

                color: Kirigami.Theme.backgroundColor
                width: Math.round(phoneContent.width * scale)
                height: Math.round(phoneContent.height * scale)
                radius: Math.max(0, phone.radius - phone.border.width)

                anchors.verticalCenter: phoneContent.verticalCenter
                anchors.horizontalCenter: phoneContent.horizontalCenter
                anchors.horizontalCenterOffset: Math.round(phoneContent.width * offset)

                Image {
                    source: "konqi_kde.png"

                    anchors.horizontalCenter: dummyWindow.horizontalCenter
                    anchors.verticalCenter: dummyWindow.verticalCenter

                    width: {
                        if (dummyWindow.width > dummyWindow.height * 0.8) {
                            return Math.round(dummyWindow.height * 0.6)
                        }
                        return Math.round(dummyWindow.width * 0.75)
                    }
                    fillMode: Image.PreserveAspectFit
                }
            }

            Rectangle {
                id: dummyWindow2

                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.Window

                property real scale: dummyWindow.scale
                property real offset: 0.5

                color: Kirigami.Theme.backgroundColor
                width: phoneContent.width * scale
                height: phoneContent.height * scale
                radius: Math.max(0, phone.radius - phone.border.width)

                anchors.verticalCenter: phoneContent.verticalCenter
                anchors.horizontalCenter: phoneContent.horizontalCenter
                anchors.horizontalCenterOffset: phoneContent.width * (-offset - 0.6 + dummyWindow.offset)

                Image {
                    source: "katie.png"

                    anchors.horizontalCenter: dummyWindow2.horizontalCenter
                    anchors.verticalCenter: dummyWindow2.verticalCenter

                    width: {
                        if (dummyWindow.width > dummyWindow.height * 0.8) {
                            return Math.round(dummyWindow.height * 0.6)
                        }
                        return Math.round(dummyWindow.width * 0.75)
                    }
                    fillMode: Image.PreserveAspectFit
                }
            }

            Rectangle {
                id: dummyWindow3

                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.Window

                property real scale: dummyWindow.scale
                property real offset: 1.2

                color: Kirigami.Theme.backgroundColor
                width: phoneContent.width * scale
                height: phoneContent.height * scale
                radius: Math.max(0, phone.radius - phone.border.width)

                anchors.verticalCenter: phoneContent.verticalCenter
                anchors.horizontalCenter: phoneContent.horizontalCenter
                anchors.horizontalCenterOffset: phoneContent.width * (-offset + dummyWindow.offset - dummyWindow2.offset)

                Image {
                    source: "Mascot_konqi-base-plasma.png"

                    anchors.horizontalCenter: dummyWindow3.horizontalCenter
                    anchors.verticalCenter: dummyWindow3.verticalCenter

                    width: {
                        if (dummyWindow.width > dummyWindow.height * 0.8) {
                            return Math.round(dummyWindow.height * 0.6)
                        }
                        return Math.round(dummyWindow.width * 0.75)
                    }
                    fillMode: Image.PreserveAspectFit
                }
            }
        }

        Rectangle {
            id: touchPoint

            property int size: root.fingerSize

            width: size
            height: size
            radius: size / 2

            property real yPosition: 0
            property real xPosition: 0

            anchors.verticalCenter: phone.bottom
            anchors.verticalCenterOffset: Math.round(-yPosition * root.phoneHeight / 6)

            anchors.horizontalCenter: phone.horizontalCenter
            anchors.horizontalCenterOffset: Math.round(xPosition * root.phoneWidth * 0.3)

            color: Qt.lighter(Kirigami.Theme.focusColor)
            border.width: 1
            border.color: Qt.darker(Kirigami.Theme.backgroundColor)
        }
    }

    // into task switcher animation
    AnimationHandler {
        id: switcherAnimation

        endTimeout: root._endTimeout

        function reset(): void {
            touchPoint.yPosition = 0;
            touchPoint.xPosition = 0;
        }

        animations: [
            NumberAnimation {
                target: touchPoint
                property: "yPosition"

                from: 0
                to: 1

                onStarted: {
                    switcherAnimation.reset();
                    root.touchOnAnim.start()
                }

                duration: 1500
                easing.type: Easing.InOutQuad
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

                onStarted: {
                    touchPoint.yPosition = 2;
                    root.touchOnAnim.start()
                }
                duration: 500
                easing.type: Easing.InOutQuad
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
            -Kirigami.Units.longDuration * 2,
        ]
    }

    AnimationHandler {
        id: windowSwitcherAnimation

        endTimeout: root._endTimeout

        function reset(): void {
            dummyWindow.offset = 0;
            dummyWindow.scale = 1;
            dummyWindow2.offset = 0.5;
        }

        animations: [
            NumberAnimation {
                target: dummyWindow
                property: "scale"

                from: 1
                to: 0.5

                onStarted: {
                    windowSwitcherAnimation.reset();
                }

                duration: switcherAnimation.animations[0].duration
                easing.type: switcherAnimation.animations[0].easing.type
            },
            NumberAnimation {
                target: dummyWindow
                property: "scale"

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
            switcherAnimation.delays[1],
        ]
    }

    // flick to home animation
    AnimationHandler {
        id: flickAnimation

        endTimeout: root._endTimeout

        function reset(): void {
            touchPoint.yPosition = 0;
        }

        animations: [
            NumberAnimation {
                target: touchPoint
                property: "yPosition"

                from: 0
                to: 1

                onStarted: {
                    root.touchOnAnim.start()
                }

                duration: 900
                easing.type: Easing.InQuart
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
            -Kirigami.Units.longDuration,
        ]
    }

    AnimationHandler {
        id: windowFlickAnimation

        endTimeout: root._endTimeout

        function reset(): void {
            dummyWindow.offset = 0;
            dummyWindow.opacity = 1;
            dummyWindow.scale = 1;
        }

        animations: [
            NumberAnimation {
                target: dummyWindow
                property: "scale"

                from: 1
                to: 0.5

                onStarted: {
                    windowFlickAnimation.reset();
                    dummyWindow2.offset = 0.5;
                }

                duration: flickAnimation.animations[0].duration
                easing.type: flickAnimation.animations[0].easing.type
            },
            NumberAnimation {
                target: dummyWindow
                property: "scale"

                to: 0.1

                duration: 300
                easing.type: Easing.InQuad
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
            immediate,
        ]
    }

    // scrub animation
    AnimationHandler {
        id: scrubAnimation

        endTimeout: root._endTimeout

        function reset(): void {
            touchPoint.yPosition = 0;
            touchPoint.xPosition = 0;
        }

        animations: [
            NumberAnimation {
                target: touchPoint
                property: "yPosition"

                from: 0
                to: 0.2

                onStarted: {
                    scrubAnimation.reset();
                    root.touchOnAnim.start()
                }

                duration: 900
                easing.type: Easing.InOutQuart
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
            dummyWindow.scale = 1;
            dummyWindow.offset = 0;
            dummyWindow2.offset = 0.5
            dummyWindow3.offset = 1.2;
        }

        animations: [
            NumberAnimation {
                // this is just to add some delay at the start when starting at the same time as the touch point animation
                target: dummyWindow
                property: "opacity"

                to: 1

                onStarted: {
                    windowScrubAnimation.reset();
                }

                duration: 0
            },
            NumberAnimation {
                target: dummyWindow
                property: "scale"

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
                property: "scale"

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

    function stopAnimation(): void {
        switcherAnimation.finished.disconnect(startSwitcherAnimation);
        flickAnimation.finished.disconnect(startFlickAnimation);
        scrubAnimation.finished.disconnect(startScrubAnimation);

        switcherAnimation.stop();
        flickAnimation.stop();
        scrubAnimation.stop();
    }

    function startSwitcherAnimation(): void {
        switcherAnimation.start();
        windowSwitcherAnimation.start();
    }

    function loopSwitcherAnimation(): void {
        switcherAnimation.finished.connect(startSwitcherAnimation);
        startSwitcherAnimation();
    }

    function startFlickAnimation(): void {
        flickAnimation.start();
        windowFlickAnimation.start();
    }

    function loopFlickAnimation(): void {
        flickAnimation.finished.connect(startFlickAnimation);
        startFlickAnimation();

    }

    function startScrubAnimation(): void {
        scrubAnimation.start();
        windowScrubAnimation.start();
    }

    function loopScrubAnimation(): void {
        scrubAnimation.finished.connect(startScrubAnimation);
        startScrubAnimation();
    }

    function startCyclingAnimations(): void {
        switcherAnimation.finished.connect(() => {
            switcherAnimation.reset();
            windowSwitcherAnimation.reset();

            startFlickAnimation();
        });
        flickAnimation.finished.connect(() => {
            flickAnimation.reset();
            windowFlickAnimation.reset();

            startScrubAnimation();
        });
        scrubAnimation.finished.connect(() => {
            scrubAnimation.reset();
            windowScrubAnimation.reset();

            startSwitcherAnimation();
        });

        startSwitcherAnimation();
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
}
