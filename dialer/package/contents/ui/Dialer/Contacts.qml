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

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.people 1.0 as KPeople
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    PlasmaComponents.Label {
        anchors.centerIn: parent
        text: i18n("No contacts")
        visible: contactsModel.count == 0
    }

    ColumnLayout {
        anchors.fill: parent
        //visible: contactsModel.count > 0

        PlasmaComponents.ToolBar {
            Layout.fillWidth: true
            tools: RowLayout {
                id: toolBarLayout
                PlasmaComponents.TextField {
                    id: searchField
                    clearButtonShown: true
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    placeholderText: i18n("Search...")
                }
            }
        }

        PlasmaExtras.ScrollArea {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ListView {
                id: view
                model: PlasmaCore.SortFilterModel {
                    id: filterModel
                    sourceModel: KPeople.PersonsModel {
                        id: contactsModel
                    }
                    sortRole: "display"
                    filterRole: "display"
                    filterRegExp: ".*"+searchField.text+".*"
                    sortOrder: Qt.AscendingOrder
                }
                section {
                    property: "display"
                    criteria: ViewSection.FirstCharacter
                    delegate: PlasmaComponents.ListItem {
                        id: sectionItem
                        sectionDelegate: true
                        PlasmaComponents.Label {
                            text: section
                        }
                    }
                }
                delegate: PlasmaComponents.ListItem {
                    RowLayout {
                        id: delegateLayout

                        KQuickControlsAddons.QPixmapItem {
                            id: avatarLabel

                            Layout.minimumWidth: units.iconSizes.medium
                            Layout.maximumWidth: Layout.minimumWidth
                            Layout.minimumHeight: Layout.minimumWidth
                            Layout.maximumHeight: Layout.minimumWidth

                            pixmap: model.decoration
                            fillMode: ExtraComponents.QPixmapItem.PreserveAspectFit
                            smooth: true
                        }

                        ColumnLayout {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            PlasmaComponents.Label {
                                id: nickLabel

                                Layout.fillWidth: true

                                text: model.display
                                elide: Text.ElideRight
                            }

                            PlasmaComponents.Label {
                                id: dataLabel

                                Layout.fillWidth: true

                                text: "605-909-123"
                                elide: Text.ElideRight
                            }

                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: call(12345)
                    }
                }
            }
        }
    }
}
