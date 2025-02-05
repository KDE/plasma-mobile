// SPDX-FileCopyrightText: 2025 Sebastian Kŭgler <sebas@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later


import QtQuick
import QtQuick.Controls

import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mobileshell.state as MobileShellState


Window {
    id: root

    signal byebye()

    readonly property int fadeOutWait: 1500
    readonly property int fadeDuration: 400
    readonly property real darkOpacity: 0.6
    readonly property real translucentOpacity: 0.0
    readonly property int unlockDuration: 400
    readonly property int bgMargin: 20
    readonly property int lockAnimationDuration: 400
    //readonly property int sliderHeight: Kirigami.Units.gridUnit * 22

    readonly property color textColor: Kirigami.Theme.backgroundColor
    readonly property color backgroundColor: Kirigami.Theme.textColor


    flags: Qt.ToolTip | Qt.FramelessWindowHint | Qt.WA_TranslucentBackground

    color: "#00000000" // important bytes are translucency!
    visible: true
    visibility: Window.FullScreen

    TasksHelper {
        id: tasksHelper
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.log("clicked")
            background.opacity = darkOpacity;
            unlockSlider.opacity = 1.0
            background.scale = 1.0
            bgFadeOutTimer.start()
        }
    }

    Timer {
        id: bgFadeOutTimer
        interval: fadeOutWait
        running: false
        onTriggered: {
            if (unlockSlider.pressed) {
                return;
            }
            background.opacity = translucentOpacity;
            unlockSlider.opacity = translucentOpacity;
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.margins: root.bgMargin
        radius: root.bgMargin
        color: root.backgroundColor
        opacity: translucentOpacity
        Behavior on opacity {
            NumberAnimation { duration: fadeDuration }
        }
    }

    Rectangle {
        id: locked_background

        anchors.fill: parent
        anchors.margins: root.bgMargin
        radius: root.bgMargin
        color: root.backgroundColor
        opacity: 0.0

        Label {
            id: lockText
            anchors.centerIn: parent
            font.pointSize: unlockSlider.sliderHeight / 3
            text: i18n("Touchscreen Locked")
            color: root.textColor
        }
    }

    SequentialAnimation {
        id: lockAnimation
        PauseAnimation { duration: 200 }
        ParallelAnimation {
            NumberAnimation { target: locked_background; property: "scale"; from: 1.2; to: 1.0; duration: lockAnimationDuration }
            NumberAnimation { target: locked_background; property: "opacity"; to: 0.8; duration: lockAnimationDuration }
        }

        PauseAnimation { duration: lockAnimationDuration }

        ParallelAnimation {
            NumberAnimation { target: locked_background; property: "scale"; to: 2.5; duration: lockAnimationDuration }
            NumberAnimation { target: locked_background; property: "opacity"; to: 0.0; duration: lockAnimationDuration }
        }
    }

    ParallelAnimation {
        id: unlockAnimation
        NumberAnimation { target: background; property: "opacity"; to: 0; duration: unlockDuration }
        NumberAnimation { target: background; property: "scale"; to: 0; duration: unlockDuration }
        NumberAnimation { target: unlockText; property: "opacity"; to: 0; duration: unlockDuration / 2  }
    }

    Timer {
        id: unlockTimer
        interval: 300
        running: false
        onTriggered: {
            unlockText.opacity = 0;
            unlockSlider.opacity = 0;
            unlockAnimation.running = true;
            // set app to not fullscreen during our close animation
            tasksHelper.restoreApp();
        }
    }

    /*
    Timer {
        id: lockTimer
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            console.log("     still alive!")
            //console.log("..... locktimer triggers ... panel state setting visible")
            //MobileShellState.ShellDBusClient.panelState = "visible";

        }
    }
    */

    Timer {
        id: resetTimer
        running: false
        interval: unlockDuration * 1.5
        onTriggered: {
            //console.log("reset / quit.")
            background.opacity = 0.0
            background.scale = 1.0
            unlockSlider.value = 0
            unlockText.opacity = 0.0

            //MobileShellState.ShellDBusClient.panelState = "default";

            console.log("Destroying LockTouchScreen.");
            root.visible = false;
            //console.log("rp: "+ root.parent);
            // tasksHelper.restoreApp();
            root.byebye();
            if (root.parent != null) {
                //root.destroy();
            } else {
                // when running standalone / testing
                Qt.quit();
            }
        }
    }

    Slider {
        id: unlockSlider

        property int sliderHeight: Kirigami.Units.gridUnit * 5
        property int sliderWidth: Math.min(root.width * 0.4, Kirigami.Units.gridUnit * 120)
        property int sliderRadius: unlockSlider.sliderHeight / 2


        opacity: translucentOpacity
        visible: opacity != 0.0

        Behavior on opacity {
            NumberAnimation { duration: fadeDuration / 2 }
        }

        x: (root.width - unlockSlider.width) / 2
        y: root.height * 0.7
        width: unlockSlider.sliderWidth
        height: unlockSlider.sliderHeight

        onPressedChanged: {
            if (unlockSlider.value === 1) {
                console.log("unlocking...: " + unlockSlider.value + " width:" + root.width);
                unlockText.opacity = 1.0;
                bgFadeOutTimer.stop();
                unlockTimer.start();
                resetTimer.start();
            } else {
                //console.log("keeping locked, value: " + unlockSlider.value);
                unlockSlider.value = 0;
                bgFadeOutTimer.restart()
            }
        }


        background: Rectangle {
            x: unlockSlider.leftPadding
            y: unlockSlider.topPadding + unlockSlider.availableHeight / 2 - height / 2
            implicitWidth: unlockSlider.sliderWidth
            implicitHeight: unlockSlider.sliderHeight
            width: unlockSlider.availableWidth
            height: implicitHeight
            radius: unlockSlider.sliderRadius
            color: Kirigami.Theme.alternateBackgroundColor
            opacity: 0.7

            Label {
                text: i18n("Slide to Unlock")
                color: Kirigami.Theme.textColor
                opacity: 1.0 - unlockSlider.value
                font.pixelSize: unlockSlider.sliderHeight / 3
                anchors.centerIn: parent
            }

            Rectangle {
                width: unlockSlider.visualPosition * parent.width
                height: parent.height
                opacity: unlockSlider.value
                visible: unlockSlider.value > 0.1 // clickthrough when hidden
                color: Kirigami.Theme.positiveTextColor
                radius: unlockSlider.sliderRadius
            }
        }

        handle: Rectangle {
            x: unlockSlider.leftPadding + unlockSlider.visualPosition * (unlockSlider.availableWidth - width)
            y: unlockSlider.topPadding + unlockSlider.availableHeight / 2 - height / 2
            implicitWidth: unlockSlider.sliderHeight
            implicitHeight: unlockSlider.sliderHeight
            radius: unlockSlider.sliderRadius
            color: Kirigami.Theme.backgroundColor
        }

    }

    Label {
        id: unlockText
        anchors.horizontalCenter: unlockSlider.horizontalCenter
        anchors.bottom: unlockSlider.top
        //anchors.bottomMargin: unlockSlider.sliderHeight
        font.pointSize: unlockSlider.sliderHeight / 3
        text: i18n("Unlocking...")
        color: root.textColor
        opacity: 0.0
        Behavior on opacity {
            NumberAnimation { duration: fadeDuration / 2 }
        }
    }

    Component.onCompleted: {
        console.log("Created LockTouchScreen." + Kirigami.Units.gridUnit);
        lockAnimation.running = true;
        //MobileShellState.ShellDBusClient.panelState = "visible";
        //console.log("panel state is now visible. starting lockTimer")
        //lockTimer.start();
        tasksHelper.setAppFullScreen();
    }
}
