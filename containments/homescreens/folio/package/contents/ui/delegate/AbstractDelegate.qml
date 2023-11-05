// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

import org.kde.kirigami 2.20 as Kirigami

import org.kde.kquickcontrolsaddons 2.0

import org.kde.private.mobile.homescreen.folio 1.0 as Folio
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell as MobileShell

Folio.DelegateTouchArea {
    id: delegate

    property string name
    property bool shadow: false

    property alias contentItem: visualItem.contentItem
    property alias delegateItem: delegateWrapper
    property alias labelOpacity: label.opacity

    signal afterClickAnimation()

    // grow/shrink animation
    property real zoomScale: 1
    property bool clickRequested: false

    NumberAnimation on zoomScale {
        id: shrinkAnim
        running: false
        duration: ShellSettings.Settings.animationsEnabled ? 80 : 1
        to: ShellSettings.Settings.animationsEnabled ? 0.8 : 1
        onFinished: {
            if (!delegate.pressed) {
                growAnim.restart();
            }
        }
    }

    NumberAnimation on zoomScale {
        id: growAnim
        running: false
        duration: ShellSettings.Settings.animationsEnabled ? 80 : 1
        to: 1
        onFinished: {
            if (delegate.clickRequested) {
                delegate.afterClickAnimation();
                delegate.clickRequested = false;
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

    layer.enabled: delegate.shadow
    layer.effect: DelegateShadow {}

    Item {
        id: delegateWrapper
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // transform is not on delegateWrapper because when it's zoomed in, it apparently
            // affects the delegate's x and y position, which messes up the starting drag and drop
            // position (for mapFromItem in HomeScreen.qml)
            transform: Scale {
                origin.x: delegate.width / 2;
                origin.y: delegate.height / 2;
                xScale: delegate.zoomScale
                yScale: delegate.zoomScale
            }

            MobileShell.BaseItem {
                id: visualItem

                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                Layout.minimumWidth: Folio.FolioSettings.delegateIconSize
                Layout.minimumHeight: Folio.FolioSettings.delegateIconSize
                Layout.preferredHeight: Layout.minimumHeight

                // darken effect when hovered
                // TODO: removed for now, since hovered property seems to overlap with the touch pressed event
                // layer {
                //     enabled: delegate.hovered
                //     effect: ColorOverlay {
                //         color: Qt.rgba(0, 0, 0, 0.3)
                //     }
                // }
            }

            DelegateLabel {
                id: label
                opacity: text.length > 0

                Layout.fillWidth: true
                Layout.preferredHeight: Folio.HomeScreenState.pageDelegateLabelHeight
                Layout.topMargin: Folio.HomeScreenState.pageDelegateLabelSpacing
                Layout.leftMargin: -parent.anchors.leftMargin + Kirigami.Units.smallSpacing
                Layout.rightMargin: -parent.anchors.rightMargin + Kirigami.Units.smallSpacing

                text: delegate.name
                color: "white"
            }
        }
    }
}


