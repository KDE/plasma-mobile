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
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState

import org.kde.plasma.private.volume

import org.kde.layershell 1.0 as LayerShell


Window {
    id: window

    width: Screen.width
    height: Screen.height

    visible: false

    LayerShell.Window.scope: "overlay"
    LayerShell.Window.anchors: LayerShell.Window.AnchorTop
    LayerShell.Window.layer: LayerShell.Window.LayerOverlay
    LayerShell.Window.exclusionZone: -1

    readonly property color backgroundColor: Qt.darker(Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.95), 1.05)

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    color: backgroundColor

    function showOverlay() {
        if (!window.visible) {
            window.open();
        }
    }

    function open() {
        window.visible = true;
        flickable.state = "open";
        // set window input transparency to accept touches
        ShellUtil.setInputTransparent(window, false);
    }

    function close() {
        flickable.state = "closed";
        // set window input transparency to allow touches to pass through while the closing animation is playing
        ShellUtil.setInputTransparent(window, true);
    }

    Component.onCompleted: {
        window.close();
        visible = false;
    }

    Binding {
        target: MobileShellState.ShellDBusClient
        property: "isVolumeOSDOpen"
        value: window.visible
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: cards.implicitHeight
        boundsBehavior: Flickable.DragAndOvershootBounds

        pressDelay: 50

        property real offset: -Kirigami.Units.gridUnit
        property real scale: 0.95

        state: "closed"

        states: [
            State {
                name: "open"
                PropertyChanges {
                    target: flickable; offset: 0
                }
                PropertyChanges {
                    target: flickable; scale: 1.0
                }
                PropertyChanges {
                    target: flickable; opacity: 1.0
                }
                PropertyChanges {
                    target: window; color: backgroundColor
                }
            },
            State {
                name: "closed"
                PropertyChanges {
                    target: flickable; offset: -Kirigami.Units.gridUnit * 3
                }
                PropertyChanges {
                    target: flickable; scale: 0.95
                }
                PropertyChanges {
                    target: flickable; opacity: 0.0
                }
                PropertyChanges {
                    target: window; color: "transparent"
                }
            }
        ]

        transitions: Transition {
            SequentialAnimation {
                ParallelAnimation {
                    PropertyAnimation {
                        properties: "offset"; easing.type: Easing.OutQuint; duration: Kirigami.Units.veryLongDuration * 1.25
                    }
                    PropertyAnimation {
                        properties: "scale"; easing.type: Easing.OutQuint; duration: Kirigami.Units.veryLongDuration * 1.25
                    }
                    PropertyAnimation {
                        properties: "opacity"; easing.type: Easing.OutQuint; duration: Kirigami.Units.veryLongDuration * 1.25
                    }
                    PropertyAnimation {
                        properties: "color"; easing.type: Easing.OutQuint; duration: Kirigami.Units.veryLongDuration * 1.25
                    }
                }
                ScriptAction {
                    script: {
                        if (flickable.state == "closed") {
                            window.visible = false;
                        }
                    }
                }
            }
        }

        MouseArea {
            // capture taps behind cards to close
            anchors.left: parent.left
            anchors.right: parent.right
            width: parent.width
            height: Math.max(cards.implicitHeight, window.height)
            onReleased: {
                window.close();
            }

            ColumnLayout {
                id: cards
                width: parent.width
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                transform: Translate {
                    y: flickable.offset
                }

                AudioApplet {
                    id: applet
                    Layout.topMargin: Kirigami.Units.gridUnit + Kirigami.Units.smallSpacing * 3
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: cards.width
                    scale: flickable.scale
                }

                PopupCard {
                    id: settings
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: Kirigami.Units.gridUnit

                    transform: Scale {
                        origin.x: Math.round(implicitWidth / 2)
                        origin.y: Math.round(height / 2)
                        xScale: flickable.scale
                        yScale: flickable.scale
                    }

                    contentItem: RowLayout {

                        PlasmaComponents.ToolButton {
                            property int addedPadding: Kirigami.Units.smallSpacing * 2
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.preferredWidth: parent.width - addedPadding * 2
                            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                            Layout.margins: addedPadding

                            contentItem: Item {
                                anchors.fill: parent
                                RowLayout {
                                    spacing: Kirigami.Units.largeSpacing
                                    anchors.centerIn: parent
                                    Kirigami.Icon {
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                                        Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                                        source:  "settings-configure"
                                    }
                                    PlasmaComponents.Label {
                                        text: i18n("Open audio settings")
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            onClicked: {
                                MobileShell.ShellUtil.executeCommand("plasma-open-settings kcm_pulseaudio");
                                window.close();
                            }
                        }
                    }
                }
            }
        }
    }
}
