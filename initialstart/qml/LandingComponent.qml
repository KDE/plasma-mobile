// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: root

    readonly property real scaleStart: 1.4
    readonly property real scaleLanding: 1.2
    readonly property real scaleSteps: 1

    signal requestNextPage()

    function returnToLanding() {
        backgroundImage.scale = scaleLanding;
        contentOpacityAnim.to = 1;
        contentOpacityAnim.restart();
    }

    property real contentOpacity: 0
    NumberAnimation on contentOpacity {
        id: contentOpacityAnim
        running: true
        duration: 1000
        to: 1

        // shorten animation after initial run
        onFinished: duration = 200
    }

    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "qrc:/assets/background.png"
        fillMode: Image.PreserveAspectCrop

        opacity: 0

        NumberAnimation on opacity {
            running: true
            duration: 400
            to: 1
            easing.type: Easing.InOutQuad
        }

        // zoom animation
        scale: scaleStart
        Component.onCompleted: scale = scaleLanding

        Behavior on scale {
            NumberAnimation {
                duration: 2000
                easing.type: Easing.OutExpo
            }
        }

        // darken image slightly
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.3)
        }
    }

    ColumnLayout {
        opacity: root.contentOpacity
        spacing: Kirigami.Units.largeSpacing

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Kirigami.Units.gridUnit * 4
        anchors.rightMargin: Kirigami.Units.gridUnit * 4

        Label {
            Layout.fillWidth: true

            text: i18n("Welcome to <b>Plasma</b>")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap

            font.pointSize: 18
            color: "white"
        }
    }

    Button {
        id: button
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: Kirigami.Units.gridUnit

        topPadding: Kirigami.Units.largeSpacing
        bottomPadding: Kirigami.Units.largeSpacing
        leftPadding: Kirigami.Units.gridUnit
        rightPadding: Kirigami.Units.gridUnit

        opacity: root.contentOpacity
        text: i18n("Next")
        icon.name: "go-next-symbolic"

        onClicked: {
            backgroundImage.scale = scaleSteps;
            contentOpacityAnim.to = 0;
            contentOpacityAnim.restart();
            root.requestNextPage()
        }
    }
}
