/*
 *  SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as Controls

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons as KQCAddons
import org.kde.plasma.private.mobileshell as MobileShell

import org.kde.plasma.private.volume

// capture presses on the audio applet so it doesn't close the overlay
ColumnLayout {
    id: audioApplet
    spacing: 0

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    property real scale: 1.0

    // Input devices
    readonly property SourceModel paSourceModel: SourceModel { id: paSourceModel }

    // Output devices
    readonly property SinkModel paSinkModel: SinkModel { id: paSinkModel }

    // Confusingly, Sink Input is what PulseAudio calls streams that send audio to an output device
    readonly property SinkInputModel paSinkInputModel: SinkInputModel { id: paSinkInputModel }

    // Confusingly, Source Output is what PulseAudio calls streams that take audio from an input device
    readonly property SourceOutputModel paSourceOutputModel: SourceOutputModel { id: paSourceOutputModel }

    // Active input devices
    readonly property PulseObjectFilterModel paSourceFilterModel: PulseObjectFilterModel {
        id: paSourceFilterModel
        filterOutInactiveDevices: true
        filterVirtualDevices: true
        sourceModel: paSourceModel
    }

    // Active output devices
    readonly property PulseObjectFilterModel paSinkFilterModel: PulseObjectFilterModel {
        id: paSinkFilterModel
        filterOutInactiveDevices: true
        filterVirtualDevices: true
        sourceModel: paSinkModel
    }

    // non-virtual streams going to output devices
    readonly property PulseObjectFilterModel paSinkInputFilterModel: PulseObjectFilterModel {
        id: paSinkInputFilterModel
        filters: [
            { role: "VirtualStream", value: false },
            { role: "Client", value: (client) => client.name !== "libcanberra" },
        ]
        sourceModel: paSinkInputModel
    }

    // non-virtual streams coming from input devices
    readonly property PulseObjectFilterModel paSourceOutputFilterModel: PulseObjectFilterModel {
        id: paSourceOutputFilterModel
        filters: [ { role: "VirtualStream", value: false } ]
        sourceModel: paSourceOutputModel
    }

    readonly property CardModel paCardModel: CardModel { id: paCardModel }

    // UI elements

    PopupCard {
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: Kirigami.Units.gridUnit
        scaleFactor: audioApplet.scale

        contentItem: ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Heading {
                level: 2
                text: i18n("Output Devices")
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            Repeater {
                id: sinkView
                Layout.fillWidth: true

                model: paSinkFilterModel
                delegate: DeviceListItem {
                    Layout.fillWidth: true
                    type: "sink"
                    onlyOne: sinkView.count === 1
                }
            }
        }
    }

    PopupCard {
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: Kirigami.Units.gridUnit
        scaleFactor: audioApplet.scale

        contentItem: ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Heading {
                level: 2
                text: i18n("Input Devices")
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            Repeater {
                id: sourceView
                Layout.fillWidth: true

                model: paSourceFilterModel
                delegate: DeviceListItem {
                    Layout.fillWidth: true
                    type: "source"
                    onlyOne: sourceView.count === 1
                }
            }
        }
    }

    PopupCard {
        visible: (sourceMediaInputView.count + sourceInputView.count) > 0
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: Kirigami.Units.gridUnit
        scaleFactor: audioApplet.scale

        contentItem: ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Heading {
                level: 2
                text: i18n("Playback Streams")
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            // "Grouped" media sources (ex. Notifications)
            Repeater {
                id: sourceMediaInputView
                Layout.fillWidth: true

                model: PulseObjectFilterModel {
                    filters: [ { role: "Name", value: "sink-input-by-media-role:event" } ]
                    sourceModel: StreamRestoreModel {}
                }
                delegate: StreamListItem {
                    Layout.fillWidth: true
                    Layout.margins: Kirigami.Units.smallSpacing
                    width: sourceOutputView.width
                    type: "sink-input"
                    devicesModel: paSinkFilterModel
                }
            }

            // Regular playback streams
            Repeater {
                id: sourceInputView
                Layout.fillWidth: true

                model: paSinkInputFilterModel

                delegate: StreamListItem {
                    Layout.fillWidth: true
                    width: sourceOutputView.width
                    type: "sink-input"
                    devicesModel: paSinkFilterModel
                }
            }
        }
    }

    PopupCard {
        visible: sourceOutputView.model.count !== 0
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: Kirigami.Units.gridUnit
        scaleFactor: audioApplet.scale

        contentItem: ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Heading {
                level: 2
                text: i18n("Recording Streams")
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            Repeater {
                id: sourceOutputView
                Layout.fillWidth: true

                model: paSourceOutputFilterModel

                delegate: StreamListItem {
                    Layout.fillWidth: true
                    width: sourceOutputView.width
                    type: "source-output"
                    devicesModel: paSourceFilterModel
                }
            }
        }
    }
}
