import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore

Rectangle {
    id: main
    color: Qt.rgba(0,0,0,0.4)
    width: 800
    height: 480

    PlasmaCore.Theme {
        id:theme
    }

    Flickable {
        id: mainFlickable
        interactive:true
        contentWidth: container.width; contentHeight: container.height
        anchors.fill: parent
        clip: true
        anchors.topMargin: 32
        anchors.bottomMargin: 128
        anchors.leftMargin: 4
        anchors.rightMargin: 4


        Column {
            id: container
            Component.onCompleted: {
                mainFlickable.contentY = searchFieldContainer.height
            }

            Item {
                id: searchFieldContainer
                width: parent.width
                height: 128
                PlasmaCore.FrameSvgItem {
                    id : background
                    imagePath: "widgets/lineedit"
                    prefix: "base"

                    width: 300
                    height: 35
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    TextInput {
                        id: searchField
                        anchors.fill:parent
                        anchors.leftMargin: background.margins.left
                        anchors.rightMargin: background.margins.right
                        anchors.topMargin: background.margins.top
                        anchors.bottomMargin: background.margins.bottom
                        onTextChanged: {
                            searchTimer.running = true
                        }
                    }
                    Timer {
                        id: searchTimer
                        interval: 500;
                        running: false
                        repeat: false
                        onTriggered: {
                            if (searchField.text == "") {
                                myModel.setQuery(myModel.defaultQuery)
                            } else {
                                myModel.setQuery(searchField.text)
                            }
                            mainFlickable.contentY = searchFieldContainer.height
                        }
                    }
                }
            }
            GridView {
                id: appsView
                objectName: "appsView"
                width: mainFlickable.width
                height: mainFlickable.height

                model: myModel
                flow: GridView.TopToBottom
                snapMode: GridView.SnapOneRow
                cellWidth: width/6
                cellHeight: 64+32
                clip: true
                signal clicked

                onWidthChanged : {
                    if (width > 600) {
                        cellWidth = width/6
                    } else {
                        cellWidth = width/4
                    }
                }

                /*onHeightChanged : {
                    if (height > 600) {
                        cellHeight = height/6
                    } else {
                        cellHeight = height/3
                    }
                }*/

                delegate: Component {
                    Item {
                        id: wrapper
                        width: wrapper.GridView.view.cellWidth
                        height: wrapper.GridView.view.cellHeight
                        property string urlText: url

                        PlasmaWidgets.IconWidget {
                            anchors.horizontalCenter: parent.horizontalCenter
                            size: "64x64"
                            id: iconWidgt
                            icon: decoration
                        }
                        Text {
                            y: 67
                            width: parent.width -16
                            wrapMode:Text.Wrap
                            horizontalAlignment: Text.AlignHCenter
                            clip: true
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: display
                            color: theme.textColor
                        }

                        MouseArea {
                            id: mousearea
                            anchors.fill: parent
                            onClicked : {
                                appsView.currentIndex = index
                                appsView.clicked()
                            }
                        }
                    }
                }
            }
        }
    }
}
