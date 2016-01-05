/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *   Copyright 2011 Viranch Mehta <viranch.mehta@gmail.com>
 *   Copyright 2013-2015 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.workspace.components 2.0

FocusScope {
    id: dialog
    focus: true

    //property alias model: batteryList.model
    property bool pluggedIn

    property int remainingTime

    property bool isBrightnessAvailable: false // FIXME: brightness...

    property QtObject model: pmSource.data["Battery0"]

    Component.onCompleted: {
        // setup handler on slider value manually to avoid change on creation

        brightnessSlider.valueChanged.connect(function() {
            batterymonitor.screenBrightness = brightnessSlider.value
        })
    }

    Column {
        id: settingsColumn
        anchors.fill: parent
        spacing: Math.round(units.gridUnit / 2)

        PlasmaComponents.Label {
            // this is just for metrics, TODO use TextMetrics in 5.4 instead
            id: percentageMeasurementLabel
            text: i18nc("Used for measurement", "100%")
            visible: false
        }
        RowLayout {
            id: infoRow
            width: parent.width
            spacing: units.gridUnit

            BatteryIcon {
                id: batteryIcon
                Layout.alignment: Qt.AlignTop
                width: units.iconSizes.large
                height: width
                batteryType: model["Type"]
                percent: pmSource.data["Battery0"]["Percent"]
                hasBattery: true
                pluggedIn: pmSource.data["Battery0"]["State"] === "Charging" && pmSource.data["Battery0"]["Is Power Supply"]
            }

            Column {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop


                RowLayout {
                    width: parent.width
                    height: units.gridUnit
                    spacing: units.smallSpacing

//                     Rectangle {
//                         color: "blue"
//                         opacity: 0.4
//                         anchors.fill: parent
//                     }

                    PlasmaComponents.Label {
                        id: batteryNameLabel
                        Layout.fillWidth: true
                        height: implicitHeight
                        elide: Text.ElideRight
                        text: model["Pretty Name"]
                    }

                    PlasmaComponents.Label {
                        text: stringForBatteryState(pmSource.data["Battery0"])
                        height: implicitHeight
                        //visible: model["Is Power Supply"]
                        opacity: 0.6
                    }

                    PlasmaComponents.Label {
                        id: batteryPercent
                        height: paintedHeight
                        horizontalAlignment: Text.AlignRight
                        //visible: batteryItem.isPresent
                        text: i18nc("Placeholder is battery percentage", "%1%", pmSource.data["Battery"]["Percent"])
                    }
                }

                PlasmaComponents.ProgressBar {
                    width: parent.width
                    minimumValue: 0
                    maximumValue: 100
                    visible: model["Plugged in"]
                    value: Number(pmSource.data["Battery0"]["Percent"])
                }
            }
        }

        RowLayout {

            visible: isBrightnessAvailable

            property alias icon: brightnessIcon.source
            property alias label: brightnessLabel.text
            property alias value: brightnessSlider.value
            property alias maximumValue: brightnessSlider.maximumValue
            width: parent.width

            //             KeyNavigation.tab: keyboardBrightnessSlider
            //             KeyNavigation.backtab: batteryList

            // Manually dragging the slider around breaks the binding
            spacing: units.gridUnit

            PlasmaCore.IconItem {
                id: brightnessIcon
                source: "video-display-brightness"
                Layout.alignment: Qt.AlignTop
                width: units.iconSizes.medium
                height: width
            }

            Column {
                id: brightnessColumn
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: 0

                PlasmaComponents.Label {
                    id: brightnessLabel
                    width: parent.width
                    height: paintedHeight
                    text: i18n("Screen Brightness")
                }

                PlasmaComponents.Slider {
                    id: brightnessSlider
                    width: parent.width
                    // Don't allow the slider to turn off the screen
                    // Please see https://git.reviewboard.kde.org/r/122505/ for more information
                    value: batterymonitor.screenBrightness
                    minimumValue: maximumValue > 100 ? 1 : 0
                    maximumValue: batterymonitor.maximumScreenBrightness
                    stepSize: 1
                }
            }
            Connections {
                target: batterymonitor
                onScreenBrightnessChanged: brightnessSlider.value = batterymonitor.screenBrightness
            }
        }
        /*
        PlasmaExtras.Heading {
            anchors {
                left: parent.left
                leftMargin: -Math.round(units.gridUnit / 2)
                right: parent.right
            }
            level: 3
            opacity: 0.6
            visible: !isBrightnessAvailable
            text: i18n("Changing screen brightness is not supported")
            wrapMode: Text.Wrap
        }
        */
    }
}
