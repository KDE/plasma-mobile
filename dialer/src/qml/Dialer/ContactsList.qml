/*
 *   Copyright 2015 Martin Klapetek <mklapetek@kde.org>
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
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.8 as Kirigami
import org.kde.people 1.0 as KPeople
import org.kde.plasma.core 2.0 as PlasmaCore


Item {
    Controls.Label {
        anchors.centerIn: parent
        text: i18n("No contacts")
        visible: contactsList.count === 0
    }

    ColumnLayout {
        anchors.fill: parent

        Kirigami.SearchField {
            id: searchField
            Layout.fillWidth: true
        }

        Controls.ScrollView {
            id: contactScrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Controls.ScrollBar.vertical.policy: Controls.ScrollBar.AlwaysOn

            contentItem: ListView {
                id: contactsList

                property string numberToCall

                section.property: "display"
                section.criteria: ViewSection.FirstCharacter
                clip: true
                model: PlasmaCore.SortFilterModel {
                    sourceModel: KPeople.PersonsSortFilterProxyModel {
                        sourceModel: KPeople.PersonsModel {
                            id: contactsModel
                        }
                        requiredProperties: "phoneNumber"
                    }
                    sortRole: "display"
                    filterRole: "display"
                    filterRegExp: ".*" + searchField.text + ".*"
                    sortOrder: Qt.AscendingOrder
                }

        //         PlasmaCore.SortFilterModel {
        //             sortRole: "display"
        //             sourceModel:
        //         }

                boundsBehavior: Flickable.StopAtBounds

                delegate: Kirigami.SwipeListItem {
                    height: Kirigami.Units.gridUnit * 6
                    enabled: true
                    clip: true

                    onClicked: {
                            contactsList.numberToCall = model.phoneNumber;
                    }

                    actions: [
                        Kirigami.Action {
                            icon.name: "call-start"
                            text: i18n("Call")
                            onTriggered: call(contactsList.numberToCall)
                        },
                        Kirigami.Action {
                            icon.name: "configure-shortcuts"
                            text: i18n("Send Message")
                        }
                    ]


                    RowLayout {
                        id: mainLayout
                        anchors.fill: parent
                        spacing: 10

                        RoundImage {
                            id: avatar
                            source: model.decoration
                            isRound: true

                            Layout.preferredHeight: parent.height - Kirigami.Units.gridUnit
                            Layout.preferredWidth: parent.height - Kirigami.Units.gridUnit
                        }

                        ColumnLayout {
                            // contact name
                            Kirigami.Heading {
                                id: nickLabel
                                text: model.display
                                textFormat: Text.PlainText
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                level: 3
                                Layout.fillWidth: true
                            }

                            Controls.Label {
                                id: dataLabel
                                text: model.phoneNumber

                                elide: Text.ElideRight
                                visible: dataLabel.text !== nickLabel.text
                            }
                        }
                    }
                }

                CustomSectionScroller {
                    listView: contactsList
                }
            }
        }
    }
}
