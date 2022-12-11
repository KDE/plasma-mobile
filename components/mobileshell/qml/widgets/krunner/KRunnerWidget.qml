/*
 *   SPDX-FileCopyrightText: 2014 Aaron Seigo <aseigo@kde.org>
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState

import org.kde.milou 0.1 as Milou
import org.kde.kirigami 2.19 as Kirigami

import "../../components" as Components

/**
 * Search widget that is embedded into the homescreen. The dimensions of 
 * the root item is assumed to be the available screen area for applications.
 */
Item {
    id: root

    // content margins (background ignores this)
    property real topMargin: 0
    property real bottomMargin: 0
    property real leftMargin: 0
    property real rightMargin: 0

    function startGesture() {
        queryField.text = "";
        flickable.contentY = closedContentY;
    }
    
    function updateGestureOffset(yOffset) {
        flickable.contentY = Math.max(0, Math.min(closedContentY, flickable.contentY + yOffset));
    }
    
    // call when the touch gesture has let go
    function endGesture() {
        flickable.opening ? open() : close();
    }
    
    // open the search widget (animated)
    function open() {
        anim.to = openedContentY;
        anim.restart();
    }
    
    // close the search widget (animated)
    function close() {
        anim.to = closedContentY;
        anim.restart();
    }
    
    readonly property real closedContentY: PlasmaCore.Units.gridUnit * 5
    readonly property real openedContentY: 0
    readonly property real openFactor: Math.max(0, Math.min(1, 1 - flickable.contentY / closedContentY))
    readonly property bool isOpen: openFactor != 0
    
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.3)
        opacity: root.openFactor
    }
    
    onOpacityChanged: {
        if (opacity === 0) {
            close();
        }
    }
    
    Flickable {
        id: flickable
        
        anchors.fill: parent
        anchors.topMargin: root.topMargin
        anchors.bottomMargin: root.bottomMargin
        anchors.leftMargin: root.leftMargin
        anchors.rightMargin: root.rightMargin
        
        contentHeight: flickable.height + root.closedContentY + 999999
        contentY: root.closedContentY
        property real oldContentY: contentY
        property bool opening: false
        
        onContentYChanged: {
            opening = contentY < oldContentY;
            oldContentY = contentY;
            
            if (contentY !== root.openedContentY) {
                queryField.focus = false;
            }
        }
        
        onMovementEnded: root.endGesture()
        
        onDraggingChanged: {
            if (!dragging) {
                root.endGesture();
            }
        }
        
        NumberAnimation on contentY {
            id: anim
            duration: PlasmaCore.Units.longDuration * 2
            easing.type: Easing.OutQuad
            running: false
            onFinished: {
                if (anim.to === root.openedContentY) {
                    queryField.forceActiveFocus();
                }
            }
        }
        
        ColumnLayout {
            id: column
            height: flickable.height
            width: flickable.width
            
            Controls.Control {
                opacity: root.openFactor
                Layout.fillWidth: true
                Layout.maximumWidth: PlasmaCore.Units.gridUnit * 30
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: PlasmaCore.Units.gridUnit
                Layout.leftMargin: PlasmaCore.Units.gridUnit
                Layout.rightMargin: PlasmaCore.Units.gridUnit
                
                leftPadding: PlasmaCore.Units.smallSpacing 
                rightPadding: PlasmaCore.Units.smallSpacing 
                topPadding: PlasmaCore.Units.smallSpacing 
                bottomPadding: PlasmaCore.Units.smallSpacing 
                
                background: Item {
                    
                    // shadow for search window
                    RectangularGlow {
                        anchors.topMargin: 1 
                        anchors.fill: parent
                        cached: true
                        glowRadius: 4
                        spread: 0.2
                        color: Qt.rgba(0, 0, 0, 0.15)
                    }
                    
                    Rectangle {
                        anchors.fill: parent
                        color: PlasmaCore.Theme.backgroundColor
                        radius: PlasmaCore.Units.smallSpacing
                    }
                }
                
                contentItem: RowLayout {
                    Item {
                        implicitHeight: queryField.height
                        implicitWidth: height
                        PlasmaCore.IconItem {
                            anchors.fill: parent
                            anchors.margins: Math.round(Kirigami.Units.smallSpacing)
                            source: "start-here-symbolic"
                        }
                    }
                    PlasmaComponents.TextField {
                        id: queryField
                        Layout.fillWidth: true
                        placeholderText: i18n("Search…")
                        inputMethodHints: Qt.ImhNoPredictiveText // don't need to press "enter" to update text
                    }
                }
            }
            
            Controls.ScrollView {
                opacity: root.openFactor === 1 ? 1 : 0
                Behavior on opacity {
                    NumberAnimation { duration: PlasmaCore.Units.shortDuration }
                }
                
                Layout.fillWidth: true

                Milou.ResultsListView {
                    id: listView
                    queryString: queryField.text
                    highlight: null
                    clip: true
                    PlasmaCore.ColorScope.colorGroup: PlasmaCore.Theme.NormalColorGroup

                    onActivated: queryField.text = "";
                    onUpdateQueryString: {
                        queryField.text = text
                        queryField.cursorPosition = cursorPosition
                    }
                    
                    delegate: MouseArea {
                        id: delegate
                        height: rowLayout.height
                        width: listView.width
                        
                        onClicked: {
                            listView.currentIndex = model.index;
                            listView.runCurrentIndex();
                        }
                        hoverEnabled: true
                        
                        Rectangle {
                            anchors.fill: parent
                            color: delegate.pressed ? Qt.rgba(255, 255, 255, 0.2) : (delegate.containsMouse ? Qt.rgba(255, 255, 255, 0.05) : "transparent")
                            Behavior on color {
                                ColorAnimation { duration: PlasmaCore.Units.shortDuration }
                            }
                        }
                        
                        RowLayout {
                            id: rowLayout
                            height: PlasmaCore.Units.gridUnit * 3
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: PlasmaCore.Units.largeSpacing
                            anchors.rightMargin: PlasmaCore.Units.largeSpacing
                            
                            Kirigami.Icon {
                                Layout.alignment: Qt.AlignVCenter
                                source: model.decoration
                                implicitWidth: PlasmaCore.Units.iconSizes.medium
                                implicitHeight: PlasmaCore.Units.iconSizes.medium
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: PlasmaCore.Units.smallSpacing
                                
                                PlasmaComponents.Label {
                                    id: title
                                    Layout.fillWidth: true
                                    Layout.leftMargin: PlasmaCore.Units.smallSpacing * 2
                                    Layout.rightMargin: PlasmaCore.Units.largeSpacing
                                    
                                    maximumLineCount: 1
                                    elide: Text.ElideRight
                                    text: typeof modelData !== "undefined" ? modelData : model.display
                                    color: "white"

                                    font.pointSize: PlasmaCore.Theme.defaultFont.pointSize
                                }
                                PlasmaComponents.Label {
                                    id: subtitle
                                    Layout.fillWidth: true
                                    Layout.leftMargin: PlasmaCore.Units.smallSpacing * 2
                                    Layout.rightMargin: PlasmaCore.Units.largeSpacing
                                    
                                    maximumLineCount: 1
                                    elide: Text.ElideRight
                                    text: model.subtext || ""
                                    color: "white"
                                    opacity: 0.8

                                    font.pointSize: Math.round(PlasmaCore.Theme.defaultFont.pointSize * 0.8)
                                }
                            }
                            
                            Repeater {
                                id: actionsRepeater
                                model: typeof actions !== "undefined" ? actions : []

                                Controls.ToolButton {
                                    icon: modelData.icon || ""
                                    visible: modelData.visible || true
                                    enabled: modelData.enabled || true

                                    Accessible.role: Accessible.Button
                                    Accessible.name: modelData.text
                                    checkable: checked
                                    checked: delegate.activeAction === index
                                    focus: delegate.activeAction === index
                                    onClicked: delegate.ListView.view.runAction(index)
                                }
                            }
                        }
                    }
                }
            }

            MouseArea {
                Layout.fillWidth: true
                Layout.fillHeight: true

                onClicked: close()
            }
        }
    }
}
