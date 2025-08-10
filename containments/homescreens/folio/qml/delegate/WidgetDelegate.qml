// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg 1.0 as KSvg

import org.kde.plasma.components 3.0 as PC3
import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio

import '../private'

Folio.WidgetContainer {
    id: root
    property Folio.HomeScreen folio

    property Folio.FolioWidget widget

    readonly property real widgetWidth: widgetHolder.width
    readonly property real widgetHeight: widgetHolder.height

    readonly property real topWidgetBackgroundPadding: widgetBackground.margins.top
    readonly property real bottomWidgetBackgroundPadding: widgetBackground.margins.bottom
    readonly property real leftWidgetBackgroundPadding: widgetBackground.margins.left
    readonly property real rightWidgetBackgroundPadding: widgetBackground.margins.right

    implicitWidth: (widget ? widget.gridWidth : 0) * folio.HomeScreenState.pageCellWidth
    implicitHeight: (widget ? widget.gridHeight : 0) * folio.HomeScreenState.pageCellHeight
    width: implicitWidth
    height: implicitHeight

    // prevent widget contents from going outside the container
    clip: true

    function updateVisualApplet() {
        if (!widget || !widget.visualApplet) {
            return;
        }

        widget.visualApplet.parent = widgetHolder;
        widget.visualApplet.anchors.fill = widgetHolder;

        // seems to be unnecessary, causes issues where the fullRepresentationItem shows up over :
        // if (widget.visualApplet.fullRepresentationItem) {
            // widget.visualApplet.fullRepresentationItem.parent = widgetHolder;
            // widget.visualApplet.fullRepresentationItem.anchors.fill = widgetHolder;
        // }
    }

    onWidgetChanged: updateVisualApplet()

    Component.onCompleted: {
        updateVisualApplet();
    }

    Connections {
        target: widget

        function onVisualAppletChanged() {
            if (!widget.visualApplet) {
                return;
            }

            root.updateVisualApplet();
        }
    }

    Item {
        id: widgetComponent
        anchors.fill: parent

        KSvg.FrameSvgItem {
            id: widgetBackground
            anchors.fill: parent
            enabledBorders: KSvg.FrameSvgItem.AllBorders
            imagePath: {
                if (!root.widget || !root.widget.applet || root.widget.applet.effectiveBackgroundHints === PlasmaCore.Types.NoBackground) {
                    return '';
                } else if (root.widget.applet.effectiveBackgroundHints & PlasmaCore.Types.StandardBackground) {
                    return 'widgets/background';
                } else if (root.widget.applet.effectiveBackgroundHints & PlasmaCore.Types.TranslucentBackground) {
                    return 'widgets/translucentbackground';
                }
                return '';
            }
        }

        Rectangle {
            id: temporaryBackground
            anchors.fill: parent
            visible: root.widget && !root.widget.applet
            color: Qt.rgba(255, 255, 255, 0.3)
            radius: Kirigami.Units.cornerRadius
        }

        Item {
            id: widgetHolder
            anchors.fill: parent
            anchors.leftMargin: (root.widget && root.widget.applet && root.widget.applet.constraintHints === PlasmaCore.Types.CanFillArea) ? 0 : widgetBackground.margins.left
            anchors.rightMargin: (root.widget && root.widget.applet && root.widget.applet.constraintHints === PlasmaCore.Types.CanFillArea) ? 0 : widgetBackground.margins.right
            anchors.topMargin: (root.widget && root.widget.applet && root.widget.applet.constraintHints === PlasmaCore.Types.CanFillArea) ? 0 : widgetBackground.margins.top
            anchors.bottomMargin: (root.widget && root.widget.applet && root.widget.applet.constraintHints === PlasmaCore.Types.CanFillArea) ? 0 : widgetBackground.margins.bottom
        }

        // TODO implement blur behind, see plasma-workspace BasicAppletContainer for how to do this
        layer.enabled: root.widget && root.widget.applet && root.widget.applet.effectiveBackgroundHints === PlasmaCore.Types.ShadowBackground
        layer.effect: DelegateShadow {}

        PC3.Label {
            id: noWidget
            visible: root.widget && !root.widget.visualApplet
            color: 'white'
            wrapMode: Text.Wrap
            text: i18n("This widget was not found.")
            horizontalAlignment: Text.AlignHCenter

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }

        PC3.BusyIndicator {
            id: loadingIndicator
            anchors.centerIn: parent
            visible: root.widget && root.widget.applet && root.widget.applet.busy
            running: visible
        }

        PC3.Button {
            id: configurationRequiredButton
            anchors.centerIn: parent
            text: i18n("Configure…")
            icon.name: 'configure'
            visible: root.widget && root.widget.applet && root.widget.applet.configurationRequired
            onClicked: root.widget.applet.internalAction('configure').trigger();
        }
    }
}
