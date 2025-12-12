// SPDX-FileCopyrightText: 2023-2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.shell 2.0
import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell as MobileShell

Item {
    id: delegate
    property Folio.HomeScreen folio

    readonly property string pluginName: model.pluginName

    property real zoomScale: (model.isSupported && mouseArea.pressed) ? 0.8 : 1
    transform: Scale {
        origin.x: delegate.width / 2;
        origin.y: delegate.height / 2;
        xScale: delegate.zoomScale
        yScale: delegate.zoomScale
    }

    Behavior on zoomScale { NumberAnimation { duration: 80 } }

    // Placeholder item used for implement drag & drop
    Item {
        id: draggable
        anchors.fill: parent

        Drag.hotSpot.x: iconWidget.width / 2
        Drag.hotSpot.y: iconWidget.height / 2
        Drag.mimeData: { "text/x-plasmoidservicename": pluginName }
        Drag.dragType: Drag.Automatic
        Drag.onDragFinished: {
            root.requestClose();
        }
    }

    MobileShell.HapticsEffect {
        id: haptics
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        cursorShape: model.isSupported ? Qt.PointingHandCursor : Qt.ArrowCursor
        hoverEnabled: true

        onPressAndHold: {
            if (!model.isSupported) {
                return
            }

            haptics.buttonVibrate();
            iconWidget.grabToImage(function(result) {
                // Start drag & drop
                folio.HomeScreenState.closeSettingsView();
                draggable.Drag.imageSource = result.url;
                draggable.Drag.active = true;
                root.requestClose();
            })
        }
    }

    Rectangle {
        id: background
        color: Qt.rgba(255, 255, 255, 0.3)
        visible: model.isSupported && mouseArea.containsMouse
        radius: Kirigami.Units.cornerRadius
        anchors.fill: parent
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing

        Item {
            id: iconWidget
            Layout.fillWidth: true
            Layout.maximumWidth: delegate.width
            Layout.preferredHeight: Kirigami.Units.iconSizes.large
            Layout.preferredWidth: Kirigami.Units.iconSizes.large
            Layout.alignment: Qt.AlignBottom

            Kirigami.Icon {
                anchors.centerIn: parent
                source: model.decoration
                visible: model.screenshot == ""
                implicitWidth: Kirigami.Units.iconSizes.large
                implicitHeight: Kirigami.Units.iconSizes.large
            }
            Image {
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                source: model.screenshot
                width: Kirigami.Units.iconSizes.large
                height: Kirigami.Units.iconSizes.large
            }
        }

        PC3.Label {
            id: heading
            Layout.fillWidth: true
            Layout.maximumWidth: delegate.width
            Layout.alignment: Qt.AlignCenter
            text: model.name
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            maximumLineCount: 2
            horizontalAlignment: Text.AlignHCenter
            font.weight: Font.Bold
        }

        PC3.Label {
            Layout.fillWidth: true
            Layout.maximumWidth: delegate.width
            Layout.alignment: Qt.AlignTop
            // otherwise causes binding loop due to the way the Plasma sets the height
            height: implicitHeight
            text: model.isSupported ? model.description : model.unsupportedMessage
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            maximumLineCount: heading.lineCount === 1 ? 3 : 2
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
