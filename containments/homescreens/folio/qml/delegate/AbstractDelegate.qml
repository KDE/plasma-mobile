// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

import org.kde.kirigami 2.20 as Kirigami

import org.kde.kquickcontrolsaddons 2.0

import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell as MobileShell

Folio.DelegateTouchArea {
    id: root
    property Folio.HomeScreen folio
    property MobileShell.MaskManager maskManager

    property string name
    property bool shadow: false

    property alias contentItem: visualItem.contentItem
    property alias delegateItem: delegateWrapper
    property alias labelOpacity: label.opacity

    signal afterClickAnimation()

    // grow/shrink animation
    property real scaleAmount: 1
    property bool clickRequested: false

    function keyboardFocus() {
        delegateWrapper.forceActiveFocus();
    }

    NumberAnimation on scaleAmount {
        id: shrinkAnim
        running: false
        duration: ShellSettings.Settings.animationsEnabled ? 80 : 1
        to: ShellSettings.Settings.animationsEnabled ? 0.8 : 1
        onFinished: {
            if (!root.pressed) {
                growAnim.restart();
            }
        }
    }

    NumberAnimation on scaleAmount {
        id: growAnim
        running: false
        duration: ShellSettings.Settings.animationsEnabled ? 80 : 1
        to: 1
        onFinished: {
            if (root.clickRequested) {
                root.afterClickAnimation();
                root.clickRequested = false;
            }
        }
    }

    cursorShape: Qt.PointingHandCursor
    onPressedChanged: (pressed) => {
        if (pressed) {
            growAnim.stop();
            shrinkAnim.restart();
        } else if (!pressed && !shrinkAnim.running) {
            growAnim.restart();
        }
    }
    // trigger handled by press animation
    onClicked: clickRequested = true;

    FocusScope {
        id: delegateWrapper
        anchors.fill: parent

        // Select keyboard navigation
        Keys.onPressed: (event) => {
            switch (event.key) {
                case Qt.Key_Enter:
                case Qt.Key_Return:
                case Qt.Key_Space:
                    root.afterClickAnimation();
                    event.accepted = true;
                    break;
                default:
                    break;
            }
        }

        KeyboardHighlight {
            anchors.fill: parent
            visible: delegateWrapper.activeFocus
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // transform is not on delegateWrapper because when it's zoomed in, it apparently
            // affects the delegate's x and y position, which messes up the starting drag and drop
            // position (for mapFromItem in HomeScreen.qml)
            transform: Scale {
                origin.x: root.width / 2;
                origin.y: root.height / 2;
                xScale: root.scaleAmount
                yScale: root.scaleAmount
            }

            MobileShell.BaseItem {
                id: visualItem

                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                Layout.minimumWidth: folio.FolioSettings.delegateIconSize
                Layout.minimumHeight: folio.FolioSettings.delegateIconSize
                Layout.preferredHeight: Layout.minimumHeight

                // darken effect when hovered
                // TODO: removed for now, since hovered property seems to overlap with the touch pressed event
                // layer {
                //     enabled: root.hovered
                //     effect: ColorOverlay {
                //         color: Qt.rgba(0, 0, 0, 0.3)
                //     }
                // }
            }

            DelegateLabel {
                id: label
                opacity: text.length > 0

                Layout.fillWidth: true
                Layout.preferredHeight: folio.HomeScreenState.pageDelegateLabelHeight
                Layout.topMargin: folio.HomeScreenState.pageDelegateLabelSpacing
                Layout.leftMargin: -parent.anchors.leftMargin + Kirigami.Units.smallSpacing
                Layout.rightMargin: -parent.anchors.rightMargin + Kirigami.Units.smallSpacing

                text: root.name
                color: "white"
            }
        }
    }
}


