import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore

Rectangle {
    color: Qt.rgba(0,0,0,0.4)
    width: 800
    height: 480

    GridView {
        id: appsView
        objectName: "appsView"

        anchors.fill: parent
        anchors.topMargin: Math.max((height-contentHeight)/2, 32)
        anchors.bottomMargin: Math.max((height-contentHeight)/2, 32)
        anchors.leftMargin: 4
        anchors.rightMargin: 4

        model: myModel
        flow: GridView.LeftToRight
        //snapMode: GridView.SnapToRow
        cellWidth: width/6
        cellHeight: height/4
        clip: true
        signal clicked

        onWidthChanged : {
            if (width > 600) {
                cellWidth = width/6
            } else {
                cellWidth = width/4
            }
        }

        onHeightChanged : {
            if (height > 600) {
                cellHeight = height/6
            } else {
                cellHeight = height/4
            }
        }

        header: Item {
            width: parent.width
            height:30
            PlasmaCore.FrameSvgItem {
                id : background
                imagePath: "widgets/lineedit"
                prefix: "base"

                width:300
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
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
                    }
                }
            }
        }
        delegate: Component {
            Item {
                id: wrapper
                width: wrapper.GridView.view.cellWidth-40
                height: wrapper.GridView.view.cellWidth-40
                property string urlText: url

                PlasmaWidgets.IconWidget {
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
                        appsView.currentIndex = index
                        appsView.clicked()
                    }
                }
            }
        }
    }
}
