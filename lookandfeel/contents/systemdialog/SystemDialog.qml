// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami

Item {
    id: root

    // -- public API: should match plasma-workspace implementation --

    default property Item mainItem
    property string mainText: ""
    property string subtitle: ""
    property string iconName
    property list<T.Action> actions
    readonly property alias dialogButtonBox: footerButtonBox

    required property Window window
    readonly property real minimumHeight: implicitWidth
    readonly property real minimumWidth: implicitHeight
    readonly property int flags: Qt.FramelessWindowHint | Qt.Dialog
    property var standardButtons // footerButtonBox standardButtons
    readonly property int spacing: Kirigami.Units.gridUnit

    function present() {
        window.showMaximized();
    }

    onWindowChanged: {
        if (window) {
            window.color = Qt.rgba(0, 0, 0, 0.5);
        }
    }

    Item {
        id: windowItem
        anchors.centerIn: parent
        // margins for shadow
        implicitWidth: Math.min(Screen.width, control.implicitWidth + 2 * Kirigami.Units.gridUnit)
        implicitHeight: Math.min(Screen.height, control.implicitHeight + 2 * Kirigami.Units.gridUnit)

        // shadow
        RectangularGlow {
            id: glow
            anchors.topMargin: 1
            anchors.fill: control
            cached: true
            glowRadius: 2
            cornerRadius: Kirigami.Units.gridUnit
            spread: 0.1
            color: Qt.rgba(0, 0, 0, 0.4)
        }

        // actual window
        QQC2.Control {
            id: control
            anchors.fill: parent
            anchors.margins: glow.cornerRadius
            topPadding: root.spacing
            bottomPadding: root.spacing
            rightPadding: root.spacing
            leftPadding: root.spacing

            implicitWidth: Kirigami.Units.gridUnit * 22

            background: Item {
                Rectangle { // border
                    anchors.fill: parent
                    anchors.margins: -1
                    radius: Kirigami.Units.largeSpacing + 1
                    color: Qt.darker(Kirigami.Theme.backgroundColor, 1.5)
                }
                Rectangle { // background colour
                    anchors.fill: parent
                    radius: Kirigami.Units.largeSpacing
                    color: Kirigami.Theme.backgroundColor
                }
            }

            contentItem: ColumnLayout {
                id: column
                spacing: 0

                // header
                Kirigami.Heading {
                    Layout.fillWidth: true
                    Layout.maximumWidth: root.window.maximumWidth
                    level: 3
                    font.weight: Font.Bold
                    text: root.mainText
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }

                QQC2.Label {
                    Layout.topMargin: Kirigami.Units.largeSpacing
                    Layout.bottomMargin: Kirigami.Units.largeSpacing
                    Layout.maximumWidth: root.window.maximumWidth
                    Layout.fillWidth: true
                    text: root.subtitle
                    visible: text.length > 0
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Kirigami.Icon {
                    Layout.topMargin: Kirigami.Units.largeSpacing
                    Layout.alignment: Qt.AlignCenter
                    source: root.iconName
                    implicitWidth: Kirigami.Units.iconSizes.large
                    implicitHeight: Kirigami.Units.iconSizes.large
                }

                // content
                QQC2.Control {
                    id: content

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.topMargin: Kirigami.Units.gridUnit
                    Layout.maximumWidth: root.window.maximumWidth

                    leftPadding: 0
                    rightPadding: 0
                    topPadding: 0
                    bottomPadding: 0

                    contentItem: root.mainItem
                    background: Item {}
                }

                QQC2.DialogButtonBox {
                    id: footerButtonBox
                    // ensure we never have no buttons, we always must have the cancel button available
                    standardButtons: (root.standardButtons === QQC2.DialogButtonBox.NoButton) ? QQC2.DialogButtonBox.Cancel : root.standardButtons

                    Layout.topMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    Layout.maximumWidth: root.window.maximumWidth
                    leftPadding: 0
                    rightPadding: 0
                    topPadding: 0
                    bottomPadding: 0

                    onAccepted: root.window.accept()
                    onRejected: root.window.reject()

                    Repeater {
                        model: root.actions
                        delegate: QQC2.Button {
                            action: modelData
                        }
                    }
                }
            }
        }
    }
}
