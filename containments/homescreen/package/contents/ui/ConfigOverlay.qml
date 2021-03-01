/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager

ContainmentLayoutManager.ConfigOverlayWithHandles {
    id: overlay

    readonly property int iconSize: units.iconSizes.medium
    PlasmaCore.Svg {
        id: configIconsSvg
        imagePath: "widgets/configuration-icons"
    }

    PlasmaComponents.Label {
        id: toolTipDelegate

        width: contentWidth
        height: undefined

        property Item toolTip

        text: (toolTip != null) ? toolTip.mainText : ""
    }

    SequentialAnimation {
        id: removeAnim
        NumberAnimation {
            target: overlay.itemContainer
            property: "scale"
            from: 1
            to: 0
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
        ScriptAction {
            script: {
                appletContainer.applet.action("remove").trigger();
                appletContainer.editMode = false;
            }
        }
    }
    PlasmaCore.FrameSvgItem {
        id: frame
        anchors.centerIn: parent

        width: layout.implicitWidth + margins.left + margins.right
        height: layout.implicitHeight + margins.top + margins.bottom
        imagePath: "widgets/background"

        RowLayout {
            id: layout
            spacing: units.largeSpacing
            anchors {
                fill: parent
                topMargin: parent.margins.top
                leftMargin: parent.margins.left
                bottomMargin: parent.margins.bottom
                rightMargin: parent.margins.right
            }

            ActionButton {
                svg: configIconsSvg
                elementId: "configure"
                iconSize: overlay.iconSize
                visible: (action && typeof(action) != "undefined") ? action.enabled : false
                action: (applet) ? applet.action("configure") : null
                Component.onCompleted: {
                    if (action && typeof(action) != "undefined") {
                        action.enabled = true
                    }
                }
            }

            ActionButton {
                id: closeButton
                svg: configIconsSvg
                elementId: "delete"
                mainText: i18n("Remove")
                iconSize: overlay.iconSize
                visible: {
                    if (!applet) {
                        return false;
                    }
                    var a = applet.action("remove");
                    return (a && typeof(a) != "undefined") ? a.enabled : false;
                }
                // we don't set action, since we want to catch the button click,
                // animate, and then trigger the "remove" action
                // Triggering the action is handled in the overlay.itemContainer, we just
                // emit a signal here to avoid the applet-gets-removed-before-we-
                // can-animate it race condition.
                onClicked: {
                    removeAnim.restart();
                }
                Component.onCompleted: {
                    var a = applet.action("remove");
                    if (a && typeof(a) != "undefined") {
                        a.enabled = true
                    }
                }
            }
        }
    }
}

