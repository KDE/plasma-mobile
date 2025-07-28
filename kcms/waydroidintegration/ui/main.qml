/*
 * SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kirigamiaddons.formcard 1.0 as FormCard
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell.waydroidintegrationplugin as AIP

KCM.SimpleKCM {
    id: root

    title: i18n("Waydroid Integration")

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    ColumnLayout {
        visible: AIP.WaydroidState.errorTitle === "" && AIP.WaydroidState.status == AIP.WaydroidState.NotSupported
        anchors.centerIn: parent
        spacing: Kirigami.Units.largeSpacing

        QQC2.Label {
            text: i18n("Waydroid is not installed")
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter

        }

        PC3.Button {
            text: i18n("Check installation")
            Layout.alignment: Qt.AlignHCenter
            onClicked: AIP.WaydroidState.refreshSupportsInfo()
        }
    }

    WaydroidInitialConfigurationForm {
        visible: AIP.WaydroidState.errorTitle === "" && AIP.WaydroidState.status == AIP.WaydroidState.NotInitialized
    }

    WaydroidDownloadStatus {
        id: downloadStatus
        visible: AIP.WaydroidState.errorTitle === "" && AIP.WaydroidState.status == AIP.WaydroidState.Initializing
        text: i18n("Downloading Android and vendor images.\nIt can take a few minutes.")

        Connections {
            target: AIP.WaydroidState

            function onDownloadStatusChanged(downloaded, total, speed) {
                downloadStatus.downloaded = downloaded
                downloadStatus.total = total
                downloadStatus.speed = speed
            }
        }
    }

    WaydroidLoader {
        visible: AIP.WaydroidState.errorTitle === "" && AIP.WaydroidState.status == AIP.WaydroidState.Resetting
        text: i18n("Waydroid is resetting.\nIt can take a few seconds.")
    }

    ColumnLayout {
        visible: AIP.WaydroidState.errorTitle === "" && AIP.WaydroidState.status == AIP.WaydroidState.Initialized && AIP.WaydroidState.sessionStatus == AIP.WaydroidState.SessionStopped
        anchors.centerIn: parent
        spacing: Kirigami.Units.largeSpacing

        QQC2.Label {
            text: i18n("The Waydroid session is not running.")
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
        }

        PC3.Button {
            text: i18n("Start the session")
            Layout.alignment: Qt.AlignHCenter
            onClicked: AIP.WaydroidState.startSessionQml()
        }
    }

    WaydroidLoader {
        visible: AIP.WaydroidState.errorTitle === "" && AIP.WaydroidState.status == AIP.WaydroidState.Initialized && AIP.WaydroidState.sessionStatus == AIP.WaydroidState.SessionStarting
        text: i18n("Waydroid session is starting.\nIt can take a few seconds.")
    }

    WaydroidConfigurationForm {
        visible: AIP.WaydroidState.errorTitle === "" && AIP.WaydroidState.status == AIP.WaydroidState.Initialized && AIP.WaydroidState.sessionStatus == AIP.WaydroidState.SessionRunning
    }

    ColumnLayout {
        visible: AIP.WaydroidState.errorTitle !== ""
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent
        anchors.leftMargin: Kirigami.Units.largeSpacing
        anchors.right: parent
        anchors.rightMargin: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        QQC2.Label {
            text: AIP.WaydroidState.errorTitle
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
        }

        QQC2.TextArea {
            visible: AIP.WaydroidState.errorMessage !== ""
            text: AIP.WaydroidState.errorMessage
            readOnly: true
            wrapMode: TextEdit.Wrap
            Layout.fillWidth: true
        }

        PC3.Button {
            text: i18n("Go back")
            Layout.alignment: Qt.AlignHCenter
            onClicked: AIP.WaydroidState.resetError()
        }
    }
}