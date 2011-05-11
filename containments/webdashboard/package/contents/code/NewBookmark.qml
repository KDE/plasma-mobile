import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Item {
    id: newBookmarkItem

    property int collapsedWidth: 10
    property int expandedWidth: 200
    property string defaultText: "http://";
    height: 64
    width: parent.width/4

    state: "collapsed"

    PlasmaCore.DataSource {
        id: bookmarksEngine
        engine: "org.kde.active.bookmarks"
        interval: 0
    }
    
    PlasmaWidgets.Frame {
        id: frame
        anchors.fill: parent
        width: parent.width
        height: parent.height
    }

    Row {
        anchors.right: parent.right

        PlasmaWidgets.LineEdit {
        //Rectangle { color: black
            id: lineEdit
            width: expandedWidth
            text: defaultText
            //anchors.top: parent.top
            //anchors.right: newIcon.left
        }
        MobileComponents.IconDelegate {
            id: newIcon
            icon: QIcon("bookmark-new")
            height: parent.height
            width: parent.height
            //anchors { right: parent.right; top: parent.top }
            onClicked: {
                print("--> new bookmark clicked!")
                //state: "expanded"
                print("--> new state: " + state);
                if (newBookmarkItem.state == "expanded") {
                    print("expanded, let's see");
                    if (lineEdit.text != defaultText) {
                        print("==> Add Bookmark: " + lineEdit.text);
                        bookmarksEngine.connectSource("add:" + lineEdit.text);
                    }
                } else {

                }
                newBookmarkItem.state = (newBookmarkItem.state == "expanded") ? "collapsed" : "expanded"
            }
            Component.onCompleted: {
                print("icon done" + icon);
                //icon = "bookmark-new";
                state = "collapsed"
            }
        }

        Item {
            width: 20
        }
    }

    states: [
        State {
            id: expanded
            name: "expanded";
            //when: mouseArea.pressed
            PropertyChanges {
                target: lineEdit
                width: expandedWidth
                opacity: 1.0
            }
        },

        State {
            id: collapsed
            name: "collapsed";
            PropertyChanges {
                target: lineEdit
                width: collapsedWidth
                opacity: 0
            }
        }
    ]

    transitions: [
        Transition {
            PropertyAnimation {
                properties: "width,opacity"
                duration: 400;
                easing.type: Easing.InOutElastic;
                easing.amplitude: 2.0; easing.period: 1.5
            }
        }
    ]

}