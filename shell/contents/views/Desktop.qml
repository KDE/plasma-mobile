/*
 *   SPDX-FileCopyrightText: 2014 Aaron Seigo <aseigo@kde.org>
 *   SPDX-FileCopyrightText: 2012 Marco Martin <notmart@gmail.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.shell 2.0 as Shell

import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.20 as Kirigami

Rectangle {
    id: root

    property Item containment

    color: (containment && containment.backgroundHints == PlasmaCore.Types.NoBackground) ? "transparent" : PlasmaCore.Theme.textColor

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

            readonly property color backgroundColor: PlasmaCore.Theme.backgroundColor
            readonly property color textColor: PlasmaCore.Theme.textColor

            Kirigami.Theme.inherit: false
            Kirigami.Theme.backgroundColor: backgroundColor
            Kirigami.Theme.textColor: textColor

            onBackgroundColorChanged: Qt.callLater(update)
            onTextColorChanged: Qt.callLater(update)

            property Binding colorBinding: Binding {
                target: desktop
                property: "accentColor"
                value: {
                    if (imageColors.palette.length === 0) {
                        return "#00000000";
                    }
                    return imageColors.dominant;
                }
            }

            property Connections repaintConnection: Connections {
                target: root.containment.wallpaper
                function onRepaintNeeded() {
                    imageColors.update();
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
