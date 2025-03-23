/*
 *  SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>
 *  SPDX-FileCopyrightText: 2019 Sefa Eyeoglu <contact@scrumplex.net>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksvg 1.0 as KSvg
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.volume 0.1

import "icon.js" as Icon

// adapted from https://invent.kde.org/plasma/plasma-pa/-/blob/master/applet/contents/ui/ListItemBase.qml
Controls.Control {
    id: baseItem

    property string label
    property alias listIcon: clientIcon.source
    property string type // sink, source, source-output

    MouseArea {
        id: clickArea
        anchors.fill: parent
        z: -1
        onClicked: {
            if (selectButton.visible) {
                model.PulseObject.default = true;
            }
        }
    }

    contentItem: RowLayout {
        id: row
        spacing: Kirigami.Units.smallSpacing

        PlasmaComponents.RadioButton {
            id: selectButton
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: Math.round(row.height / 2 - implicitHeight - Kirigami.Units.smallSpacing / 2) // align with text
            checked: model.PulseObject.hasOwnProperty("default") ? model.PulseObject.default : false
            visible: (baseItem.type == "sink" && sinkView.model.count > 1) || (baseItem.type == "source" && sourceView.model.count > 1)
            onClicked: model.PulseObject.default = true
        }

        // application icon
        Kirigami.Icon {
            id: clientIcon
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: Kirigami.Units.smallSpacing
            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
            Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
            visible: type === "sink-input" || type === "source-output"
            source: "unknown"
            onSourceChanged: {
                if (!valid && source != "unknown") {
                    source = "unknown";
                }
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                Layout.alignment: Qt.AlignBottom

                PlasmaComponents.Label {
                    id: mainLabel
                    text: baseItem.label
                    Layout.alignment: Qt.AlignBottom
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                PlasmaComponents.ToolButton {
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: -Kirigami.Units.smallSpacing
                    icon.name: "application-menu"
                    checkable: true
                    checked: contextMenu.visible && contextMenu.visualParent === this
                    visible: contextMenu.hasContent
                    onClicked: {
                        contextMenu.visualParent = this;
                        contextMenu.openRelative();
                    }
                    PlasmaComponents.ToolTip {
                        text: i18n("Show additional options for %1", baseItem.label)
                    }

                    ListItemMenu {
                        id: contextMenu
                        pulseObject: model.PulseObject
                        cardModel: paCardModel
                        itemType: {
                            switch (baseItem.type) {
                            case "sink":
                                return ListItemMenu.Sink;
                            case "sink-input":
                                return ListItemMenu.SinkInput;
                            case "source":
                                return ListItemMenu.Source;
                            case "source-output":
                                return ListItemMenu.SourceOutput;
                            }
                        }
                        sourceModel: {
                            if (baseItem.type.includes("sink")) {
                                return sinkView.model;
                            } else if (baseItem.type.includes("source")) {
                                return sourceView.model;
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents.ToolButton {
                    icon.name: Icon.name(Volume / PulseAudio.NormalVolume * 100.0, Muted)
                    text: Muted ? i18n("Unmute") : i18n("Mute")
                    display: Controls.AbstractButton.IconOnly
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                    onClicked: {
                        Muted = !Muted
                    }
                }

                // this slider was effectively copied from the source (linked at the top of the file)
                PlasmaComponents.Slider {
                    id: slider
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop

                    // Helper properties to allow async slider updates.
                    // While we are sliding we must not react to value updates
                    // as otherwise we can easily end up in a loop where value
                    // changes trigger volume changes trigger value changes.
                    property int volume: Volume
                    property bool ignoreValueChange: true
                    readonly property bool forceRaiseMaxVolume: volume >= PulseAudio.NormalVolume * 1.01

                    from: PulseAudio.MinimalVolume
                    to: PulseAudio.NormalVolume
                    stepSize: to / (to / PulseAudio.NormalVolume * 100.0)
                    visible: HasVolume
                    enabled: VolumeWritable
                    opacity: Muted ? 0.5 : 1

                    Accessible.name: i18nc("Accessibility data on volume slider", "Adjust volume for %1", baseItem.label)

                    background: KSvg.FrameSvgItem {
                        imagePath: "widgets/slider"
                        prefix: "groove"
                        width: parent.availableWidth
                        height: margins.top + margins.bottom
                        anchors.centerIn: parent
                        scale: parent.mirrored ? -1 : 1

                        KSvg.FrameSvgItem {
                            imagePath: "widgets/slider"
                            prefix: "groove-highlight"
                            anchors.left: parent.left
                            y: (parent.height - height) / 2
                            width: Math.max(margins.left + margins.right, slider.handle.x * meter.volume)
                            height: Math.max(margins.top + margins.bottom, parent.height)
                            opacity: meter.available && (meter.volume > 0 || animation.running)
                            VolumeMonitor {
                                id: meter
                                target: parent.visible ? model.PulseObject : null
                            }
                            Behavior on width {
                                NumberAnimation  {
                                    id: animation
                                    duration: Kirigami.Units.shortDuration
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                    }

                    Component.onCompleted: {
                        ignoreValueChange = false;
                    }

                    onVolumeChanged: {
                        var oldIgnoreValueChange = ignoreValueChange;
                        ignoreValueChange = true;
                        value = Volume;
                        ignoreValueChange = oldIgnoreValueChange;
                    }

                    onValueChanged: {
                        if (!ignoreValueChange) {
                            Volume = value;
                            Muted = value == 0;

                            if (!pressed) {
                                updateTimer.restart();
                            }
                        }
                    }

                    onPressedChanged: {
                        if (!pressed) {
                            // Make sure to sync the volume once the button was
                            // released.
                            // Otherwise it might be that the slider is at v10
                            // whereas PA rejected the volume change and is
                            // still at v15 (e.g.).
                            updateTimer.restart();
                        }
                    }

                    Timer {
                        id: updateTimer
                        interval: 200
                        onTriggered: slider.value = Volume
                    }
                }
                PlasmaComponents.Label {
                    id: percentText
                    readonly property real value: model.PulseObject.volume > slider.to ? model.PulseObject.volume : slider.value
                    readonly property real displayValue: Math.round(value / PulseAudio.NormalVolume * 100.0)
                    Layout.alignment: Qt.AlignHCenter
                    Layout.minimumWidth: percentMetrics.advanceWidth
                    horizontalAlignment: Qt.AlignRight
                    text: i18nc("volume percentage", "%1%", displayValue)
                    color: {
                        if (displayValue <= 100) {
                            return Kirigami.Theme.textColor
                        } else if (displayValue > 100 && displayValue <= 125) {
                            return Kirigami.Theme.neutralTextColor
                        } else {
                            return Kirigami.Theme.negativeTextColor
                        }
                    }
                }

                TextMetrics {
                    id: percentMetrics
                    font: percentText.font
                    text: i18nc("only used for sizing, should be widest possible string", "100%")
                }
            }
        }
    }

    function setVolumeByPercent(targetPercent) {
        model.PulseObject.volume = Math.round(PulseAudio.NormalVolume * (targetPercent/100));
    }
}
