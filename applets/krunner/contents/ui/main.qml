/*
 *   Copyright 2014 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2015 Marco Martin <notmart@gmail.com>
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

import QtQuick 2.1
import QtQuick.Window 2.1
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.milou 0.1 as Milou
import org.kde.kirigami 2.14 as Kirigami

Item {
    PlasmaCore.ColorScope.colorGroup: PlasmaCore.Theme.NormalColorGroup
    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground | PlasmaCore.Types.ConfigurableBackground
    Layout.minimumWidth: Math.min(plasmoid.availableScreenRect.width, plasmoid.availableScreenRect.height) - Kirigami.Units.gridUnit * 2

    Rectangle {
        id: background

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: units.gridUnit
        }
        radius: height/2
        height: layout.implicitHeight + radius
        color: Qt.rgba(1,1,1, 0.3)

        RowLayout {
            id: layout
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                margins: background.radius/2
            }
            Kirigami.Icon {
                source: "search"
                Layout.fillHeight: true
                Layout.preferredWidth: height
                color: "white"
            }
            PlasmaExtras.Heading {
                level: 2
                text: i18n("Search...")
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: window.showMaximized()
        }
        Kirigami.AbstractApplicationWindow {
            id: window
            visible: false
            onVisibleChanged: {
                if (visible) {
                    queryField.forceActiveFocus();
                }
            }
            header: Controls.ToolBar {
                height: Kirigami.Units.gridUnit * 2
                contentItem: Kirigami.SearchField {
                    id: queryField
                    focus: true
                }
            }
            PlasmaCore.IconItem {
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }
                width: Math.min(parent.width, parent.height) * 0.8
                height: width
                opacity: 0.2
                source: "search"
            }
            Controls.ScrollView {
                anchors.fill: parent
                Milou.ResultsListView {
                    id: listView
                    queryString: queryField.text
                    highlight: null
                    PlasmaCore.ColorScope.colorGroup: PlasmaCore.Theme.NormalColorGroup
                    anchors.rightMargin: 10

                    onActivated: queryField.text = ""
                    onUpdateQueryString: {
                        queryField.text = text
                        queryField.cursorPosition = cursorPosition
                    }
                }
            }
        }
    }
}
