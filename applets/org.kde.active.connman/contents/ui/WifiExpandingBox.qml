/*
* Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1 as Labs
import MeeGo.Settings 0.1
import MeeGo.Connman 0.1
import MeeGo.Components 0.1 as MeeGo

import "helper.js" as WifiHelper

MeeGo.ExpandingBox {
    id: container

    property int containerHeight: 80
    height: containerHeight

    //expandedHeight: detailsItem.height
    property NetworkListModel listModel: null
    property QtObject networkItem: null
    property Item page: null
    property int currentIndex
    property string ssid: ""
    property string status: ""
    property int statusint: 0
    property string ipaddy: ""
    property string subnet: ""
    property string gateway: ""
    property string dns: ""
    property string hwaddy: ""
    property string security: ""
    property string method: ""
    property variant nameservers: []

    /// TODO FIXME: this is bad but connman doesn't currently expose a property to indicate whether
    /// a service is the default route or not:
    property bool defaultRoute: false

    property bool finished: false

    property variant signalIndicatorIcons: ["wifi-signal-weak", "wifi-signal-good", "wifi-signal-strong",
        "wifi-signal-weak-connected", "wifi-signal-good-connected", "wifi-signal-strong-connected",
        "wifi-secure-signal-weak", "wifi-secure-signal-good", "wifi-secure-signal-strong",
        "wifi-secure-signal-weak-connected", "wifi-secure-signal-good-connected", "wifi-secure-signal-strong-connected"]

    property int signalIndicatorIconIndex: getSignalIndicatorIconIndex()

    function getSignalIndicatorIconIndex() {
        var index = 0;

        //Caclulates index offsets
        index += container.statusint < NetworkItemModel.StateReady ? 0:3
        index += container.security == "" || container.security == "none" ? 0:6
        index += container.networkItem.strength <= 0 ||container.networkItem.strength > 100 ? 0 : Math.ceil(container.networkItem.strength/100 * 3) - 1

        if (index < signalIndicatorIcons.length)
            return index;
        else
            return 0;
    }

    MeeGo.Theme {
        id: theme
    }

    Component.onCompleted: {
        WifiHelper.connmanSecurityType["wpa"] = qsTr("WPA");
        WifiHelper.connmanSecurityType["rsn"] = qsTr("WPA2");
        WifiHelper.connmanSecurityType["wep"] = qsTr("WEP");
        WifiHelper.connmanSecurityType["ieee8021x"] = qsTr("RADIUS");
        WifiHelper.connmanSecurityType["psk"] = qsTr("WPA2");
        WifiHelper.connmanSecurityType["none"] = "";

        WifiHelper.IPv4Type["dhcp"] = qsTr("DHCP")
        WifiHelper.IPv4Type["static"] = qsTr("Static")

        finished = true;
    }

    onSecurityChanged: {
        //securityText.text = container.connmanArray[container.security]
    }

    Row {
        id: headerArea
        spacing: 8
        anchors.top:  parent.top       
        height: container.containerHeight
        anchors.left: parent.left
        anchors.leftMargin: 20

        Image {
            id: checkbox
            anchors.verticalCenter: parent.verticalCenter
            source:  "image://themedimage/images/btn_tickbox_dn"
            visible:  container.defaultRoute
        }

        Rectangle {
            id: checkboxFiller
            width:  checkbox.width
            height: checkbox.height
            //anchors.verticalCenter: parent.verticalCenter
            color: "transparent"
            visible:  !checkbox.visible
        }


        Image {
            id: signalIndicator
            anchors.verticalCenter: parent.verticalCenter
            source: {
                if(networkItem.type == "wifi" || networkItem.type == "cellular")
                    return "image://themedimage/icons/settings/" + signalIndicatorIcons[signalIndicatorIconIndex]
                else return "image://themedimage/icons/settings/wifi-signal-strong-connected"
            }
        }

        Column {
            id: textLabelColumn
            spacing: 5
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            Text {
                id: mainText
                text: status == "" ? ssid:(ssid + " - " + status)
                font.pixelSize: theme.fontPixelSizeNormal
                color: theme.fontColorNormal
                width:  container.width - 40
                elide: Text.ElideRight
            }

            Text {
                id: securityText
                text: finished ? WifiHelper.connmanSecurityType[container.security] : ""
                font.pixelSize: theme.fontPixelSizeNormal
                color: theme.fontColorNormal
                visible: text != ""
                width: parent.width
                elide: Text.ElideRight
            }
        }
    }




    onStatusintChanged: {

        if(statusint == NetworkItemModel.StateIdle) {
            status = ""

        }
        else if(statusint == NetworkItemModel.StateFailure) {
            status = qsTr("Failed to Connect")
        }
        else if(statusint == NetworkItemModel.StateAssociation) {
            status = qsTr("Associating")

        }
        else if(statusint == NetworkItemModel.StateConfiguration) {
            status = qsTr("Configuring")

        }
        else if(statusint == NetworkItemModel.StateReady) {
            status = qsTr("Connected")

        }
        else if(statusint == NetworkItemModel.StateOnline) {
            status = qsTr("Connected")
        }
        else {
            console.log("state type: " + statusint + "==" + NetworkItemModel.StateIdle)
        }

        if(statusint == NetworkItemModel.StateIdle || statusint == NetworkItemModel.StateFailure ) {
            detailsComponent = passwordArea
        }
        else if(statusint == NetworkItemModel.StateReady || statusint == NetworkItemModel.StateOnline) {
            detailsComponent = detailsArea
            expanded = false
        }
        else if(statusint == NetworkItemModel.StateAssociation || statusint == NetworkItemModel.StateConfiguration){
            detailsComponent = passwordArea
        }

    }

    /*onExpandedChanged: {
    if(expanded && security == "none" && statusint < NetworkItemModel.StateReady) {
			listModel.connectService(ssid, security, "");
		}
	}*/

    Component {
        id: removeConfirmAreaComponent
        Column {
            id: removeConfirmArea
            width: parent.width
            spacing: 10
            Component.onCompleted: {
                console.log("height: !!!! " + height)
            }

            Text {
                text: qsTr("Do you want to remove %1 ?  This action will forget any passwords and you will no longer be automatically connected to %2").arg(networkItem.name).arg(networkItem.name);
                font.pixelSize: theme.fontPixelSizeNormal
                color: theme.fontColorNormal
                wrapMode: Text.WordWrap
                width: parent.width
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                height: childrenRect.height

                MeeGo.Button {
                    id: yesDelete
                    text: qsTr("Yes, Delete")
                    width: removeConfirmArea.width / 2 - 20
                    height: 50
                    onClicked: {
                        networkItem.passphrase=""
                        networkItem.removeService();
                        container.expanded = false;
                        container.detailsComponent = passwordArea
                    }
                }
                MeeGo.Button {
                    id: noSave
                    text: qsTr("No, Save")
                    width: removeConfirmArea.width / 2 - 20
                    height: 50
                    onClicked: {
                        container.expanded = false;
                        container.detailsComponent = detailsArea
                    }
                }
            }
        }
    }

    Component {
        id: detailsArea
        Grid {
            id: settingsGrid
            spacing: 15
            columns: 2
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right:  parent.right
            anchors.rightMargin: 20
            height: childrenRect.height

            property bool editable: container.networkItem.method != "dhcp" && container.networkItem.type != "cellular"
            property int orientationWidth: parent.width//(settingsGrid.width  / (window.orientation == 1 || window.orientation == 3 ? 3:2)) - settingsGrid.spacing * 2


            MeeGo.Button {
                id: disconnectButton
                text: qsTr("Disconnect")
                height: 50
                width: orientationWidth
                onClicked: {
                    networkItem.disconnectService();
                    container.expanded = false;
                }
            }

            MeeGo.Button {
                id: removeConnection
                text: qsTr("Remove connection")
                height: 50
                width: orientationWidth
                elideText: true
                onClicked: {
                    container.detailsComponent = removeConfirmAreaComponent
                }

            }

            Text {
                id: connectByLabel
                text: qsTr("Connect by:")
                font.pixelSize: theme.fontPixelSizeNormal
                color: theme.fontColorNormal
                width: orientationWidth
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }

            /*MeeGo.DropDown {
                id: dropdown
                width: orientationWidth
                property string method
                visible: container.networkItem.type != "cellular"
                model: finished ? [ WifiHelper.IPv4Type["dhcp"], WifiHelper.IPv4Type["static"] ]: []
                payload: finished ? [ WifiHelper.IPv4Type["dhcp"], WifiHelper.IPv4Type["static"] ]: []
                selectedIndex: finished && networkItem.method == "dhcp" ? 0:1
                replaceDropDownTitle: true
                method: selectedIndex == 0 ? "dhcp":"static"

                Connections {
                    target: networkItem
                    onMethodChanged: {
                        settingsGrid.editable = networkItem.method != "dhcp" && networkItem.type != "cellular"
                        dropdown.selectedIndex = networkItem.method == "dhcp" ? 0:1
                        dropdown.method = dropdown.selectedIndex == 0 ? "dhcp":"static"
                    }
                }
            }*/

            Text {
                width: orientationWidth
                font.pixelSize: theme.fontPixelSizeNormal
                color: theme.fontColorNormal
                text: finished ? WifiHelper.IPv4Type[networkItem.method] : ""
            }

			Text {
				id: ipaddyLabel
				font.pixelSize: theme.fontPixelSizeNormal
				color: theme.fontColorNormal
				text: qsTr("IP Address:")
				width: orientationWidth
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			}

			Text {
				font.pixelSize: theme.fontPixelSizeNormal
				color: theme.fontColorNormal
				text: container.ipaddy
				visible:  !editable
				width: orientationWidth
			}

			MeeGo.TextEntry {
				id: ipaddyEdit
				width: orientationWidth
				text: container.ipaddy
				visible: editable
				//textInput.inputMask: "000.000.000.000;_"
			}

			Text {
				font.pixelSize: theme.fontPixelSizeNormal
				color: theme.fontColorNormal
				id: subnetMaskLabel
				text: qsTr("Subnet mask:")
				width: orientationWidth
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			}

			Text {
				font.pixelSize: theme.fontPixelSizeNormal
				color: theme.fontColorNormal
				text: container.subnet
				visible:  !editable
				width: orientationWidth
			}

			MeeGo.TextEntry {
				id: subnetEdit
				width: orientationWidth
				text: container.subnet
				visible: editable
				//textInput.inputMask: "000.000.000.000;_"
			}
			Text {
				id: gatewayLabel
				text: qsTr("Gateway")
				font.pixelSize: theme.fontPixelSizeNormal
				color: theme.fontColorNormal
				width: orientationWidth
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			}

			Text {
				text: container.gateway
				font.pixelSize: theme.fontPixelSizeNormal
				color: theme.fontColorNormal
				visible:  !editable
				width: orientationWidth
			}

			MeeGo.TextEntry {
				id: gatewayEdit
				width: orientationWidth
				text: container.gateway
				visible: editable
				//textInput.inputMask: "000.000.000.000;_"
			}
			Text {
				id: dnsLabel
				font.pixelSize: theme.fontPixelSizeNormal
				color: theme.fontColorNormal
				text: qsTr("DNS:")
				width: orientationWidth
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			}
			Grid {
				id: nameserverstextedit
				width: parent.width
				//height: 20
				columns: 2
				Repeater {
					model: container.nameservers
					delegate: Text {
						width: orientationWidth
						text: modelData
						font.pixelSize: theme.fontPixelSizeNormal
						color: theme.fontColorNormal
					}
				}

			}
			Text {
				id: hwaddyLabel
				text: qsTr("Hardware address:")
				font.pixelSize: theme.fontPixelSizeNormal
				color: theme.fontColorNormal
				visible: container.networkItem.type != "cellular"
				width: orientationWidth
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			}

			Text {
				font.pixelSize: theme.fontPixelSizeNormal
				color: theme.fontColorNormal
				width: orientationWidth
				text: container.hwaddy
				visible: container.networkItem.type != "cellular"
			}

			Labs.GConfItem {

				id: connectionsHacksGconf
				defaultValue: false
				key: "/meego/ux/settings/connectionshacks"
			}

			Text {
				id: securityLabel
				visible: connectionsHacksGconf.value
				font.pixelSize: theme.fontPixelSizeNormal
				color: theme.fontColorNormal
				text: qsTr("Security: ")
				width: orientationWidth
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			}
			Text {
				visible: connectionsHacksGconf.value
				width: orientationWidth
				font.pixelSize: theme.fontPixelSizeNormal
				color: theme.fontColorNormal
				text: WifiHelper.connmanSecurityType[container.security]
			}

			Text {
				id: strengthLabel
				font.pixelSize: theme.fontPixelSizeNormal
				color: theme.fontColorNormal
				visible: connectionsHacksGconf.value
				width: orientationWidth
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
				text: qsTr("Strength: ")
			}
			Text {
				font.pixelSize: theme.fontPixelSizeNormal
				color: theme.fontColorNormal
				visible: connectionsHacksGconf.value
				width: orientationWidth
				text: container.networkItem.strength
			}

			MeeGo.Button {
				id: applyButton
				text: qsTr("Apply")
				elideText: true
				height: 50
				width: orientationWidth
				onClicked: {
					networkItem.method = dropdown.method
					networkItem.ipaddress = ipaddyEdit.text
					networkItem.netmask = subnetEdit.text
					networkItem.gateway = gatewayEdit.text
				}
			}

			MeeGo.Button {
				id: cancelButton
				text: qsTr("Cancel")
				height: 50
				width: orientationWidth
				elideText: true
				onClicked: {
					container.expanded = false
					dropdown.selectedIndex = networkItem.method == "dhcp" ? 0:1
					ipaddyEdit.text = networkItem.ipaddress
					subnetEdit.text = networkItem.netmask
					gatewayEdit.text = networkItem.gateway
				}
			}
		}

	}

    Component {
        id: passwordArea
        Item {
            id: passwordGrid
            anchors.right: parent.right
            anchors.left:  parent.left
            anchors.margins: 20
            height: childrenRect.height

            property bool passwordRequired: container.networkItem.type == "wifi" && container.security != "none" && container.security != "ieee8021x"

            Column {
                width:  parent.width
                spacing: 10
                Row {
                    height: childrenRect.height
                    spacing: 10

                    MeeGo.TextEntry {
                        id: passwordTextInput
                        //textInput.echoMode: TextInput.Normal
                        visible: passwordGrid.passwordRequired
                        defaultText: qsTr("Type password here")
                        width: passwordGrid.width / 2
                        text: container.networkItem.passphrase
                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText

                    }

                    MeeGo.Button {
                        id: setupButton
                        height: 50

                        text:  qsTr("Setup")
                        visible: container.networkItem.type == "cellular"
                        onClicked: {
                           addPage(cellularSettings)
                        }
                    }

                    MeeGo.Button {
                        id: connectButtonOfAwesome
                        height: 50
                        property bool shouldBeActive: container.statusint != NetworkItemModel.StateAssociation &&
                                                      container.statusint != NetworkItemModel.StateConfiguration
                        active: shouldBeActive
                        enabled: shouldBeActive
                        text: qsTr("Connect")
                        onClicked: {
                            if(container.networkItem.type == "wifi") {
                                container.networkItem.passphrase = passwordTextInput.text;
                                container.listModel.connectService(container.ssid, container.security, passwordTextInput.text)
                            }
                            else {
                                container.networkItem.connectService();
                            }
                        }
                    }
                }

                Row {
                    height: childrenRect.height
                    spacing: 10
                    MeeGo.CheckBox {
                        id: showPasswordCheckbox
                        visible: passwordGrid.passwordRequired
                        isChecked: true
                        onIsCheckedChanged: {
                            if(isChecked) passwordTextInput.textInput.echoMode = TextInput.Normal
                            else passwordTextInput.textInput.echoMode = TextInput.Password
                        }
                    }

                    Text {
                        visible: passwordGrid.passwordRequired
                        text: qsTr("Show password")
                        font.pixelSize: 14//theme_fontPixelSizeLarge
                        width: 100
                        height: showPasswordCheckbox.height
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
		}
    }

    Component {
        id: cellularSettings
        CellularSettings {
            networkItem: container.networkItem
        }
    }
}



