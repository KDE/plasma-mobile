
import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Rectangle {
    color: Qt.rgba(0,0,0,0.4)
    id: widgetsExplorer
    objectName: "widgetsExplorer"
    state: "horizontal"
    width:800
    height:480

    signal addAppletRequested(string plugin)
    signal closeRequested

    states: [
        State {
            name: "horizontal"
            PropertyChanges {
                target: infoPanel;
                x: parent.width
                y: 0
                width: parent.width/4
                height: parent.height
            }
            PropertyChanges {
                target: appletsView;
                anchors.bottom: widgetsExplorer.bottom
                anchors.right: infoPanel.left
            }
            PropertyChanges {
                target: infoContent;
                anchors.bottomMargin: closeButton.height + 16
            }
            PropertyChanges {
                target: detailsIcon
                anchors.horizontalCenter: parent.horizontalCenter
            }
        },
        State {
            name: "vertical"
            PropertyChanges {
                target: infoPanel;
                x: 0
                y: parent.height
                width: parent.width
                height: parent.height/4
            }
            PropertyChanges {
                target: appletsView;
                anchors.bottom: infoPanel.top
                anchors.right: widgetsExplorer.right
            }
            PropertyChanges {
                target: infoContent;
                anchors.bottomMargin: 0
            }
            PropertyChanges {
                target: detailsIcon
                anchors.horizontalCenter: undefined
            }
        }
    ]

    onWidthChanged : {
        orientationTimer.running = true
    }

    Timer {
        id: orientationTimer
        running: false
        repeat: false
        interval: 200
        onTriggered: {
            if (width > height) {
                state = "horizontal"
            } else {
                state = "vertical"
                infoPanel.height = 200
            }
        }
    }


    MobileComponents.IconGrid {
        id: appletsView
        property string currentPlugin
        model: myModel


        delegate: Component {
            MobileComponents.IconDelegate {
                icon: decoration
                text: display
                onClicked: {
                    currentPlugin = pluginName
                    detailsIcon.icon = decoration
                    detailsName.text = display
                    detailsVersion.text = "Version "+version
                    detailsDescription.text = description
                    detailsAuthor.text = "<b>Author:</b> "+author
                    detailsEmail.text = "<b>Email:</b> "+email
                    detailsLicense.text = "<b>License:</b> "+license

                    //appletsView.width = (appletsView.parent.width/4)*3;
                    //appletsView.cellWidth = appletsView.width/3
                    infoPanel.state = "shown"
                }
            }
        }

        onSearchQueryChanged: {
            appletsFilter.filterRegExp = ".*"+searchQuery+".*"
        }


        width: parent.width
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 4
        anchors.bottomMargin: closeButton.height
    }


    Rectangle {
        id: infoPanel

        state: "hidden"

        color: Qt.rgba(0,0,0,0.4)

        Flow {
            id: infoContent
            anchors.fill:parent

            PlasmaWidgets.IconWidget {
                id: detailsIcon
                y: 8
                anchors.horizontalCenter: parent.horizontalCenter
                minimumIconSize : "128x128"
                maximumIconSize : "128x128"
                preferredIconSize : "128x128"
            }


            Flickable {
                width: (widgetsExplorer.state == "horizontal")?parent.width:parent.width - detailsIcon.width - addButtonParent.width
                height: (widgetsExplorer.state == "horizontal")?parent.height - detailsIcon.height - addButton.height:parent.height
                contentWidth: width;
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


            Item {
                id: addButtonParent
                width: widgetsExplorer.width/4
                height: addButton.height
                PlasmaWidgets.PushButton {
                    id: addButton
                    anchors.right: parent.right
                    anchors.rightMargin: 4

                    text: "Add widget"
                    onClicked : widgetsExplorer.addAppletRequested(appletsView.currentPlugin)
                }
            }

        }

        states: [
            State {
                name: "shown"
                PropertyChanges {
                    target: infoPanel;
                    x: if (widgetsExplorer.state == "horizontal")
                           infoPanel.parent.width - infoPanel.width
                       else
                           infoPanel.x

                    y: if (widgetsExplorer.state == "vertical")
                           infoPanel.parent.height - infoPanel.height
                       else
                           infoPanel.y
                }
            }
        ]

        transitions: [
            Transition {
                from: "hidden"
                to:"shown"

                NumberAnimation {
                    properties: "x,y";
                    duration: 300;
                    easing.type: "OutQuad";
                }
            }
        ]
    }


    PlasmaWidgets.PushButton {
        id: closeButton
        width: addButton.width
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.bottomMargin: 4

        text: "Close"
        onClicked : widgetsExplorer.closeRequested()
    }

}
