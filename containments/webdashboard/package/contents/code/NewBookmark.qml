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

    PlasmaCore.FrameSvgItem {
        id: frame
        //state: "hidden"
        enabledBorders: "LeftBorder|TopBorder|BottomBorder"
        imagePath: "widgets/background"
        anchors.fill: parent
        width: parent.width + 32
        height: parent.height
    }

    Row {
        anchors.right: parent.right

        PlasmaWidgets.LineEdit {
        //Rectangle { color: black
            id: lineEdit
            width: expandedWidth
            text: defaultText
            y: frame.margins.top
            clearButtonShown: true
            //anchors.top: parent.top
            //anchors.right: newIcon.left
        }
        PlasmaWidgets.IconWidget {
            anchors.horizontalCenter: parent.horizontalCenter
            minimumIconSize : "32x32"
            maximumIconSize : "32x32"
            preferredIconSize : "32x32"
            id: newIcon
            icon: QIcon("bookmark-new")
            //height: parent.height
            //width: parent.height
            y: frame.margins.top
            anchors.right: parent.right
            //x: parent.width - frame.margins.right - width
            //anchors { right: parent.right; top: parent.top }
            onClicked: {
                print("--> new bookmark clicked!")
                //state: "expanded"
                print("--> new state: " + state);
                if (newBookmarkItem.state == "expanded") {
                    print("expanded, let's see");
                    if (isValidBookmark(lineEdit.text)) {
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

            function isValidBookmark(url) {
                var ok = true;

                // empty?
                if (url == "") ok = false;

                // does it begin with http(s)://?
                if ((url.indexOf("http://") != 0) && 
                            (url.indexOf("https://") != 0)) {
                    ok = false;
                }

                if (url == defaultText) {
                    ok = false;
                }
                print("valid url? " + url + " " + ok);
                return ok;
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
            PropertyChanges {
                target: frame
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
            PropertyChanges {
                target: frame
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