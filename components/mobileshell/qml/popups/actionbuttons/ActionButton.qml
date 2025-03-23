/*
 *  SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell as MobileShell

import org.kde.layershell 1.0 as LayerShell


Window {
    id: root

    readonly property int size: Kirigami.Units.gridUnit * 2
    readonly property int margins: Math.round(Kirigami.Units.largeSpace * 0.5)

    property int screenEdge: ActionButton.ScreenEdge.Bottom
    property int angle: 0
    property string iconSource
    property bool active: false

    signal triggered()

    enum ScreenEdge {
        Bottom,
        Left,
        Top,
        Right
    }

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
        if (screenEdge === ActionButton.ScreenEdge.Top) {
            return LayerShell.Window.AnchorTop | LayerShell.Window.AnchorLeft
        } else if (screenEdge === ActionButton.ScreenEdge.Bottom) {
            return LayerShell.Window.AnchorBottom | LayerShell.Window.AnchorRight
        } else if (screenEdge === ActionButton.ScreenEdge.Left) {
            return LayerShell.Window.AnchorBottom | LayerShell.Window.AnchorLeft
        } else {
            return LayerShell.Window.AnchorTop | LayerShell.Window.AnchorRight
        }
    }

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    width: size * 2
    height: size * 2

    visible: active

    color: "transparent"

    Timer {
        id: hideButton
        interval: Kirigami.Units.longDuration
        repeat: false
        onTriggered: if (!active) root.visible = false;
    }

    Component.onCompleted: {
        ShellUtil.setInputRegion(root, Qt.rect((root.width - size) / 2, (root.height - size) / 2, size, size));
        ShellUtil.setInputTransparent(root, !active);
    }

    AbstractButton {
        id: button
        anchors.centerIn: parent
        padding: root.size / 2
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
            xScale: button.scale
            yScale: button.scale
        }

        MobileShell.HapticsEffect {
            id: haptics
        }

        background: Rectangle {
            radius: root.size
            color: Qt.rgba(255, 255, 255, button.pressed ? 0.5 : 0.2)
        }

        contentItem: Item {
            Kirigami.Icon {
                anchors.centerIn: parent
                width: Kirigami.Units.iconSizes.small
                height: Kirigami.Units.iconSizes.small
                transformOrigin: Item.Center
                rotation: root.angle
                source: root.iconSource
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
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
