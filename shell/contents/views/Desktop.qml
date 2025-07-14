/*
 *   SPDX-FileCopyrightText: 2014 Aaron Seigo <aseigo@kde.org>
 *   SPDX-FileCopyrightText: 2012 Marco Martin <notmart@gmail.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15

import org.kde.plasma.core as PlasmaCore

import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState

Rectangle {
    id: root

    property Item containment

    color: (containment && containment.backgroundHints == PlasmaCore.Types.NoBackground) ? "transparent" : Kirigami.Theme.textColor

    Component.onCompleted: {
        initializeShellSingletons();
    }

    function initializeShellSingletons() {
        console.log('Initializing DBus objects and popup providers...');
        // Note: The calls here must be idempotent (support being called multiple times)
        //       - this is called every time there is a new desktop containment

        // HACK: we need to initialize the DBus server somewhere in plasmashell, it might as well be here...
        MobileShellState.ShellDBusObject.registerObject();

        // Initialize the volume osd, and volume keys.
        // Initialize notification popups.
        // Initialize action popup buttons.
        MobileShell.PopupProviderLoader.load();
    }

    function toggleWidgetExplorer(containment) {
        console.log("Widget Explorer toggled");
        if (widgetExplorerStack.source != "") {
            widgetExplorerStack.source = "";
        } else {
            widgetExplorerStack.setSource(desktop.fileFromPackage("explorer", "WidgetExplorer.qml"), {"containment": containment, "containmentInterface": root.containment})
        }
    }

    onContainmentChanged: {
        if (containment == null) {
            return;
        }

        containment.parent = root;
        containment.visible = true;
        containment.anchors.fill = root;
    }

    // This is taken from plasma-desktop's shell package, try to keep it in sync
    // Handles taking accent color from wallpaper
    Loader {
        id: wallpaperColors

        active: desktop.usedInAccentColor && root.containment && root.containment.wallpaper
        asynchronous: true

        sourceComponent: Kirigami.ImageColors {
            id: imageColors
            source: root.containment.wallpaper

            readonly property color backgroundColor: Kirigami.Theme.backgroundColor
            readonly property color textColor: Kirigami.Theme.textColor
            property color colorFromPlugin: "transparent"

            Kirigami.Theme.inherit: false
            Kirigami.Theme.backgroundColor: backgroundColor
            Kirigami.Theme.textColor: textColor

            onBackgroundColorChanged: Qt.callLater(update)
            onTextColorChanged: Qt.callLater(update)

            property Binding colorBinding: Binding {
                target: desktop
                property: "accentColor"
                value: {
                    if (!Qt.colorEqual(imageColors.colorFromPlugin, "transparent")) {
                        return imageColors.colorFromPlugin;
                    }
                    if (imageColors.palette.length === 0) {
                        return "transparent";
                    }
                    return imageColors.dominant;
                }
                when: desktop.usedInAccentColor // Without this, accentColor may still be updated after usedInAccentColor becomes false
            }

            property Connections repaintConnection: Connections {
                target: root.containment.wallpaper
                function onRepaintNeeded(color) {
                    imageColors.colorFromPlugin = color;

                    if (Qt.colorEqual(color, "transparent")) {
                        imageColors.update();
                    }
                }
            }
        }

        onLoaded: item.update()
    }

    Loader {
        id: widgetExplorerStack
        z: 99
        asynchronous: true
        y: containment ? containment.availableScreenRect.y : 0
        height: containment ? containment.availableScreenRect.height : parent.height
        width: parent.width

        onLoaded: {
            if (widgetExplorerStack.item) {
                item.closed.connect(function() {
                    widgetExplorerStack.source = ""
                });

                item.topPanelHeight = containment.availableScreenRect.y
                item.bottomPanelHeight = root.height - (containment.availableScreenRect.height + containment.availableScreenRect.y)

                item.leftPanelWidth = containment.availableScreenRect.x
                item.rightPanelWidth = root.width - (containment.availableScreenRect.width + containment.availableScreenRect.x)
            }
        }
    }
}
