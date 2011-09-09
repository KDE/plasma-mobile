/*
 * Copyright 2011 Marco Martin.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.0
import MeeGo.Settings 0.1
import MeeGo.Labs.Components 0.1 as Labs
import MeeGo.Components 0.1
import MeeGo.Connman 0.1


Item {
    id: main
    property int minimumWidth: 300
    property int minimumHeight: 400

    NetworkListModel {
        id: networkListModel

        Component.onCompleted: {
            networkListModel.requestScan();
        }
        onStateChanged: {
            if (state == "online") {
                plasmoid.popupIcon = QIcon("network-connect")
            } else {
                plasmoid.popupIcon = QIcon("network-disconnect")
            }
        }
    }

    ListView {
       anchors.fill:parent
       model: networkListModel
       delegate: Component {
        id: availableNetworkItem
        WifiExpandingBox {
            listModel: networkListModel
            page: container
            width: main.width
            ssid: name
            networkItem: model.networkitemmodel
            currentIndex: model.index
            statusint: model.state
            hwaddy: deviceAddress
            security: model.security
            gateway: model.gateway
            ipaddy: model.ipaddress
            subnet: model.netmask
            method: model.method
            nameservers: model.nameservers
            defaultRoute:  model.defaultRoute
         }
        }

       }
}
