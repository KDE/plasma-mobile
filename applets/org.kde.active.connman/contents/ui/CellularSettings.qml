import Qt 4.7
import MeeGo.Components 0.1 as MeeGo
import MeeGo.Connman 0.1
import MeeGo.Settings 0.1

MeeGo.AppPage {
    id: container
    pageTitle: qsTr("Cellular Settings")

    property NetworkItemModel networkItem: null

    CellularSettingsModel { id: cellularSettings }

    Flickable {
        id: contentArea
        anchors.fill: parent
        clip: true
        contentWidth: parent.width
        contentHeight: contents.height

        Column {
            id: contents
            width: parent.width

            Image {
                width: parent.width
                source: "image://themedimage/images/settings/pulldown_box_2"

                Text {
                    text: qsTr("Manual APN entry")
                    width: 100
                    height: parent.height
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    verticalAlignment: Text.AlignVCenter
                }

                MeeGo.ToggleButton {
                    id: manualApn
                    on: false
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Grid {
                id: dropDowns
                visible: !manualApn.on
                columns: 2
                spacing: 10
                width: parent.width
                height: childrenRect.height

                property string country: ""
                property string provider: networkItem.name
                property string apn: cellularSettings.apn;

                Text {
                    text: qsTr("Country")
                }

                MeeGo.DropDown {
                    id: countryDropdown
                    width: 200
                    model: cellularSettings.countries()
                    payload: cellularSettings.countries()
                    replaceDropDownTitle: true

                    onTriggered: {
                        var data = payload[index]
                        dropDowns.country = data;
                        console.log("setting provider dropdownlist to: " + data)
                    }
                }

                Text {
                    text: qsTr("Provider")
                }

                MeeGo.DropDown {
                    id: providerDropdown
                    width: 200
                    model: cellularSettings.providers(dropDowns.country)
                    payload: cellularSettings.providers(dropDowns.country)
                    replaceDropDownTitle: true
                    selectedIndex: cellularSettings.providers(dropDowns.country).indexOf(dropDowns.provider)
                    onTriggered: {
                        dropDowns.provider = payload[index]
                        console.log("setting provider to: " + dropDowns.provider)
                    }
                }

                Text {
                    text: qsTr("APN")
                }

                MeeGo.DropDown {
                    id: apnDropDown
                    width: 200
                    model: cellularSettings.apns(dropDowns.country,dropDowns.provider)
                    payload: cellularSettings.apns(dropDowns.country,dropDowns.provider)
                    replaceDropDownTitle: true
                    selectedIndex: cellularSettings.apns(dropDowns.country,dropDowns.provider).indexOf(apn)
                    onTriggered: {
                        dropDowns.apn = payload[index]
                        cellularSettings.setApn(dropDowns.apn)
                        networkItem.apn = dropDowns.apn
                    }
                }
            }

            Grid {
                id: manualEntry
                width: parent.width
                columns: 2
                height: childrenRect.height
                visible: manualApn.on
                Text {
                    text: qsTr("APN")
                }

                MeeGo.TextEntry {
                    id: apn
                    width: parent.width / 3
                    text: cellularSettings.apn

                }

                Text {
                    text: qsTr("Username")
                }

                MeeGo.TextEntry {
                    id: username
                    width: parent.width / 3
                    text: cellularSettings.username()

                }

                Text {
                    text: qsTr("Password")
                }

                MeeGo.TextEntry {
                    id: password
                    width: parent.width / 3
                    text: cellularSettings.password()
                }

                MeeGo.Button {
                    width: parent.width / 3
                    height: 50
                    text: qsTr("Apply");
                    elideText: true
                    onClicked: {
                        cellularSettings.setApn(apn.text, username.text, password.text)
                        networkItem.apn = apn.text
                    }
                }

            }
        }
    }
}
