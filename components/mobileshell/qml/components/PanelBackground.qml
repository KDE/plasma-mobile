// SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Effects

Item {
    id: root

    property int panelType: PanelBackground.PanelType.Base
    property real flatten: 0 // flattens out the border and shadow effects
    property bool pressed: false // darkens the panel when true
    property bool animate: false // animate panel color changes

    enum PanelType {
        Flat, // the base rectangle with no effects
        Base, // the base panel with some effects
        Stacked, // for being stacked on top of the base panel
        Drawer, // for uses in drawers, scroll containers, typically when a translucent component is behind them
        Wallpaper, // for uses when the panel is right on top of the user's wallpaper
        Popup // for uses as a popup, like for the volume and notifition popups.
    }

    // whether to use a shadow effect
    readonly property bool shadow:          panelType === PanelBackground.PanelType.Base ||
                                            panelType === PanelBackground.PanelType.Stacked ||
                                            panelType === PanelBackground.PanelType.Drawer ||
                                            panelType === PanelBackground.PanelType.Popup ||
                                            panelType === PanelBackground.PanelType.Wallpaper
    // whether to use the complex shadow effect - note that this uses more performance
    readonly property bool complexShadow:   shadow &&
                                            (panelType === PanelBackground.PanelType.Base ||
                                            panelType === PanelBackground.PanelType.Drawer ||
                                            panelType === PanelBackground.PanelType.Popup ||
                                            panelType === PanelBackground.PanelType.Wallpaper)
    // whether the panel should have a border when using a dark theme
    readonly property bool border:          panelType === PanelBackground.PanelType.Base ||
                                            panelType === PanelBackground.PanelType.Stacked ||
                                            panelType === PanelBackground.PanelType.Popup
    // whether to force the panel to have a border even when using a light theme
    readonly property bool forceBorder:     border &&
                                            (panelType === PanelBackground.PanelType.Stacked)
    // whether the panel is translucent border - note that border cannot be used when translucent
    readonly property bool translucent:     panelType === PanelBackground.PanelType.Popup ||
                                            panelType === PanelBackground.PanelType.Wallpaper
    // adjust color depending on panel type
    property color panelColor: {
        let tintPercent
        if (panelType === PanelBackground.PanelType.Popup) {
            tintPercent = 0.035
        } else if (panelType === PanelBackground.PanelType.Base || panelType === PanelBackground.PanelType.Stacked || panelType === PanelBackground.PanelType.Flat) {
            tintPercent = 0
        } else {
            tintPercent = 0.06
        }

        return Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, "white", tintPercent)
    }
    // in some circumstances, panels can change there type
    // for example, popup notifition when opening the popup notifition drawer
    // in these incidents, we animate the color to prevent harsh transitions
    Behavior on panelColor {
        ColorAnimation {
            duration: animate ? Kirigami.Units.veryLongDuration * 1.5 : 0
            easing.type: Easing.OutExpo
        }
    }

    // corner radius of the panel
    property int radius: Kirigami.Units.cornerRadius

    Kirigami.Theme.colorSet: panelType === PanelBackground.PanelType.Popup ? Kirigami.Theme.Window : Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    // very simple shadow for performance
    Rectangle {
        id: simpleShadow
        anchors.top: root.top
        anchors.topMargin: 1
        anchors.left: root.left
        anchors.right: root.right
        height: root.height

        visible: root.shadow && root.flatten < 1
        radius: root.radius

        color: Qt.rgba(0, 0, 0, (root.complexShadow ? 0.025 : 0.15) * (1 - root.flatten))
        opacity: root.complexShadow ? 0 : 1
    }

    // simple-ish expanded shadow for performance
    MultiEffect {
        anchors.fill: background
        source: background
        visible: root.complexShadow && root.flatten < 1
        blurMax: 16

        shadowEnabled: root.complexShadow
        shadowVerticalOffset: 1
        shadowOpacity: (panelType === PanelBackground.PanelType.Base ? 0.5 : 0.2) * (1 - root.flatten)
        shadowColor: "black"
    }

    Rectangle {
        id: background
        anchors.fill: root

        color: Qt.darker(Qt.rgba(root.panelColor.r, root.panelColor.g, root.panelColor.b, root.translucent ? 0.9 : 1), root.pressed ? 3.5 : 1)
        radius: root.radius

        // Only show border when using a dark background and when the border property is set to true
        readonly property color borderColor: Qt.darker(Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.textColor, root.panelColor, 0.9), root.pressed ? 3.5 : 1)
        border.color: Qt.rgba(borderColor.r, borderColor.g, borderColor.b, 1 - root.flatten)
        border.width: root.border && root.flatten < 1 && ((Kirigami.ColorUtils.brightnessForColor(color)) === Kirigami.ColorUtils.Dark || root.forceBorder) ? 1 : 0
        border.pixelAligned: false
    }
}
