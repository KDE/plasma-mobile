/*
 *   SPDX-FileCopyrightText: 2014 Aaron Seigo <aseigo@kde.org>
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Window 2.1
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.12
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
        height: layout.implicitHeight + PlasmaCore.Units.largeSpacing
        color: Qt.rgba(1,1,1, 0.3)

        RowLayout {
            id: layout
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: background.radius/2
            }
            spacing: PlasmaCore.Units.smallSpacing * 2
            Kirigami.Icon {
                source: "start-here-symbolic"
                Layout.preferredHeight: PlasmaCore.Units.gridUnit * 1.5
                Layout.preferredWidth: height
                color: "white"
            }
            PlasmaExtras.Heading {
                level: 3
                text: i18n("Search...")
            }
            Item { Layout.fillWidth: true }
            Kirigami.Icon {
                source: "search"
                Layout.preferredHeight: PlasmaCore.Units.gridUnit * 1.5
                Layout.preferredWidth: height
                color: "white"
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: window.showMaximized()
        }
        
        Kirigami.AbstractApplicationWindow {
            id: window
            visible: false
            color: "transparent"
            onVisibleChanged: {
                if (!visible) {
                    queryField.forceActiveFocus();
                }
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: window.close();
                
                // shadow for search window
                RectangularGlow {
                    anchors.topMargin: 1 
                    anchors.fill: content
                    cached: true
                    glowRadius: 4
                    spread: 0.2
                    color: Qt.rgba(0, 0, 0, 0.15)
                }

                MouseArea {
                    id: content
                    // capture presses on the rectangle so that it doesn't close the window
                    anchors.top: parent.top
                    anchors.topMargin: Kirigami.Units.largeSpacing * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    implicitWidth: Math.min(Kirigami.Units.gridUnit * 30, parent.width - Kirigami.Units.largeSpacing * 4)
                    implicitHeight: Math.min(mainColumn.implicitHeight, parent.height - Kirigami.Units.largeSpacing * 4)

                    Behavior on implicitHeight {
                        NumberAnimation { 
                            duration: Kirigami.Units.longDuration 
                            easing.type: Easing.InOutQuad
                        }
                    }
                    
                    Rectangle {
                        anchors.fill: parent
                        radius: Kirigami.Units.smallSpacing 

                        Kirigami.Theme.inherit: false
                        Kirigami.Theme.colorSet: Kirigami.Theme.View
                        color: Kirigami.Theme.backgroundColor

                        ColumnLayout {
                            id: mainColumn
                            anchors.fill: parent
                            anchors.margins: Kirigami.Units.smallSpacing

                            RowLayout {
                                Layout.bottomMargin: Kirigami.Units.smallSpacing / 2
                                Item {
                                    implicitHeight: queryField.height
                                    implicitWidth: height
                                    Kirigami.Icon {
                                        anchors.fill: parent
                                        anchors.margins: Math.round(Kirigami.Units.smallSpacing * 1.5)
                                        source: "start-here-symbolic"
                                    }
                                }
                                Kirigami.SearchField {
                                    id: queryField
                                    focus: true
                                    Layout.fillWidth: true
                                }
                            }

                            Controls.ScrollView {
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                Milou.ResultsListView {
                                    id: listView
                                    queryString: queryField.text
                                    highlight: null
                                    PlasmaCore.ColorScope.colorGroup: PlasmaCore.Theme.NormalColorGroup
                                    anchors.rightMargin: 10

                                    onActivated: {
                                        window.visible = false;
                                        queryField.text = "";
                                    }
                                    onUpdateQueryString: {
                                        queryField.text = text
                                        queryField.cursorPosition = cursorPosition
                                    }

                                    delegate: Kirigami.BasicListItem {
                                        id: resultDelegate
                                        property var additionalActions: typeof actions !== "undefined" ? actions : []
                                        icon: model.decoration
                                        label: typeof modelData !== "undefined" ? modelData : model.display
                                        subtitle: model.subtext || ""
                                        onClicked: {
                                            listView.currentIndex = model.index
                                            listView.runCurrentIndex()
                                        }
                                        Row {
                                            id: actionsRow

                                            Repeater {
                                                id: actionsRepeater
                                                model: resultDelegate.additionalActions

                                                Controls.ToolButton {
                                                    width: height
                                                    height: listItem.height
                                                    visible: modelData.visible || true
                                                    enabled: modelData.enabled || true

                                                    Accessible.role: Accessible.Button
                                                    Accessible.name: modelData.text
                                                    checkable: checked
                                                    checked: resultDelegate.activeAction === index
                                                    focus: resultDelegate.activeAction === index

                                                    Kirigami.Icon {
                                                        anchors.centerIn: parent
                                                        width: units.iconSizes.small
                                                        height: units.iconSizes.small
                                                        // ToolButton cannot cope with QIcon
                                                        source: modelData.icon || ""
                                                        active: parent.hovered || parent.checked
                                                    }

                                                    onClicked: resultDelegate.ListView.view.runAction(index)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
