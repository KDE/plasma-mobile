// SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Window

import org.kde.kirigami as Kirigami

import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell.windowplugin as WindowPlugin
import org.kde.plasma.plasmoid

/**
 * Component that animates an app opening from a location.
 */

MouseArea { // use mousearea to ensure clicks don't go behind
    id: root
    visible: false

    property alias backgroundColor: background.color
    property alias icon: icon.source

    property bool __openRequested: false
    
    function open(splashIcon) {
        iconParent.scale = 0.5;
        background.scale = 0.5;
        backgroundParent.x = 0;
        backgroundParent.y = 0;
        __openRequested = true;
        updateIconSource(splashIcon);
    }

    function openWithPosition(splashIcon, x, y, sourceIconSize) {
        iconParent.scale = sourceIconSize/iconParent.width;
        background.scale = 0;
        backgroundParent.x = -root.width/2 + x
        backgroundParent.y = -root.height/2 + y
        __openRequested = true;
        updateIconSource(splashIcon);
    }
    
    function close() {
        visible = false;
        colorGenerator.resetColor();
    }

    // call this after everything has loaded
    function actuallyOpen() {
        __openRequested = false;
        if (ShellSettings.Settings.animationsEnabled) {
            openAnimComplex.restart();
        } else {
            openAnimSimple.restart();
        }
    }

    // close when an app opens
    property bool windowActive: Window.active
    onWindowActiveChanged: root.close();
    
    // close when homescreen requested
    Connections {
        target: MobileShellState.ShellDBusClient
        function onOpenHomeScreenRequested() {
            root.close();
        }
    }
        
    Connections {
        target: WindowPlugin.WindowUtil

    // Open StartupFeedback when the notifier gives an app (ex. from Milou search)
    // TODO: This is problematic with multiple screens, because we don't have any info given
    //       on which screen the app is opening on. Thus StartupFeedback would just open on
    //       every single screen...
    // -> We have it disabled for now until some solution is found. We manually open StartupFeedback
    //    from launches in the homescreen (call open()).
    //
    //     function onAppActivationStarted(appId, iconName) {
    //         if (!openAnimComplex.running && !root.__openRequested) {
    //             // TODO: this doesn't work because it gets triggered on screen 0 even if the app is opening on screen 1
    //             // HACK: We have no way of knowing which screen this app is going to open on
    //             //       -> Assume the first screen for now
    //             if (Plasmoid.screen === 0) {
    //                 root.open(iconName);
    //             }
    //         }
    //     }

        function onAppActivationFinished(appId, iconName) {
            if (iconName === root.icon.name) {
                root.close();
            }
        }
    }

    function updateIconSource(source) {
        if (icon.source !== source) {
            // the colors are generated async from the icon, so we need to ensure we don't display an old color
            // for a moment when an app opens
            colorGenerator.resetColor();
        } else {
            // case where we set the same icon, ensure the color is set
            colorGenerator.updateColor();
        }
        icon.source = source;
    }

    Kirigami.ImageColors {
        id: colorGenerator
        source: icon.source

        // the colors are generated async from the icon, so we need to ensure we don't display an old color
        // for a moment when an app opens
        property color colorToUse: 'transparent'

        function resetColor() {
            colorToUse = 'transparent';
        }
        function updateColor() {
            colorToUse = colorGenerator.dominant;

            // once color is finished updating, start the animation
            if (root.__openRequested) {
                root.actuallyOpen();
            }
        }
        onPaletteChanged: {
            // update color once palette has loaded
            updateColor();
        }
    }

    // animation that moves the icon
    SequentialAnimation {
        id: openAnimComplex

        ScriptAction {
            script: {
                root.opacity = 1;
                root.visible = true;
            }
        }

        // slight pause to give slower devices time to catch up when the item becomes visible
        PauseAnimation { duration: 20 }

        ParallelAnimation {
            id: parallelAnim
            property real animationDuration: Kirigami.Units.longDuration + Kirigami.Units.shortDuration

            ScaleAnimator {
                target: background
                from: background.scale
                to: 1
                duration: parallelAnim.animationDuration
                easing.type: Easing.OutCubic
            }
            ScaleAnimator {
                target: iconParent
                from: iconParent.scale
                to: 1
                duration: parallelAnim.animationDuration
                easing.type: Easing.OutCubic
            }
            XAnimator {
                target: backgroundParent
                from: backgroundParent.x
                to: 0
                duration: parallelAnim.animationDuration
                easing.type: Easing.OutCubic
            }
            YAnimator {
                target: backgroundParent
                from: backgroundParent.y
                to: 0
                duration: parallelAnim.animationDuration
                easing.type: Easing.OutCubic
            }
        }

        ScriptAction {
            script: {
                // close the app drawer after it isn't visible
                MobileShellState.ShellDBusClient.resetHomeScreenPosition();
            }
        }
    }

    // animation that just fades in
    SequentialAnimation {
        id: openAnimSimple

        ScriptAction {
            script: {
                root.opacity = 0;
                root.visible = true;
                background.scale = 1;
                iconParent.scale = 1;
                backgroundParent.x = 0;
                backgroundParent.y = 0;
            }
        }

        NumberAnimation {
            target: root
            properties: "opacity"
            from: 0
            to: 1
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutCubic
        }

        ScriptAction {
            script: {
                // close the app drawer after it isn't visible
                MobileShellState.ShellDBusClient.resetHomeScreenPosition();
            }
        }
    }

    Item {
        id: backgroundParent
        width: root.width
        height: root.height
        
        Rectangle {
            id: background
            anchors.fill: parent

            color: colorGenerator.colorToUse
        }

        Item {
            id: iconParent
            anchors.centerIn: background
            width: Kirigami.Units.iconSizes.enormous
            height: width

            Kirigami.Icon {
                id: icon
                anchors.fill: parent
            }

            MultiEffect {
                anchors.fill: icon
                source: icon
                shadowEnabled: true
                blurMax: 16
                shadowColor: "#80000000"
            }
        }
    }
}

