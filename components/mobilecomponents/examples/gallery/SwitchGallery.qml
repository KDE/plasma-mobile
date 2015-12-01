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
import QtQuick.Layouts 1.3
import org.kde.plasma.mobilecomponents 0.2
//FIXME
import org.kde.plasma.core 2.0 as PlasmaCore

Page {
    id: page
    Layout.fillWidth: true
    flickable: scrollView.flickableItem
    Controls.ScrollView {
        id: scrollView
        anchors.fill: parent
        
        ColumnLayout {
            width: page.width
            Heading {
                text: "Switches"
                anchors {
                    left: parent.left
                    leftMargin: Units.smallSpacing
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.minimumHeight: units.gridUnit * 10
                GridLayout {
                    anchors.centerIn: parent
                    columns: 3
                    rows: 3
                    rowSpacing: Units.smallSpacing

                    Item {
                        width: 1
                        height: 1
                    }
                    Label {
                        text: "Normal"
                    }
                    Label {
                        text: "Disabled"
                        enabled: false
                    }
                    Label {
                        text: "On"
                    }
                    Controls.Switch {
                        checked: true
                    }
                    Controls.Switch {
                        checked: true
                        enabled: false
                    }
                    Label {
                        text: "Off"
                    }
                    Controls.Switch {
                        checked: false
                    }
                    Controls.Switch {
                        checked: false
                        enabled: false
                    }
                }
            }
            //FIXME: possible to have this in mobileComponents?
            PlasmaCore.ColorScope {
                colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                Layout.fillWidth: true
                Layout.minimumHeight: units.gridUnit * 10
                Rectangle {
                    anchors.fill: parent
                    color: PlasmaCore.ColorScope.backgroundColor
                    GridLayout {
                        anchors.centerIn: parent
                        columns: 3
                        rows: 3
                        rowSpacing: Units.smallSpacing

                        Item {
                            width: 1
                            height: 1
                        }
                        Label {
                            text: "Normal"
                        }
                        Label {
                            text: "Disabled"
                            enabled: false
                        }
                        Label {
                            text: "On"
                        }
                        Controls.Switch {
                            checked: true
                        }
                        Controls.Switch {
                            checked: true
                            enabled: false
                        }
                        Label {
                            text: "Off"
                        }
                        Controls.Switch {
                            checked: false
                        }
                        Controls.Switch {
                            checked: false
                            enabled: false
                        }
                    }
                }
            }
        }
    }
}
