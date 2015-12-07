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

import QtQuick 2.1
import QtQuick.Layouts 1.2
import org.kde.plasma.mobilecomponents 0.2
import org.kde.plasma.core 2.0 as PlasmaCore

Page {
    Layout.fillWidth: true

    Heading {
        id: heading
        text: "Icon Grid"
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: Units.smallSpacing
        }
    }
    IconGrid {
        id: grid
        anchors {
            left: parent.left
            right: parent.right
            top: heading.bottom
            bottom: parent.bottom
        }

        model: PlasmaCore.DataModel {
            dataSource: PlasmaCore.DataSource {
                engine: "apps"
                connectedSources: sources
            }
        }
        delegate: Item {
            width: grid.delegateWidth
            height: grid.delegateHeight
            Item {
                anchors {
                    fill: parent
                    margins: units.gridUnit
                }
                Icon {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                    }
                    width: Units.iconSizes.huge
                    height: width
                    source: model.iconName
                }
                Label {
                    text: model.name
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.bottom
                    }
                }
            }
        }
    }
}
