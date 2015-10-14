/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
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
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.3
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons  2.0
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents

MobileComponents.OverlayDrawer {
    id: root
    inverse: true

    property alias content: mainContent.data

    property alias title: heading.text
    property alias titleIcon: headingIcon.source
    property list<Action> actions

    drawer: ColumnLayout {
        id: mainColumn
        anchors.fill: parent
        implicitWidth: units.gridUnit * 12

        RowLayout {
            Layout.fillWidth: true
            anchors {
                left: parent.left
            }
            PlasmaCore.IconItem {
                id: headingIcon
                height: parent.height
                width: height
                Layout.minimumWidth: height
            }
            PlasmaExtras.Heading {
                id: heading
                level: 1
            }
            Item {
                height: parent.height
                Layout.minimumWidth: height
            }
        }

        PlasmaExtras.PageRow {
            id: pageRow
            Layout.fillWidth: true
            Layout.fillHeight: true
            initialPage: menuComponent
        }

        ColumnLayout {
            id: mainContent
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
        Component {
            id: menuComponent
            ListView {
                id: optionMenu

                model: actions
                property int level: 0

                footer: PlasmaComponents.ListItem {
                    visible: level > 0
                    enabled: true
                    RowLayout {
                        anchors {
                            left: parent.left
                        }
                        PlasmaCore.IconItem {
                            Layout.maximumWidth: height
                            Layout.fillHeight: true
                            source: "go-previous"
                        }
                        PlasmaComponents.Label {
                            text: i18n("Back")
                        }
                    }
                    onClicked: pageRow.pop()
                }
                delegate: PlasmaComponents.ListItem {
                    enabled: true
                    RowLayout {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        PlasmaCore.IconItem {
                            Layout.maximumWidth: height
                            Layout.fillHeight: true
                            source: modelData.iconName
                        }
                        PlasmaComponents.Label {
                            Layout.fillWidth: true
                            text: modelData.text
                        }
                        PlasmaCore.IconItem {
                            Layout.maximumWidth: height
                            Layout.fillHeight: true
                            source: "go-next"
                            visible: modelData.children != undefined
                        }
                    }
                    onClicked: {
                        if (modelData.children) {
                            pageRow.push(menuComponent, {"model": modelData.children, "level": level + 1});
                        } else {
                            modelData.trigger();
                            pageRow.pop(pageRow.initialPage);
                        }
                    }
                }
            }
        }
    }
}

