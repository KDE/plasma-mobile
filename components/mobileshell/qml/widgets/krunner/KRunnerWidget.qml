/*
 *   SPDX-FileCopyrightText: 2014 Aaron Seigo <aseigo@kde.org>
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Effects
import QtQuick.Controls as Controls
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.milou as Milou
import org.kde.kirigami 2.19 as Kirigami

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

    // emitted when an item on the ListView is triggered
    signal actionTriggered()

    readonly property real closedContentY: Kirigami.Units.gridUnit * 5
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

    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Down) {
                            listView.forceActiveFocus();
                        }
                    }

    Flickable {
        id: flickable

        anchors.fill: parent
        anchors.topMargin: root.topMargin
        anchors.bottomMargin: root.bottomMargin
        anchors.leftMargin: root.leftMargin
        anchors.rightMargin: root.rightMargin

        contentHeight: flickable.height + root.closedContentY
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
            duration: Kirigami.Units.longDuration * 2
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
                Layout.maximumWidth: Kirigami.Units.gridUnit * 30
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Kirigami.Units.gridUnit
                Layout.leftMargin: Kirigami.Units.gridUnit
                Layout.rightMargin: Kirigami.Units.gridUnit

                leftPadding: Kirigami.Units.smallSpacing
                rightPadding: Kirigami.Units.smallSpacing
                topPadding: Kirigami.Units.smallSpacing
                bottomPadding: Kirigami.Units.smallSpacing

                background: Item {

                    // shadow for search window
                    MultiEffect {
                        anchors.fill: parent
                        source: rectBackground
                        blurMax: 16
                        shadowEnabled: true
                        shadowVerticalOffset: 1
                        shadowOpacity: 0.15
                    }

                    Rectangle {
                        id: rectBackground
                        anchors.fill: parent
                        color: Kirigami.Theme.backgroundColor
                        radius: Kirigami.Units.cornerRadius
                    }
                }

                contentItem: RowLayout {
                    Item {
                        implicitHeight: queryField.height
                        implicitWidth: height
                        Kirigami.Icon {
                            anchors.fill: parent
                            anchors.margins: Math.round(Kirigami.Units.smallSpacing)
                            source: "start-here-symbolic"
                        }
                    }
                    PlasmaComponents.TextField {
                        id: queryField
                        Layout.fillWidth: true
                        placeholderText: "Search…"
                        inputMethodHints: Qt.ImhNoPredictiveText // don't need to press "enter" to update text
                    }
                }
            }

            Controls.ScrollView {
                opacity: root.openFactor === 1 ? 1 : 0
                Behavior on opacity {
                    NumberAnimation { duration: Kirigami.Units.shortDuration }
                }

                Layout.fillWidth: true
                Layout.fillHeight: listView.contentHeight > availableHeight

                Milou.ResultsListView {
                    id: listView
                    queryString: queryField.text
                    clip: true
                    Kirigami.Theme.colorSet: Kirigami.Theme.Window

                    highlight: activeFocus ? highlightComponent : null
                    Component {
                        id: highlightComponent

                        PlasmaExtras.Highlight {}
                    }

                    onActivated: {
                        root.close();
                    }
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

                            root.actionTriggered();
                        }
                        hoverEnabled: true

                        function activateNextAction() {
                            queryField.forceActiveFocus();
                            queryField.selectAll();
                            listView.currentIndex = -1;
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: delegate.pressed ? Qt.rgba(255, 255, 255, 0.2) : (delegate.containsMouse ? Qt.rgba(255, 255, 255, 0.05) : "transparent")
                            Behavior on color {
                                ColorAnimation { duration: Kirigami.Units.shortDuration }
                            }
                        }

                        RowLayout {
                            id: rowLayout
                            height: Kirigami.Units.gridUnit * 3
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: Kirigami.Units.gridUnit
                            anchors.rightMargin: Kirigami.Units.gridUnit

                            Kirigami.Icon {
                                Layout.alignment: Qt.AlignVCenter
                                source: model.decoration
                                implicitWidth: Kirigami.Units.iconSizes.medium
                                implicitHeight: Kirigami.Units.iconSizes.medium
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: Kirigami.Units.smallSpacing

                                PlasmaComponents.Label {
                                    id: title
                                    Layout.fillWidth: true
                                    Layout.leftMargin: Kirigami.Units.smallSpacing * 2
                                    Layout.rightMargin: Kirigami.Units.gridUnit

                                    maximumLineCount: 1
                                    elide: Text.ElideRight
                                    text: typeof modelData !== "undefined" ? modelData : model.display
                                    color: "white"

                                    font.pointSize: Kirigami.Theme.defaultFont.pointSize
                                }
                                PlasmaComponents.Label {
                                    id: subtitle
                                    Layout.fillWidth: true
                                    Layout.leftMargin: Kirigami.Units.smallSpacing * 2
                                    Layout.rightMargin: Kirigami.Units.gridUnit

                                    maximumLineCount: 1
                                    elide: Text.ElideRight
                                    text: model.subtext || ""
                                    color: "white"
                                    opacity: 0.8

                                    font.pointSize: Math.round(Kirigami.Theme.defaultFont.pointSize * 0.8)
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
