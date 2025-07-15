/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls as Controls

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons
import org.kde.plasma.plasmoid

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import plasma.applet.org.kde.plasma.mobile.homescreen.halcyon as Halcyon

import org.kde.kirigami as Kirigami

MouseArea {
    id: delegate
    width: GridView.view.cellWidth
    height: GridView.view.cellHeight

    property Halcyon.Application application: model.application

    property int reservedSpaceForLabel
    property alias iconItem: icon

    readonly property real margins: Math.floor(width * 0.2)

    signal launch(int x, int y, var source, string title, string storageId)

    function openContextMenu() {
        dialogLoader.active = true;
        dialogLoader.item.open();
    }

    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onPressAndHold: openContextMenu()

    function launchApp() {
        // launch app
        if (application.running) {
            delegate.launch(0, 0, "", application.name, application.storageId);
        } else {
            delegate.launch(delegate.x + (Kirigami.Units.smallSpacing * 2), delegate.y + (Kirigami.Units.smallSpacing * 2), icon.source, application.name, application.storageId);
        }
    }

    Loader {
        id: dialogLoader
        active: false

        sourceComponent: PlasmaComponents.Menu {
            title: label.text
            closePolicy: PlasmaComponents.Menu.CloseOnReleaseOutside | PlasmaComponents.Menu.CloseOnEscape

            PlasmaComponents.MenuItem {
                icon.name: "emblem-favorite"
                text: i18n("Add to favourites")
                onClicked: {
                    Plasmoid.pinnedModel.addApp(application.storageId, 0);
                }
            }
            onClosed: dialogLoader.active = false
        }
    }

    // grow/shrink animation
    property real zoomScale: 1
    transform: Scale {
        origin.x: delegate.width / 2;
        origin.y: delegate.height / 2;
        xScale: delegate.zoomScale
        yScale: delegate.zoomScale
    }

    property bool launchAppRequested: false

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
            if (delegate.launchAppRequested) {
                delegate.launchApp();
                delegate.launchAppRequested = false;
            }
        }
    }

    onPressedChanged: {
        if (pressed) {
            growAnim.stop();
            shrinkAnim.restart();
        } else if (!pressed && !shrinkAnim.running) {
            growAnim.restart();
        }
    }
    // launch app handled by press animation
    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) {
            openContextMenu();
        } else {
            launchAppRequested = true;
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            leftMargin: margins
            topMargin: margins
            rightMargin: margins
            bottomMargin: margins
        }
        spacing: 0

        Kirigami.Icon {
            id: icon

            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillWidth: true
            Layout.preferredHeight: Math.floor(parent.height - delegate.reservedSpaceForLabel)
            Layout.maximumHeight: labelFontMetrics.height * 7
            Layout.topMargin: Math.max(0, Layout.preferredHeight - height)

            source: application.icon

            Rectangle {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }
                visible: application.running
                radius: width
                width: Kirigami.Units.smallSpacing
                height: width
                color: Kirigami.Theme.highlightColor
            }

            // darken effect when hovered/pressed
            layer {
                enabled: delegate.pressed
                effect: MultiEffect {
                    colorization: 1.0
                    colorizationColor: Qt.rgba(0, 0, 0, 0.3)
                }
            }

            FontMetrics {
                id: labelFontMetrics
                font: label.font
            }
        }

        PlasmaComponents.Label {
            id: label
            visible: text.length > 0

            Layout.fillWidth: true
            Layout.preferredHeight: delegate.reservedSpaceForLabel
            Layout.topMargin: Kirigami.Units.smallSpacing
            Layout.leftMargin: -parent.anchors.leftMargin + Kirigami.Units.smallSpacing
            Layout.rightMargin: -parent.anchors.rightMargin + Kirigami.Units.smallSpacing

            wrapMode: Text.WordWrap
            maximumLineCount: 2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            elide: Text.ElideRight

            text: application.name

            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.85
            font.weight: Font.Bold
            color: "white"
        }
    }
}


