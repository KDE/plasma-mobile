/*
 *  SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Window
import Qt5Compat.GraphicalEffects

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtra
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.kquickcontrolsaddons as KQCAddons

import org.kde.plasma.private.volume

// capture presses on the audio applet so it doesn't close the overlay
ColumnLayout {
    spacing: 0
    
    required property MobileShell.AudioInfo audioInfo
    
    PulseObjectFilterModel {
        id: paSinkFilterModel
        sortRole: "SortByDefault"
        sortOrder: Qt.DescendingOrder
        filterOutInactiveDevices: true
        sourceModel: audioInfo.paSinkModel
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
