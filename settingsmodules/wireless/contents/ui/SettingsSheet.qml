/*
 * Copyright (C) 2013 Robin Burchell <robin+mer@viroteck.net>
 * Copyright (C) 2012 Jolla Ltd. <dmitry.rozhkov@jollamobile.com>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * Neither the name of Nemo Mobile nor the names of its contributors
 *     may be used to endorse or promote products derived from this
 *     software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.components 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import MeeGo.Connman 0.2

Item {
    id: sheet

    property QtObject network

    onNetworkChanged: {
        proxyAutoUrl.checked = ! network.proxyConfig["URL"];
        form.networkName = network.name;
        form.ipv4 = network.ipv4;
        form.nameservers = network.nameservers;
        form.domains = network.domains;
        form.proxy = network.proxy;
        form.proxyConfig = network.proxyConfig;
    }

    RowLayout {
        z: 2
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        Button {
            text: "Accept"
            onClicked: {
                var domains = [],
                    nameservers = [],
                    ipv4,
                    proxyconf,
                    proxy_server_text;

                console.log("Accept");

                // Domains
                if (network.domains.join() !== domainsField.text) {
                    if (domainsField.text) {
                        domains = domainsField.text.split();
                    }
                    console.log("Update Domains: " + domains.join());
                    network.domainsConfig = domains;
                }

                // IPv4
                ipv4 = network.ipv4;
                if (ipv4["Method"] !==  method.state) {
                    ipv4["Method"] = method.state;
                    if (method.state === "manual") {
                        ipv4["Address"] = address.text
                        ipv4["Netmask"] = netmask.text
                        ipv4["Gateway"] = gateway.text
                    }
                    network.ipv4Config = ipv4;
                } else if (network.ipv4["Method"] === "manual") {
                    if (ipv4["Address"] !== address.text ||
                        ipv4["Netmask"] !== netmask.text ||
                        ipv4["Gateway"] !== gateway.text) {

                        ipv4["Address"] = address.text
                        ipv4["Netmask"] = netmask.text
                        ipv4["Gateway"] = gateway.text
                        network.ipv4Config = ipv4;
                    }
                }

                // Nameservers
                if (method.state === "manual" &&
                    network.nameserversConfig.join() !== nameserversField.text) {
                    nameservers = nameserversField.text.split();
                    network.nameserversConfig = nameservers;
                }

                // Proxy
                proxyconf = network.proxyConfig;
                if (proxyconf["Method"] !== proxy.state) {
                    proxyconf["Method"] = proxy.state;
                    if (proxy.state === "auto") {
                        proxyconf["URL"] = proxyurl.text;
                    } else if (proxy.state === "manual") {
                        proxyconf["Servers"] = [proxyserver.text + ":" + proxyport.text];
                    }
                    network.proxyConfig = proxyconf;
                } else if (proxy.state === "manual") {
                    proxy_server_text = proxyserver.text + ":" + proxyport.text;
                    if (proxyconf["Servers"].length === 0 || proxyconf["Servers"][0] !== proxy_server_text) {
                        proxyconf["Servers"] = [proxy_server_text];
                        network.proxyConfig = proxyconf;
                    }
                } else if (proxy.state == "auto") {
                    if (proxyAutoUrl.checked && proxyconf["URL"]) {
                        // empty URL to use the provided by DHCP
                        proxyconf["URL"] = "";
                        network.proxyConfig = proxyconf;
                    } else if (! proxyAutoUrl.checked && proxyurl.text !== proxyconf["URL"]) {
                        // manual URL is used and it needs update
                        proxyconf["URL"] = proxyurl.text;
                        network.proxyConfig = proxyconf;
                    }
                }

                stackView.pop();
            }
        }
        Button {
            text: "Cancel"
            onClicked: {
                stackView.pop();
            }
        }
    }

    PlasmaExtras.ScrollArea {
        anchors.fill: parent
        Flickable {
            id: form
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.topMargin: 10
            //contentWidth: mainColumn.width
            contentHeight: mainColumn.height
            flickableDirection: Flickable.VerticalFlick

            property string networkName: "Error"
            property variant ipv4: {"Method": "manual", "Address": "", "Netmask": "", "Gateway": ""}
            property variant nameservers: []
            property variant domains: []
            property variant proxy: {"Method": "auto", "URL": ""}
            property variant proxyConfig: {"Servers": []}

            Column {
                id: mainColumn
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 10

                Row {
                    anchors { left: parent.left; right: parent.right }

                    PlasmaCore.IconItem {
                        height: units.iconSizes.large
                        width: height
                        source: {
                            var strength = form.strength;
                            var str_id = 0;

                            if (strength >= 100) {
                                str_id = 100;
                            } else if (strength >= 80) {
                                str_id = 80;
                            } else if (strength >= 60) {
                                str_id = 60;
                            } else if (strength >= 40) {
                                str_id = 40;
                            } else if (strength >= 20) {
                                str_id = 20;
                            }
                            return "network-wireless-" + str_id;
                        }
                    }

                    PlasmaExtras.Heading {
                        text: form.networkName
                    }
                }

                Item {
                    anchors { left: parent.left; right: parent.right }
                    height: 100

                    Button {
                        id: disconnectButton
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }
                        text: "Disconnect"
                        onClicked: {
                            console.log("Disconnect clicked");
                            network.requestDisconnect();
                            stackView.pop();
                        }
                    }
                }

                Column {
                    anchors { left: parent.left; right: parent.right }
                    Text {
                        anchors { left: parent.left; leftMargin: 20 }
                        text: "Method"
                    }
                    ButtonRow {
                        id: method
                        anchors { left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
                        state: form.ipv4.Method

                        states: [
                            State {
                                name: "dhcp"
                                PropertyChanges {target: networkInfo; visible: true}
                                PropertyChanges {target: networkFields; visible: false}
                            },
                            State {
                                name: "manual"
                                PropertyChanges {target: networkInfo; visible: false}
                                PropertyChanges {target: networkFields; visible: true}
                            }
                        ]

                        Button {
                            text: "DHCP"
                            checked: form.ipv4.Method == "dhcp"
                            onClicked: {
                                method.state = "dhcp"
                            }
                        }
                        Button {
                            text: "Static"
                            checked: form.ipv4.Method == "manual"
                            onClicked: {
                                method.state = "manual"
                            }
                        }
                    }
                }

                Column {
                    id: networkInfo
                    anchors { left: parent.left; right: parent.right }
                    spacing: 50
                    Column {
                        anchors { left: parent.left; right: parent.right }

                        Text {
                            anchors { left: parent.left; leftMargin: 20; }
                            text: "IP address"
                        }
                        Text {
                            anchors { left: parent.left; leftMargin: 20; topMargin: 30 }
                            text: form.ipv4.Address
                        }
                    }
                    Column {
                        anchors { left: parent.left; right: parent.right }

                        Text {
                            anchors { left: parent.left; leftMargin: 20 }
                            text: "Subnet mask"
                        }
                        Text {
                            anchors { left: parent.left; leftMargin: 20; topMargin: 30 }
                            text: form.ipv4.Netmask
                        }
                    }
                    Column {
                        anchors { left: parent.left; right: parent.right }

                        Text {
                            anchors { left: parent.left; leftMargin: 20 }
                            text: "Router"
                        }
                        Text {
                            anchors { left: parent.left; leftMargin: 20; topMargin: 30 }
                            text: form.ipv4.Gateway
                        }
                    }
                    Column {
                        anchors { left: parent.left; right: parent.right }

                        Text {
                            anchors { left: parent.left; leftMargin: 20 }
                            text: "DNS"
                        }
                        Text {
                            anchors { left: parent.left; leftMargin: 20; topMargin: 30 }
                            text: form.nameservers.join()
                        }
                    }

                }

                Item {
                    id: networkFields
                    anchors { left: parent.left; right: parent.right }

                    Column {
                        spacing: 50
                        Column {
                            anchors { left: parent.left; right: parent.right }

                            Text {
                                anchors { left: parent.left; leftMargin: 20 }
                                text: "IP address"
                            }
                            TextField {
                                id: address
                                anchors { left: parent.left; leftMargin: 20; top:parent.top; topMargin: 30 }
                                width: 440
                                text: form.ipv4.Address
                            }
                        }
                        Column {
                            anchors { left: parent.left; right: parent.right }

                            Text {
                                anchors { left: parent.left; leftMargin: 20 }
                                text: "Subnet mask"
                            }
                            TextField {
                                id: netmask
                                anchors { left: parent.left; leftMargin: 20; topMargin: 30 }
                                width: 440
                                text: form.ipv4.Netmask
                            }
                        }
                        Column {
                            anchors { left: parent.left; right: parent.right }

                            Text {
                                anchors { left: parent.left; leftMargin: 20 }
                                text: "Router"
                            }
                            TextField {
                                id: gateway
                                anchors { left: parent.left; leftMargin: 20; topMargin: 30 }
                                width: 440
                                text: form.ipv4.Gateway
                            }
                        }
                        Column {
                            anchors { left: parent.left; right: parent.right }

                            Text {
                                anchors { left: parent.left; leftMargin: 20 }
                                text: "DNS"
                            }
                            TextField {
                                id: nameserversField
                                anchors { left: parent.left; leftMargin: 20; topMargin: 30 }
                                width: 440
                                text: {
                                    var nservs = "";
                                    if (sheet.network) {
                                        nservs = sheet.network.nameserversConfig.join();
                                        return nservs ? nservs : form.nameservers.join();
                                    } else {
                                        return "";
                                    }
                                }
                            }
                        }
                    }
                }

                Column {
                    anchors { left: parent.left; right: parent.right }

                    Text {
                        anchors { left: parent.left; leftMargin: 20 }
                        text: "Search domains"
                    }
                    TextField {
                        id: domainsField
                        anchors { left: parent.left; leftMargin: 20; topMargin: 30 }
                        width: 440
                        text: form.domains.join()
                    }
                }

                Column {
                    anchors { left: parent.left; right: parent.right }
                    Text {
                        anchors { left: parent.left; leftMargin: 20 }
                        text: "HTTP Proxy"
                    }
                    ButtonRow {
                        id: proxy
                        anchors { left: parent.left; right: parent.right; topMargin: 30; leftMargin: 10; rightMargin: 10 }
                        state: form.proxy.Method

                        states: [
                            State {
                                name: "direct"
                                PropertyChanges {target: proxyManualFields; visible: false}
                                PropertyChanges {target: proxyAutoFields; visible: false}
                                PropertyChanges {target: directProxyButton; checked: true}
                                PropertyChanges {target: manualProxyButton; checked: false}
                                PropertyChanges {target: autoProxyButton; checked: false}
                            },
                            State {
                                name: "auto"
                                PropertyChanges {target: proxyManualFields; visible: false}
                                PropertyChanges {target: proxyAutoFields; visible: true}
                                PropertyChanges {target: directProxyButton; checked: false}
                                PropertyChanges {target: manualProxyButton; checked: false}
                                PropertyChanges {target: autoProxyButton; checked: true}
                            },
                            State {
                                name: "manual"
                                PropertyChanges {target: proxyManualFields; visible: true}
                                PropertyChanges {target: proxyAutoFields; visible: false}
                                PropertyChanges {target: directProxyButton; checked: false}
                                PropertyChanges {target: manualProxyButton; checked: true}
                                PropertyChanges {target: autoProxyButton; checked: false}
                            }
                        ]

                        Button {
                            id: directProxyButton
                            text: "Off"
                            onClicked: {
                                proxy.state = "direct"
                            }
                        }
                        Button {
                            id: manualProxyButton
                            text: "Manual"
                            onClicked: {
                                proxy.state = "manual"
                            }
                        }
                        Button {
                            id: autoProxyButton
                            text: "Auto"
                            onClicked: {
                                proxy.state = "auto"
                            }
                        }
                    }
                }

                Column {
                    id: proxyManualFields
                    anchors { left: parent.left; right: parent.right }

                    spacing: 50
                    Column {
                        anchors { left: parent.left; right: parent.right }

                        Text {
                            anchors { left: parent.left; leftMargin: 20 }
                            text: "Server"
                        }
                        TextField {
                            id: proxyserver
                            anchors { left: parent.left; leftMargin: 20; top:parent.top; topMargin: 30 }
                            width: 440
                            text: form.proxyConfig.Servers ? form.proxyConfig.Servers[0].split(":")[0] : ""
                        }
                    }
                    Column {
                        anchors { left: parent.left; right: parent.right }

                        Text {
                            anchors { left: parent.left; leftMargin: 20 }
                            text: "Port"
                        }
                        TextField {
                            id: proxyport
                            anchors { left: parent.left; leftMargin: 20; topMargin: 30 }
                            width: 440
                            text: form.proxyConfig.Servers ? form.proxyConfig.Servers[0].split(":")[1] : ""
                            // TODO: validator
                        }
                    }
                }

                Column {
                    id: proxyAutoFields
                    anchors { left: parent.left; right: parent.right }

                    spacing: 50
                    CheckBox {
                        id: proxyAutoUrl
                        text: "Use URL provided by DHCP server"
                    }
                    Column {
                        visible: !proxyAutoUrl.checked
                        anchors { left: parent.left; right: parent.right }

                        Text {
                            anchors { left: parent.left; leftMargin: 20 }
                            text: "URL"
                        }
                        TextField {
                            id: proxyurl
                            anchors { left: parent.left; leftMargin: 20; top:parent.top; topMargin: 30 }
                            width: 440
                            readOnly: proxyAutoUrl.checked
                            text: form.proxy.URL
                            // TODO: validator
                        }
                    }
                }
            }
        }
    }
}

