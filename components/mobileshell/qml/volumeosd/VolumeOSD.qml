/*
 *  SPDX-FileCopyrightText: 2014 Martin Klapetek <mklapetek@kde.org>
 *  SPDX-FileCopyrightText: 2019 Kai Uwe Broulik <kde@broulik.de>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Window

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.core as PlasmaCore

PlasmaCore.Dialog {
    id: root
    width: Kirigami.Units.gridUnit * 20

    location: PlasmaCore.Types.OnScreenDisplay
    // type: PlasmaCore.Dialog.AppletPopup
    hideOnWindowDeactivate: true
    backgroundHints: PlasmaCore.Types.NoBackground
    outputOnly: false
    // outputOnly: true

    // used by context menus opened in the applet to not autoclose the osd
    property bool suppressActiveClose: false

    // whether the applet is showing all devices
    property bool showFullApplet: false

    visible: false

    color: showFullApplet ? Qt.rgba(0, 0, 0, 0.6) : "transparent"
    Behavior on color {
        ColorAnimation {}
    }
    
    function showOverlay() {
        if (!root.visible) {
            root.showFullApplet = false;
            root.show();
            hideTimer.restart();
        } else if (!root.showFullApplet) { // don't autohide applet when the full applet is showing
            hideTimer.restart();
        }
    }

    // onActiveChanged: {
    //     if (!active && !suppressActiveClose) {
    //         hideTimer.stop();
    //         hideTimer.triggered();
    //     }
    // }
    
    MainVolumeCard {
        id: osd
        showFullApplet: root.showFullApplet
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        Timer {
            id: hideTimer
            interval: 3000
            running: false
            onTriggered: {
                root.close();
                window.showFullApplet = false;
            }
        }
    }

    // Flickable {
    //     id: flickable
    //     anchors.fill: parent
    //     contentHeight: cards.implicitHeight
    //     boundsBehavior: root.showFullApplet ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds

    //     pressDelay: 50

    //     MouseArea {
    //         // capture taps behind cards to close
    //         anchors.left: parent.left
    //         anchors.right: parent.right
    //         width: parent.width
    //         height: Math.max(cards.implicitHeight, root.height)
    //         onReleased: {
    //             hideTimer.stop();
    //             hideTimer.triggered();
    //         }

    //         ColumnLayout {
    //             id: cards
    //             width: parent.width
    //             anchors.left: parent.left
    //             anchors.right: parent.right
    //             spacing: 0

    //             // osd card
    //             MainVolumeCard {
    //                 id: osd
    //                 showFullApplet: root.showFullApplet
    //                 Layout.topMargin: Kirigami.Units.gridUnit
    //                 Layout.alignment: Qt.AlignHCenter
    //             }

    //             // other applet cards
    //             AudioApplet {
    //                 id: applet
    //                 Layout.topMargin: Kirigami.Units.gridUnit
    //                 Layout.alignment: Qt.AlignHCenter
    //                 Layout.preferredWidth: cards.width
    //                 opacity: root.showFullApplet ? 1 : 0
    //                 visible: opacity !== 0
    //                 transform: Translate {
    //                     y: root.showFullApplet ? 0 : -Kirigami.Units.gridUnit
    //                     Behavior on y { NumberAnimation {} }
    //                 }

    //                 Behavior on opacity { NumberAnimation {} }
    //             }
    //         }
    //     }
    // }
}
