
import Qt 4.7
import Plasma 0.1 as Plasma
import GraphicsLayouts 4.7

Rectangle {
    color: Qt.rgba(0,0,0,0.4)
    id: widgetsExplorer
    state: "horizontal"
    width:800
    height:480

    states: [
        State {
            name: "horizontal"
            PropertyChanges {
                target: infoPanel;
                anchors.top: widgetsExplorer.top
                anchors.bottom: widgetsExplorer.bottom
                anchors.left: undefined
                anchors.right: undefined
            }
            PropertyChanges {
                target: appletsView;
                anchors.bottom: widgetsExplorer.bottom
                anchors.right: infoPanel.left
            }
            PropertyChanges {
                target: panelLayout;
                orientation: Qt.Vertical
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
                anchors.top: undefined
                anchors.bottom: undefined
                anchors.left: widgetsExplorer.left
                anchors.right: widgetsExplorer.right
                height: 200
            }
            PropertyChanges {
                target: appletsView;
                anchors.bottom: infoPanel.top
                anchors.right: widgetsExplorer.right
            }
            PropertyChanges {
                target: panelLayout;
                orientation: Qt.Horizontal
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

        if (width > 600) {
            state = "horizontal"
        } else {
            state = "vertical"
            //FIXME: why this is necessary?
            infoPanel.height = 200
        }
    }

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
        cellWidth: width/4
        cellHeight: height/3
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

                        //appletsView.width = (appletsView.parent.width/4)*3;
                        //appletsView.cellWidth = appletsView.width/3
                        infoPanel.state = "shown"
                    }
                }
            }
        }

        onWidthChanged : {
            if (widgetsExplorer.state == "horizontal" && infoPanel.state == "hidden") {
                cellWidth = width/4
            } else {
                cellWidth = width/3
            }
        }
        onHeightChanged : {
            if (widgetsExplorer.state == "horizontal") {
                cellHeight = widgetsExplorer.height/3
            } else {
                cellHeight = widgetsExplorer.height/4
            }
        }
    }

    Rectangle {
        id: infoPanel

        anchors.topMargin: 4
        anchors.rightMargin: 4

        state: "hidden"

        x: if (widgetsExplorer.state == "horizontal")
               parent.width
           else
               0

        y: if (widgetsExplorer.state == "vertical")
               parent.height
           else
               0

        width: if (widgetsExplorer.state == "horizontal")
                   parent.width/4
               else
                   parent.width

        height: if (widgetsExplorer.state == "horizontal")
                    parent.height
                else
                    parent.height/4

        color: Qt.rgba(0,0,0,0.4)

        QGraphicsWidget {
            id: infoContent
            anchors.fill:parent
            layout: QGraphicsLinearLayout {
                id:panelLayout
                orientation: Qt.Vertical
                Plasma.IconWidget {
                    id: detailsIcon
                    y: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                    minimumIconSize : "128x128"
                    maximumIconSize : "128x128"
                    preferredIconSize : "128x128"
                }

                LayoutItem {
                    preferredSize: "500x500"
                    Flickable {
                        anchors.fill: parent
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
                }

                Plasma.PushButton {
                    id: addButton
                    maximumSize: maximumSize.width+"x"+preferredSize.height

                    text: "Add widget"
                    onClicked : appletsView.addAppletRequested()
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
