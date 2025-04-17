/*
 *  SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Effects

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell as MobileShell

import org.kde.layershell 1.0 as LayerShell


Window {
    id: root

    readonly property int size: Kirigami.Units.gridUnit * 2
    readonly property int margins: Math.round(Kirigami.Units.largeSpace * 0.5)

    property int screenCorner: ActionButton.ScreenCorner.BottomRight
    property int angle: 0
    property string iconSource
    property bool active: false

    signal triggered()

    enum ScreenCorner {
        BottomRight,
        BottomLeft,
        TopLeft,
        TopRight
    }

    // When the button is animating its disappearance, make sure it is transparent to inputs.
    onActiveChanged: {
        ShellUtil.setInputTransparent(root, !active)
        if (active) {
            root.visible = true;
            root.raise();
            hideButton.stop();
            return;
        }
        hideButton.restart();
    }

    LayerShell.Window.scope: "overlay"
    LayerShell.Window.margins.top: margins
    LayerShell.Window.margins.bottom: margins
    LayerShell.Window.margins.left: margins
    LayerShell.Window.margins.right: margins
    LayerShell.Window.layer: LayerShell.Window.LayerOverlay
    LayerShell.Window.exclusionZone: -1
    LayerShell.Window.keyboardInteractivity: LayerShell.Window.KeyboardInteractivityNone
    LayerShell.Window.anchors: {
        if (screenCorner === ActionButton.ScreenCorner.TopLeft) {
            return LayerShell.Window.AnchorTop | LayerShell.Window.AnchorLeft
        } else if (screenCorner === ActionButton.ScreenCorner.BottomRight) {
            return LayerShell.Window.AnchorBottom | LayerShell.Window.AnchorRight
        } else if (screenCorner === ActionButton.ScreenCorner.BottomLeft) {
            return LayerShell.Window.AnchorBottom | LayerShell.Window.AnchorLeft
        } else {
            return LayerShell.Window.AnchorTop | LayerShell.Window.AnchorRight
        }
    }

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    // Double the set button size to leave room for button scale animation.
    width: size * 2
    height: size * 2

    visible: active

    color: "transparent"

    // Hide the root window after the button disappearing animation finishes.
    Timer {
        id: hideButton
        interval: Kirigami.Units.longDuration
        repeat: false
        onTriggered: if (!active) root.visible = false;
    }

    Component.onCompleted: {
        // Because the window surface area had to be made larger to accommodate the button scale animation,
        // set the input region to the size of the actual button.
        ShellUtil.setInputRegion(root, Qt.rect((root.width - size) / 2, (root.height - size) / 2, size, size));
        ShellUtil.setInputTransparent(root, !active);
    }

    Controls.Control {
        id: content
        anchors.centerIn: parent
        width: root.size
        height: root.size
        opacity: root.active ? 1 : 0

        property double scale: !root.active ? 0.5 : (button.pressed ? 1.5 : 1)

        Behavior on scale {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutBack
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCirc
            }
        }

        transform: Scale {
            origin.x: root.size / 2
            origin.y: root.size / 2
            xScale: content.scale
            yScale: content.scale
        }

        MultiEffect {
            anchors.fill: parent
            source: simpleShadow
            blurMax: 16
            shadowEnabled: true
            shadowVerticalOffset: 1
            shadowOpacity: 0.85
            shadowColor: Qt.lighter(Kirigami.Theme.backgroundColor, 0.2)
        }

        Rectangle {
            id: simpleShadow
            anchors.fill: parent
            anchors.leftMargin: -1
            anchors.rightMargin: -1
            anchors.bottomMargin: -1

            color: {
                let darkerBackgroundColor = Qt.darker(Kirigami.Theme.backgroundColor, 1.3);
                return Qt.rgba(darkerBackgroundColor.r, darkerBackgroundColor.g, darkerBackgroundColor.b, 0.5)
            }
            radius: root.size
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.lighter(Kirigami.Theme.backgroundColor, 1.5)
            radius: root.size
            opacity: 0.85
        }

        Controls.AbstractButton {
            id: button
            anchors.fill: parent

            MobileShell.HapticsEffect {
                id: haptics
            }

            contentItem: Item {
                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.small
                    height: Kirigami.Units.iconSizes.small
                    transformOrigin: Item.Center
                    rotation: root.angle
                    source: root.iconSource
                }
            }

            onPressed: {
                haptics.buttonVibrate();
            }

            onReleased: {
                if (active) root.triggered();
            }
        }
    }
}
