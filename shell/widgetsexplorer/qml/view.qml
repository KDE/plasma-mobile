
import Qt 4.7
import Plasma 0.1 as Plasma

Rectangle {
    color: Qt.rgba(0,0,0,0.4)

    
    GridView {
        id: appletsView
        objectName: "appletsView"

        width: parent.width
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 4
        anchors.bottomMargin: closeButton.height

        model: myModel
        flow: GridView.LeftToRight
        snapMode: GridView.SnapToRow
        cellWidth: width/5
        cellHeight: height/4
        clip: true
        signal addAppletRequested
        signal closeRequested

        delegate: Component {
            Item {
                id: wrapper
                width: wrapper.GridView.view.cellWidth-40
                height: wrapper.GridView.view.cellWidth-40
                property string appletPlugin : pluginName

                Plasma.IconWidget {
                    minimumIconSize : "64x64"
                    maximumIconSize : "64x64"
                    preferredIconSize : "64x64"
                    minimumSize.width: wrapper.width
                    minimumSize.height: wrapper.height
                    id: resultwidget
                    icon: decoration
                    text: display
                }

                MouseArea {
                    id: mousearea
                    
                    anchors.fill: parent
                    onClicked : {
                        appletsView.currentIndex = index
                        detailsIcon.icon = decoration
                        detailsName.text = display
                        detailsVersion.text = "Version "+version
                        detailsDescription.text = description
                        detailsAuthor.text = "<b>Author:</b> "+author
                        detailsEmail.text = "<b>Email:</b> "+email
                        detailsLicense.text = "<b>License:</b> "+license

                        appletsView.width = (appletsView.parent.width/4)*3;
                        infoPanel.state = "shown"
                    }
                }
            }
        }
    }
    Rectangle {
        id: infoPanel

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 4
        anchors.rightMargin: 4

        state: "hidden"

        x: parent.width

        width: parent.width/4;
        
        color: Qt.rgba(0,0,0,0.4)

        Plasma.IconWidget {
            id: detailsIcon
            y: 8
            anchors.horizontalCenter: parent.horizontalCenter
            minimumIconSize : "128x128"
            maximumIconSize : "128x128"
            preferredIconSize : "128x128"
        }

        Flickable {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: detailsIcon.bottom
            anchors.bottom: parent.bottom
            anchors.bottomMargin: addButton.height + 40
            contentWidth: column.width;
            contentHeight: column.height
            interactive : true
            clip:true

            Column {
                id:column;
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 8
                
                spacing: 8

                Text {
                    id: detailsName

                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize : 30;
                    wrapMode : Text.Wrap

                    color: "white"
                }
                
                Text {
                    id: detailsVersion

                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    wrapMode : Text.Wrap

                    color: "white"
                }

                Text {
                    id: detailsDescription

                    width: parent.width
                    wrapMode : Text.Wrap

                    color: "white"
                }


                Text {
                    id: detailsAuthor

                    width: parent.width
                    wrapMode : Text.Wrap

                    color: "white"
                }

                Text {
                    id: detailsEmail

                    width: parent.width
                    wrapMode : Text.Wrap

                    color: "white"
                }

                Text {
                    id: detailsLicense

                    width: parent.width
                    wrapMode : Text.Wrap

                    color: "white"
                }
            }
        }
        
        Plasma.PushButton {
            id: addButton
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            anchors.bottomMargin: closeButton.height + 32

            text: "Add widget"
            onClicked : appletsView.addAppletRequested()
        }
        
        states: [
            State {
                name: "shown"
                PropertyChanges {
                    target: infoPanel;
                    x: infoPanel.parent.width - infoPanel.width
                }
            }
        ]

        transitions: [
            Transition {
                from: "hidden"
                to:"shown"

                NumberAnimation {
                    properties: "x";
                    duration: 300;
                    easing.type: "OutQuad";
                }
            }
        ]
    }


    Plasma.PushButton {
        id: closeButton
        width: addButton.width
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.bottomMargin: 4

        text: "Close"
        onClicked : appletsView.closeRequested()
    }

}
