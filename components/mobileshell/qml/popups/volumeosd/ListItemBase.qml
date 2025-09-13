/*
 *  SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>
 *  SPDX-FileCopyrightText: 2019 Sefa Eyeoglu <contact@scrumplex.net>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.kquickcontrolsaddons
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.private.volume

import "icon.js" as Icon

// adapted from https://invent.kde.org/plasma/plasma-pa/-/blob/master/applet/contents/ui/ListItemBase.qml
Controls.AbstractButton {
    id: baseItem

    property string label
    property alias listIcon: clientIcon.source
    property string type // sink, source, source-output

    property bool onlyOne: false

    // Whether this item is selected
    readonly property bool supportsSelection: (baseItem.type == "sink" || baseItem.type == "source")
    readonly property bool selected: supportsSelection && (model.PulseObject.hasOwnProperty("default") ? model.PulseObject.default : false)

    onClicked: {
        // Set as the default audio device
        model.PulseObject.default = true
    }

    topPadding: Kirigami.Units.mediumSpacing
    bottomPadding: Kirigami.Units.mediumSpacing
    leftPadding: Kirigami.Units.mediumSpacing
    rightPadding: Kirigami.Units.mediumSpacing

    background: Rectangle {
        radius: Kirigami.Units.cornerRadius
        // border.width: 1
        // border.color: baseItem.selected ? Kirigami.Theme.highlightColor : 'transparent'
        color: (baseItem.selected || baseItem.down)
                    ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.3)
                    : 'transparent'
    }

    contentItem: RowLayout {
        id: row
        spacing: Kirigami.Units.smallSpacing

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

        RowLayout {
            spacing: 0
            Layout.maximumWidth: Infinity // Ignore maximum width of children
            visible: (baseItem.type === "sink" || baseItem.type === "source") && !baseItem.onlyOne

            PlasmaComponents.RadioButton {
                id: defaultButton
                Accessible.ignored: true // read out from delegate
                activeFocusOnTab: false // toggle from delegate
                checked: model.PulseObject?.default ?? false
                onToggled: {
                    if (checked) {
                        baseItem.click();
                    }
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
                    id: viewButton
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: -Kirigami.Units.smallSpacing
                    icon.name: "view-more-symbolic"
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

                // this slider was effectively copied from the source (linked at the top of the file)
                VolumeSlider {
                    id: slider

                    Layout.fillWidth: true
                    from: PulseAudio.MinimalVolume
                    to: model.Volume >= PulseAudio.NormalVolume * 1.01 ? PulseAudio.MaximalVolume : PulseAudio.NormalVolume
                    stepSize: PulseAudio.NormalVolume / 100.0
                    property real myStepSize: PulseAudio.NormalVolume / 100.0
                    visible: model.HasVolume !== false // Devices always have volume but Streams don't necessarily
                    enabled: model.VolumeWritable
                    muted: model.Muted
                    volumeObject: model.PulseObject
                    activeFocusOnTab: false // access from delegate

                    value: to, model.Volume
                    onMoved: {
                        model.Volume = value;
                        model.Muted = value === 0;
                    }
                    onPressedChanged: {
                        if (!pressed) {
                            // Make sure to sync the volume once the button was
                            // released.
                            // Otherwise it might be that the slider is at v10
                            // whereas PA rejected the volume change and is
                            // still at v15 (e.g.).
                            value = Qt.binding(() => model.Volume);
                        }
                    }

                    function updateVolume() {
                        if (model.Volume > PulseAudio.NormalVolume) {
                            model.Volume = PulseAudio.NormalVolume;
                        }
                    }

                    SequentialAnimation {
                        id: seqAnimation
                        NumberAnimation {
                            id: toAnimation
                            target: slider
                            property: "to"
                            duration: Kirigami.Units.shortDuration
                            easing.type: Easing.InOutQuad
                        }
                        ScriptAction {
                            script: slider.updateVolume()
                        }
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
}
