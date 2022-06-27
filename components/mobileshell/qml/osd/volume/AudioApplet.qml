/*
 *  SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtGraphicalEffects 1.12

import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtra
import org.kde.kquickcontrolsaddons 2.0 as KQCAddons

import org.kde.plasma.private.volume 0.1

// adapted version of https://invent.kde.org/plasma/plasma-pa/-/blob/master/applet/contents/ui/main.qml

// most audio functions are in VolumeProvider.qml (which will be a parent)
// capture presses on the audio applet so it doesn't close the overlay
ColumnLayout {
    spacing: 0
    
    // pulseaudio models
    
    function isDummyOutput(output) {
        return output && output.name === dummyOutputName;
    }
    
    SinkModel {
        id: paSinkModel
    }
    
    PulseObjectFilterModel {
        id: paSinkFilterModel
        sortRole: "SortByDefault"
        sortOrder: Qt.DescendingOrder
        filterOutInactiveDevices: true
        sourceModel: paSinkModel
    }

    SourceModel {
        id: paSourceModel
    }

    PulseObjectFilterModel {
        id: paSourceFilterModel
        sortRole: "SortByDefault"
        sortOrder: Qt.DescendingOrder
        filterOutInactiveDevices: true
        sourceModel: paSourceModel
    }

    CardModel {
        id: paCardModel
    }

    // ui elements
    
    PopupCard {
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: PlasmaCore.Units.largeSpacing
        contentItem: ColumnLayout {
            anchors.rightMargin: PlasmaCore.Units.smallSpacing
            anchors.leftMargin: PlasmaCore.Units.smallSpacing
            
            PlasmaExtra.Heading {
                level: 2
                text: i18n("Outputs")
                Layout.fillWidth: true
                Layout.topMargin: PlasmaCore.Units.smallSpacing
                Layout.leftMargin: PlasmaCore.Units.smallSpacing
            }
            
            Repeater {
                id: sinkView
                Layout.fillWidth: true
                
                model: paSinkFilterModel
                delegate: DeviceListItem {
                    Layout.fillWidth: true
                    Layout.margins: PlasmaCore.Units.smallSpacing
                    type: "sink"
                    onlyone: sinkView.count === 1
                }
            }
        }
    }
    
    PopupCard {
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: PlasmaCore.Units.largeSpacing
        contentItem: ColumnLayout {
            anchors.rightMargin: PlasmaCore.Units.smallSpacing
            anchors.leftMargin: PlasmaCore.Units.smallSpacing
            
            PlasmaExtra.Heading {
                level: 2
                text: i18n("Inputs")
                Layout.fillWidth: true
                Layout.topMargin: PlasmaCore.Units.smallSpacing
                Layout.leftMargin: PlasmaCore.Units.smallSpacing
            }
            
            Repeater {
                id: sourceView
                Layout.fillWidth: true
                
                model: paSourceFilterModel
                delegate: DeviceListItem {
                    Layout.fillWidth: true
                    Layout.margins: PlasmaCore.Units.smallSpacing
                    type: "source"
                    onlyone: sinkView.count === 1
                }
            }
        }
    }
    
    PopupCard {
        visible: sourceInputView.model.count + sourceMediaInputView.model.count !== 0
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: PlasmaCore.Units.largeSpacing
        contentItem: ColumnLayout {
            anchors.rightMargin: PlasmaCore.Units.smallSpacing
            anchors.leftMargin: PlasmaCore.Units.smallSpacing
            
            PlasmaExtra.Heading {
                level: 2
                text: i18n("Playback Streams")
                Layout.fillWidth: true
                Layout.topMargin: PlasmaCore.Units.smallSpacing
                Layout.leftMargin: PlasmaCore.Units.smallSpacing
            }
            
            Repeater {
                id: sourceMediaInputView
                Layout.fillWidth: true
                
                model: PulseObjectFilterModel {
                    filters: [ { role: "Name", value: "sink-input-by-media-role:event" } ]
                    sourceModel: StreamRestoreModel {}
                }
                delegate: StreamListItem {
                    Layout.fillWidth: true
                    Layout.margins: PlasmaCore.Units.smallSpacing
                    width: sourceOutputView.width
                    type: "sink-input"
                    devicesModel: sourceView.model
                }
            }
            
            Repeater {
                id: sourceInputView
                Layout.fillWidth: true
                
                model: PulseObjectFilterModel {
                    filters: [ { role: "VirtualStream", value: false } ]
                    sourceModel: SinkInputModel {}
                }

                delegate: StreamListItem {
                    Layout.fillWidth: true
                    Layout.margins: PlasmaCore.Units.smallSpacing
                    width: sourceOutputView.width
                    type: "sink-input"
                    devicesModel: sourceView.model
                }
            }
        }
    }
    
    PopupCard {
        visible: sourceOutputView.model.count !== 0
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: PlasmaCore.Units.largeSpacing
        contentItem: ColumnLayout {
            anchors.rightMargin: PlasmaCore.Units.smallSpacing
            anchors.leftMargin: PlasmaCore.Units.smallSpacing
            
            PlasmaExtra.Heading {
                level: 2
                text: i18n("Recording Streams")
                Layout.fillWidth: true
                Layout.topMargin: PlasmaCore.Units.smallSpacing
                Layout.leftMargin: PlasmaCore.Units.smallSpacing
            }
            
            Repeater {
                id: sourceOutputView
                Layout.fillWidth: true
                
                model: PulseObjectFilterModel {
                    filters: [ { role: "VirtualStream", value: false } ]
                    sourceModel: SourceOutputModel {}
                }
                delegate: StreamListItem {
                    Layout.fillWidth: true
                    Layout.margins: PlasmaCore.Units.smallSpacing
                    width: sourceOutputView.width
                    type: "source-output"
                    devicesModel: sourceView.model
                }
            }
        }
    }
}
