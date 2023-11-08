// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.12 as Controls
import org.kde.kirigami 2.12 as Kirigami
import cellularnetworkkcm 1.0

Kirigami.ScrollablePage {
    id: apnlist
    title: i18n("APNs")
    
    property Modem modem
    
    ListView {
        id: profileListView
        model: modem.profiles
     
        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Kirigami.Units.largeSpacing
            visible: profileListView.count === 0
            text: i18n("No APNs configured")
            icon.name: "globe"
            
            helpfulAction: Kirigami.Action {
                icon.name: "list-add"
                text: i18n("Add Connection")
                onTriggered: {
                    profileDialog.profile = null;
                    profileDialog.open();
                }
            }
        }
        
        EditProfileDialog {
            id: profileDialog
            modem: apnlist.modem
            profile: null
            pageWidth: apnlist.width
        }
        
        header: ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0
            
            MessagesList {
                id: messagesList
                visible: count != 0
                Layout.fillWidth: true
                Layout.margins: Kirigami.Units.largeSpacing
                model: kcm.messages
            }
            
            Kirigami.InlineMessage {
                id: cannotFindWarning
                Layout.margins: visible ? Kirigami.Units.largeSpacing : 0
                Layout.topMargin: visible && !messagesList.visible ? Kirigami.Units.largeSpacing : 0
                Layout.fillWidth: true
                
                visible: false
                type: Kirigami.MessageType.Warning
                showCloseButton: true
                text: qsTr("Unable to autodetect connection settings for your carrier. Please find your carrier's APN settings by either contacting support or searching online.")
                
                Connections {
                    target: modem
                    function onCouldNotAutodetectSettings() {
                        cannotFindWarning.visible = true;
                    }
                }
            }
            
            Kirigami.SwipeListItem {
                Layout.fillWidth: true
                visible: profileListView.count !== 0
                onClicked: {
                    profileDialog.profile = null;
                    profileDialog.open();
                }
                
                contentItem: Row {
                    spacing: Kirigami.Units.smallSpacing
                    Kirigami.Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        source: "list-add"
                        height: Kirigami.Units.gridUnit * 1.5
                        width: height
                    }
                    Kirigami.Heading {
                        level: 3
                        anchors.verticalCenter: parent.verticalCenter
                        Layout.alignment: Qt.AlignLeft
                        text: i18n("Add APN")
                    }
                }
            }
            
            Kirigami.SwipeListItem {
                Layout.fillWidth: true
                onClicked: {
                    modem.addDetectedProfileSettings();
                }
                
                contentItem: Row {
                    spacing: Kirigami.Units.smallSpacing
                    Kirigami.Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        source: "list-add"
                        height: Kirigami.Units.gridUnit * 1.5
                        width: height
                    }
                    Kirigami.Heading {
                        level: 3
                        anchors.verticalCenter: parent.verticalCenter
                        Layout.alignment: Qt.AlignLeft
                        text: i18n("Autodetect APN")
                    }
                }
            }
        }
        
        delegate: Kirigami.SwipeListItem {
            onClicked: modem.activateProfile(modelData.connectionUni)
            
            actions: [
                Kirigami.Action {
                    icon.name: "entry-edit"
                    text: i18n("Edit")
                    onTriggered: {
                        profileDialog.profile = modelData;
                        profileDialog.open();
                    }
                },
                Kirigami.Action {
                    icon.name: "delete"
                    text: i18n("Delete")
                    onTriggered: modem.removeProfile(modelData.connectionUni)
                }
            ]
            
            contentItem: RowLayout {
                Layout.fillWidth: true
                
                Controls.RadioButton {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    checked: modem.activeConnectionUni == modelData.connectionUni
                    onClicked: {
                        if (!checked) {
                            modem.activateProfile(modelData.connectionUni);
                        }
                        
                        // reapply binding
                        checked = Qt.binding(() => { return modem.activeConnectionUni == modelData.connectionUni });
                    }
                }
                
                ColumnLayout {
                    Layout.alignment: Qt.AlignLeft
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing
                    
                    Kirigami.Heading {
                        Layout.fillWidth: true
                        level: 3
                        text: modelData.name
                    }
                    Controls.Label {
                        Layout.fillWidth: true
                        text: modelData.apn
                    }
                }
            }
        }
    }
}
