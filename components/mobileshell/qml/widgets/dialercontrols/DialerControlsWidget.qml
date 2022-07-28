/*
 *  SPDX-FileCopyrightText: 2022 Alexey Andreyev <aa13q@ya.ru>
 *
 *  SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.telephony 1.0

import "../../components" as Components

/**
 * Embeddable component that provides phone dialer control.
 */
Item {
    id: root
    visible: ActiveCallModel.active
    
    readonly property real padding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
    readonly property real contentHeight: PlasmaCore.Units.gridUnit * 2 + PlasmaCore.Units.smallSpacing
    implicitHeight: visible ? padding * 2 + contentHeight : 0

    function selectModem() {
        const deviceUniList = DeviceUtils.deviceUniList()
        if (deviceUniList.length === 0) {
            console.warn("Modem devices not found")
            return ""
        }

        if (deviceUniList.length === 1) {
            return deviceUniList[0]
        }
        console.log("TODO: select device uni")
    }

    function activeDeviceUni() {
        return selectModem()
    }

    function activeCallUni() {
        return ActiveCallModel.activeCallUni()
    }

    // page indicator
    RowLayout {
        z: 1
        visible: view.count > 1
        spacing: Kirigami.Units.smallSpacing
        anchors.bottomMargin: Kirigami.Units.smallSpacing * 2
        anchors.bottom: view.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        
        Repeater {
            model: view.count
            delegate: Rectangle {
                width: Kirigami.Units.smallSpacing
                height: Kirigami.Units.smallSpacing
                radius: width / 2
                color: Qt.rgba(255, 255, 255, view.currentIndex === model.index ? 1 : 0.5)
            }
        }
    }
    
    // list of active calls
    QQC2.SwipeView {
        id: view
        clip: true

        anchors.fill: parent

        Repeater {
            model: ActiveCallModel

            delegate: Loader {
                active: ActiveCallModel.active

                asynchronous: true

                sourceComponent: Components.BaseItem {
                    id: dialerItem

                    property string source

                    padding: root.padding
                    implicitHeight: root.contentHeight + root.padding * 2
                    implicitWidth: root.width

                    contentItem: PlasmaCore.ColorScope {
                        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                        width: dialerItem.width - dialerItem.leftPadding - dialerItem.rightPadding

                        RowLayout {
                            id: controlsRow
                            width: parent.width
                            height: parent.height
                            spacing: 0

                            Image {
                                id: contactPicture
                                Layout.preferredWidth: height
                                Layout.fillHeight: true
                                asynchronous: true
                                fillMode: Image.PreserveAspectFit
                                sourceSize.height: height
                                visible: status === Image.Loading || status === Image.Ready
                            }

                            ColumnLayout {
                                Layout.leftMargin: contactPicture.visible ? Kirigami.Units.largeSpacing : 0
                                Layout.fillWidth: true
                                spacing: Kirigami.Units.smallSpacing

                                Components.MarqueeLabel {
                                    Layout.fillWidth: true

                                    inputText: communicationWith
                                    textFormat: Text.PlainText
                                    font.pointSize: PlasmaCore.Theme.defaultFont.pointSize
                                    color: "white"
                                }

                                Components.MarqueeLabel {
                                    property string contactName: ContactUtils.displayString(model.communicationWith)
                                    Layout.fillWidth: true
                                    visible: contactName !== communicationWith

                                    inputText: contactName
                                    textFormat: Text.PlainText
                                    font.pointSize: PlasmaCore.Theme.defaultFont.pointSize
                                    font.bold: true
                                    color: "white"
                                }
                            }

                            PlasmaComponents3.ToolButton {
                                Layout.fillHeight: true
                                Layout.preferredWidth: height

                                icon.name: "call-start-symbolic"
                                icon.width: PlasmaCore.Units.iconSizes.small
                                icon.height: PlasmaCore.Units.iconSizes.small
                                onClicked: CallUtils.accept(activeDeviceUni(), activeCallUni());
                                Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Accept call")
                            }

                            PlasmaComponents3.ToolButton {
                                Layout.fillHeight: true
                                Layout.preferredWidth: height

                                icon.name:"call-stop-symbolic"
                                icon.width: PlasmaCore.Units.iconSizes.small
                                icon.height: PlasmaCore.Units.iconSizes.small
                                onClicked: CallUtils.hangUp(activeDeviceUni(), activeCallUni());
                                Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Reject call")
                            }
                        }
                    }
                }
            }
        }
    }
}
