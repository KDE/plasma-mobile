/*
 *   Copycontext 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Controls 1.2 as Controls
import QtQuick.Layouts 1.2
import org.kde.plasma.mobilecomponents 0.2

Page {
    id: page
    Layout.fillWidth: true
    Timer {
        id: timer
        property int value: 0
        interval: 80
        repeat: true
        running: true
        onTriggered: {
            value = (value + 1) % 100
        }
    }
    Controls.ScrollView {
        id: scrollView
        anchors.fill: parent
        ColumnLayout {
            width: page.width
            Heading {
                text: "Progress Indicators"
                anchors {
                    left: parent.left
                    top: parent.top
                    leftMargin: Units.smallSpacing
                }
            }
            GridLayout {
                anchors.centerIn: parent
                rowSpacing: Units.largeSpacing
                columns: 2
                width: parent.width - units.gridUnit*2

                Label {
                    text: "Determinate:"
                    Layout.alignment: Qt.AlignRight
                }
                Controls.ProgressBar {
                    minimumValue: 0
                    maximumValue: 100
                    value: timer.value
                    Layout.maximumWidth: units.gridUnit * 10
                }
                Label {
                    text: "Indeterminate:"
                    Layout.alignment: Qt.AlignRight
                }
                Controls.ProgressBar {
                    minimumValue: 0
                    maximumValue: 100
                    indeterminate: true
                    Layout.maximumWidth: units.gridUnit * 10
                }
                Label {
                    text: "Busy indicator:"
                    Layout.alignment: Qt.AlignRight
                }
                Controls.BusyIndicator {
                    
                }
                Label {
                    text: "Inactive indicator:"
                    Layout.alignment: Qt.AlignRight
                }
                Controls.BusyIndicator {
                    running: false
                }
                Label {
                    text: "Custom size:"
                    Layout.alignment: Qt.AlignRight
                }
                Controls.BusyIndicator {
                    Layout.minimumWidth: Units.iconSizes.enormous
                    Layout.minimumHeight: width
                }
                Label {
                    text: "Vertical:"
                    Layout.alignment: Qt.AlignRight
                }
                RowLayout {
                    Controls.ProgressBar {
                        Layout.minimumWidth: Units.gridUnit * 2
                        Layout.maximumHeight: Units.gridUnit * 8
                        minimumValue: 0
                        maximumValue: 100
                        value: timer.value
                        orientation: Qt.Vertical
                    }
                    Controls.ProgressBar {
                        Layout.minimumWidth: Units.gridUnit * 2
                        Layout.maximumHeight: Units.gridUnit * 8
                        indeterminate: true
                        orientation: Qt.Vertical
                    }
                }
            }
        }
    }
}
