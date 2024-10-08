// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtCore
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.mobileinitialstart.initialstart
import org.kde.plasma.mobileinitialstart.prepare 1.0 as Prepare

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

        readonly property bool isLandscape: width >= height

        source: {
            // default wallpaper background
            const imgFile = isLandscape ? '2560x1440.png' : '1080x1920.png';
            const lightWallpaperFolder = 'wallpapers/Next/contents/images/';
            const darkWallpaperFolder = 'wallpapers/Next/contents/images_dark/';

            const wallpaperUrl = StandardPaths.locate(
                StandardPaths.GenericDataLocation,
                (Prepare.PrepareUtil.usingDarkTheme ? darkWallpaperFolder : lightWallpaperFolder) + imgFile
            );

            if (!wallpaperUrl) {
                return StandardPaths.locate(StandardPaths.GenericDataLocation, lightWallpaperFolder + imgFile);
            }
            return wallpaperUrl;
        }
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

            text: i18n("Welcome to<br/><b>Plasma Mobile</b>")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap

            font.pointSize: 18
            color: "white"
        }

    }

    ColumnLayout {
        opacity: root.contentOpacity
        spacing: Kirigami.Units.largeSpacing

	anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Kirigami.Units.gridUnit * 4
            rightMargin: Kirigami.Units.gridUnit * 4
            bottomMargin: Kirigami.Units.gridUnit * 2
        }


        Kirigami.Heading {
            Layout.fillWidth: true
            text: i18n("Powered by<br/><b>%1</b>", InitialStartUtil.distroName)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap

            level: 5
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
        leftPadding: Kirigami.Units.largeSpacing
        rightPadding: Kirigami.Units.largeSpacing

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

