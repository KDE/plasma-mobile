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
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import org.kde.people 1.0 as KPeople
import org.kde.kquickcontrolsaddons 2.0 as ExtraComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras


PlasmaExtras.ScrollArea {
    anchors.fill: parent
    verticalScrollBarPolicy: Qt.ScrollBarAsNeeded

    contentItem: ListView {
        id: contactsList

        property bool delegateSelected: false

        clip: true
        model: PlasmaCore.SortFilterModel {
            sortRole: "display"
            sourceModel: KPeople.PersonsModel {
                id: contactsModel
            }
        }

        boundsBehavior: Flickable.StopAtBounds

        delegate: PlasmaComponents.ListItem {
            height: units.gridUnit * 6
            enabled: true
            clip: true
            opacity: contactsList.delegateSelected && contactsList.currentIndex != index ? 0.4 : 1

            onClicked: {
                if (contactsList.delegateSelected) {
                    contactsList.currentIndex = -1;
                    contactsList.delegateSelected = false;
                } else {
                    contactsList.currentIndex = index;
                    contactsList.delegateSelected = true;
                }

                contactsList.toggleOverlayButtons(contactsList.delegateSelected);
            }


            RowLayout {
                id: mainLayout
                anchors.fill: parent

                ExtraComponents.QPixmapItem {
                    id: avatarLabel

                    Layout.maximumWidth: parent.height
                    Layout.minimumWidth: parent.height
                    Layout.fillHeight: true

                    pixmap: model.decoration
                    fillMode: ExtraComponents.QPixmapItem.PreserveAspectFit
                    smooth: true
                }

                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    Label {
                        id: nickLabel

                        Layout.fillWidth: true

                        text: model.display
                        elide: Text.ElideRight
                    }

                    Label {
                        id: dataLabel

                        Layout.fillWidth: true

                        text: "605-909-123"
                        elide: Text.ElideRight
                    }

                }
            }
        }

        function toggleOverlayButtons(show) {
            if (show) {
                settingsRect.parent = contactsList.currentItem
                settingsRect.visible = true;

                callRect.parent = contactsList.currentItem
                callRect.visible = true;
            } else {
                settingsRect.visible = false;
                callRect.visible = false;
            }
        }

        Rectangle {
            id: settingsRect
            height: units.gridUnit * 6
            width:  height + units.gridUnit * 2
            radius: 45
            z: 100
            visible: false
            color: "lightblue"

            anchors {
                left: parent.left
                leftMargin: -width/2
                verticalCenter: parent.verticalCenter
            }


            PlasmaCore.IconItem {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: parent.height / 4
                source: "configure-shortcuts"
            }
        }

        Rectangle {
            id: callRect
            height: settingsRect.height
            width: settingsRect.width
            radius: height
            z: 100
            visible: false
            color: "lightgreen"

            anchors {
                right: parent.right
                rightMargin: -width/2
                verticalCenter: parent.verticalCenter
            }

            PlasmaCore.IconItem {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: parent.height / 4
                source: "call-start"
            }
            MouseArea {
                anchors.fill: parent
                //TODO: needs the proper number
                onClicked: Qt.openUrlExternally("call://" + "605909123")
            }
        }

        highlight: PlasmaComponents.Highlight {
            hover: contactsList.focus
        }
        highlightMoveDuration: 0
    }
}
