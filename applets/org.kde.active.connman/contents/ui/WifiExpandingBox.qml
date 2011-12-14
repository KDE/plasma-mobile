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
import org.kde.plasma.components 0.1 as PlasmaComponents

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
        id: meegoTheme
    }

    Component.onCompleted: {
        WifiHelper.connmanSecurityType["wpa"] = i18n("WPA");
        WifiHelper.connmanSecurityType["rsn"] = i18n("WPA2");
        WifiHelper.connmanSecurityType["wep"] = i18n("WEP");
        WifiHelper.connmanSecurityType["ieee8021x"] = i18n("RADIUS");
        WifiHelper.connmanSecurityType["psk"] = i18n("WPA2");
        WifiHelper.connmanSecurityType["none"] = "";

        WifiHelper.IPv4Type["dhcp"] = i18n("DHCP")
        WifiHelper.IPv4Type["static"] = i18n("Static")

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
                font.pixelSize: meegoTheme.fontPixelSizeNormal
                color: meegoTheme.fontColorNormal
                width:  container.width - 40
                elide: Text.ElideRight
            }

            Text {
                id: securityText
                text: finished ? WifiHelper.connmanSecurityType[container.security] : ""
                font.pixelSize: meegoTheme.fontPixelSizeNormal
                color: meegoTheme.fontColorNormal
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
            status = i18n("Failed to Connect")
        }
        else if(statusint == NetworkItemModel.StateAssociation) {
            status = i18n("Associating")

        }
        else if(statusint == NetworkItemModel.StateConfiguration) {
            status = i18n("Configuring")

        }
        else if(statusint == NetworkItemModel.StateReady) {
            status = i18n("Connected")

        }
        else if(statusint == NetworkItemModel.StateOnline) {
            status = i18n("Connected")
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
                text: i18n("Do you want to remove %1 ?  This action will forget any passwords and you will no longer be automatically connected to %2").arg(networkItem.name).arg(networkItem.name);
                font.pixelSize: meegoTheme.fontPixelSizeNormal
                color: meegoTheme.fontColorNormal
                wrapMode: Text.WordWrap
                width: parent.width
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                height: childrenRect.height

                PlasmaComponents.Button {
                    id: yesDelete
                    text: i18n("Yes, Delete")
                    width: removeConfirmArea.width / 2 - 20
                    height: 50
                    onClicked: {
                        networkItem.passphrase=""
                        networkItem.removeService();
                        container.expanded = false;
                        container.detailsComponent = passwordArea
                    }
                }
                PlasmaComponents.Button {
                    id: noSave
                    text: i18n("No, Save")
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


            PlasmaComponents.Button {
                id: disconnectButton
                text: i18n("Disconnect")
                height: 50
                onClicked: {
                    networkItem.disconnectService();
                    container.expanded = false;
                }
            }

            PlasmaComponents.Button {
                id: removeConnection
                text: i18n("Remove connection")
                height: 50
                onClicked: {
                    container.detailsComponent = removeConfirmAreaComponent
                }

            }

            Text {
                id: connectByLabel
                text: i18n("Connect by:")
                font.pixelSize: meegoTheme.fontPixelSizeNormal
                color: meegoTheme.fontColorNormal
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }

            /*MeeGo.DropDown {
                id: dropdown
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
                font.pixelSize: meegoTheme.fontPixelSizeNormal
                color: meegoTheme.fontColorNormal
                text: finished ? WifiHelper.IPv4Type[networkItem.method] : ""
            }

			Text {
				id: ipaddyLabel
				font.pixelSize: meegoTheme.fontPixelSizeNormal
				color: meegoTheme.fontColorNormal
				text: i18n("IP Address:")
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			}

			Text {
				font.pixelSize: meegoTheme.fontPixelSizeNormal
				color: meegoTheme.fontColorNormal
				text: container.ipaddy
				visible:  !editable
			}

			PlasmaComponents.TextField {
				id: ipaddyEdit
				text: container.ipaddy
				visible: editable
				//textInput.inputMask: "000.000.000.000;_"
			}

			Text {
				font.pixelSize: meegoTheme.fontPixelSizeNormal
				color: meegoTheme.fontColorNormal
				id: subnetMaskLabel
				text: i18n("Subnet mask:")
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			}

			Text {
				font.pixelSize: meegoTheme.fontPixelSizeNormal
				color: meegoTheme.fontColorNormal
				text: container.subnet
				visible:  !editable
			}

			PlasmaComponents.TextField {
				id: subnetEdit
				text: container.subnet
				visible: editable
				//textInput.inputMask: "000.000.000.000;_"
			}
			Text {
				id: gatewayLabel
				text: i18n("Gateway")
				font.pixelSize: meegoTheme.fontPixelSizeNormal
				color: meegoTheme.fontColorNormal
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			}

			Text {
				text: container.gateway
				font.pixelSize: meegoTheme.fontPixelSizeNormal
				color: meegoTheme.fontColorNormal
				visible:  !editable
			}

			PlasmaComponents.TextField {
				id: gatewayEdit
				text: container.gateway
				visible: editable
				//textInput.inputMask: "000.000.000.000;_"
			}
			Text {
				id: dnsLabel
				font.pixelSize: meegoTheme.fontPixelSizeNormal
				color: meegoTheme.fontColorNormal
				text: i18n("DNS:")
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			}
			Grid {
				id: nameserverstextedit
				//height: 20
				columns: 2
				Repeater {
					model: container.nameservers
					delegate: Text {
						text: modelData
						font.pixelSize: meegoTheme.fontPixelSizeNormal
						color: meegoTheme.fontColorNormal
					}
				}

			}
			Text {
				id: hwaddyLabel
				text: i18n("Hardware address:")
				font.pixelSize: meegoTheme.fontPixelSizeNormal
				color: meegoTheme.fontColorNormal
				visible: container.networkItem.type != "cellular"
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			}

			Text {
				font.pixelSize: meegoTheme.fontPixelSizeNormal
				color: meegoTheme.fontColorNormal
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
				font.pixelSize: meegoTheme.fontPixelSizeNormal
				color: meegoTheme.fontColorNormal
				text: i18n("Security: ")
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			}
			Text {
				visible: connectionsHacksGconf.value
				font.pixelSize: meegoTheme.fontPixelSizeNormal
				color: meegoTheme.fontColorNormal
				text: WifiHelper.connmanSecurityType[container.security]
			}

			Text {
				id: strengthLabel
				font.pixelSize: meegoTheme.fontPixelSizeNormal
				color: meegoTheme.fontColorNormal
				visible: connectionsHacksGconf.value
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
				text: i18n("Strength: ")
			}
			Text {
				font.pixelSize: meegoTheme.fontPixelSizeNormal
				color: meegoTheme.fontColorNormal
				visible: connectionsHacksGconf.value
				text: container.networkItem.strength
			}

			PlasmaComponents.Button {
				id: applyButton
				text: i18n("Apply")
				height: 50
				onClicked: {
					networkItem.method = dropdown.method
					networkItem.ipaddress = ipaddyEdit.text
					networkItem.netmask = subnetEdit.text
					networkItem.gateway = gatewayEdit.text
				}
			}

			PlasmaComponents.Button {
				id: cancelButton
				text: i18n("Cancel")
				height: 50
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

                    PlasmaComponents.TextField {
                        id: passwordTextInput
                        //textInput.echoMode: TextInput.Normal
                        visible: passwordGrid.passwordRequired
                        placeholderText: i18n("Type password here")
                        width: passwordGrid.width / 2
                        text: container.networkItem.passphrase
                    }

                    PlasmaComponents.Button {
                        id: setupButton
                        height: 50

                        text:  i18n("Setup")
                        visible: container.networkItem.type == "cellular"
                        onClicked: {
                           addPage(cellularSettings)
                        }
                    }

                    PlasmaComponents.Button {
                        id: connectButtonOfAwesome
                        height: 50
                        property bool shouldBeActive: container.statusint != NetworkItemModel.StateAssociation &&
                                                      container.statusint != NetworkItemModel.StateConfiguration
                        enabled: shouldBeActive
                        text: i18n("Connect")
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
                    PlasmaComponents.CheckBox {
                        id: showPasswordCheckbox
                        visible: passwordGrid.passwordRequired
                        checked: true
                        onCheckedChanged: {
                            if(checked) passwordTextInput.textInput.echoMode = TextInput.Normal
                            else passwordTextInput.textInput.echoMode = TextInput.Password
                        }
                    }

                    Text {
                        visible: passwordGrid.passwordRequired
                        text: i18n("Show password")
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



