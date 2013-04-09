/*
 *   Copyright 2013 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

import QtQuick 1.1
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.components 0.1 as PlasmaComponents

Item {
    id: root

    anchors {
        left: parent.left
        right: parent.right
        leftMargin: theme.defaultFont.mSize.width
    }
    height: mainColumn.height

    Column {
        id: mainColumn

        anchors {
            left: parent.left
            right: parent.right
        }

        PlasmaExtras.Heading {
            text: i18n("Size")
            anchors {
                right: parent.right
                rightMargin: theme.defaultFont.mSize.width
            }
        }
        Component.onDestruction: metadataModel.queryProvider.extraQueryString = ""
        PlasmaComponents.ButtonColumn {
            exclusive: true
            spacing: 4
            PlasmaComponents.RadioButton {
                text: i18n("Any size")
                onCheckedChanged: {
                    if (checked) {
                        metadataModel.queryProvider.extraQueryString = ""
                    }
                }
            }
            PlasmaComponents.RadioButton {
                text: i18n("Small")
                onCheckedChanged: {
                    if (checked) {
                        metadataModel.queryProvider.extraQueryString = "width<600"
                    }
                }
            }
            PlasmaComponents.RadioButton {
                text: i18n("Medium")
                onCheckedChanged: {
                    if (checked) {
                        metadataModel.queryProvider.extraQueryString = "width>600 and width<2000"
                    }
                }
            }
            PlasmaComponents.RadioButton {
                text: i18n("Large")
                onCheckedChanged: {
                    if (checked) {
                        metadataModel.queryProvider.extraQueryString = "width>2000"
                    }
                }
            }
        }
    }
}
