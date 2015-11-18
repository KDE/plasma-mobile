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
import org.kde.plasma.mobilecomponents 0.2

OverlayDrawer {
    id: root
    inverse: true

    default property alias content: mainContent.data

    property alias title: heading.text
    property alias titleIcon: headingIcon.source
    property list<Action> actions

    drawer: ColumnLayout {
        id: mainColumn
        anchors.fill: parent
        spacing: 0
        implicitWidth: units.gridUnit * 12

        RowLayout {
            Layout.fillWidth: true
            Layout.minimumHeight: Math.max(headingIcon.height, heading.height) + Units.smallSpacing*2
            anchors {
                left: parent.left
                margins: Units.smallSpacing
            }
            Icon {
                id: headingIcon
                Layout.minimumWidth: Units.iconSizes.large
                Layout.minimumHeight: width
            }
            Heading {
                id: heading
                level: 1
            }
            Item {
                height: parent.height
                Layout.minimumWidth: height
            }
        }
        Rectangle {
            color: Theme.textColor
            opacity: 0.2
            Layout.fillWidth: true
            Layout.minimumHeight: 1
        }

        PageRow {
            id: pageRow
            Layout.fillWidth: true
            Layout.fillHeight: true
            initialPage: menuComponent
        }

        ColumnLayout {
            id: mainContent
            Layout.alignment: Qt.AlignHCenter
            Layout.minimumWidth: parent.width - Units.smallSpacing*2
            Layout.maximumWidth: Layout.minimumWidth
            Layout.fillWidth: false
            Layout.fillHeight: true
        }
        Item {
            Layout.minimumWidth: Units.smallSpacing
            Layout.minimumHeight: Units.smallSpacing
        }

        Component {
            id: menuComponent
            ListView {
                id: optionMenu

                model: actions
                property int level: 0

                footer: ListItem {
                    visible: level > 0
                    enabled: true
                    RowLayout {
                        anchors {
                            left: parent.left
                        }
                        Icon {
                            Layout.maximumWidth: height
                            Layout.fillHeight: true
                            source: "go-previous"
                        }
                        Label {
                            text: i18n("Back")
                        }
                    }
                    onClicked: pageRow.pop()
                }
                delegate: ListItem {
                    enabled: true
                    RowLayout {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        Icon {
                            Layout.maximumWidth: height
                            Layout.fillHeight: true
                            source: modelData.iconName
                        }
                        Label {
                            Layout.fillWidth: true
                            text: modelData.text
                        }
                        Icon {
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

