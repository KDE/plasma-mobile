import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import "../components"

Rectangle {
    id: dialer
    color: "black"
    opacity: 0.8

    property color textColor: "white"
    property bool calling: false // needs to be connected to a system service
    property bool enableButtons: calling

    function addNumber(number) {
        status.text = status.text + number
    }

    function call() {
        if (!calling) {
            console.log("Calling: " + status.text);
        } else {
            console.log("Hanging up: " + status.text);
            status.text = '';
        }

        dialer.calling = !dialer.calling;
    }

    function fromContacts() {
        console.log("Should get from contacts!");
        status.text = "+41 76 555 5555"
    }

    Text {
        id: status
        height: parent.height / 6
        width: parent.width
        horizontalAlignment: Qt.AlignRight
        verticalAlignment: Qt.AlignVCenter
        font.pixelSize: one.font.pixelSize
        color: textColor
    }

    Grid {
        id: pad
        columns: 3
        spacing: 0
        property int buttonHeight: height / 5
        anchors {
            top: status.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        height: parent.height - status.height
        width: parent.width

        DialerButton { id: one; text: "1" } 
        DialerButton { text: "2" }
        DialerButton { text: "3" }

        DialerButton { text: "4" } 
        DialerButton { text: "5" }
        DialerButton { text: "6" }

        DialerButton { text: "7" } 
        DialerButton { text: "8" }
        DialerButton { text: "9" }

        DialerButton { text: "*"; } 
        DialerButton { text: "0"; sub: "+"; }
        DialerButton { text: "#" }

        DialerIconButton {
            source: "im-user"
            callback: fromContacts
        }
        DialerIconButton {
            id: callButton
            source: dialer.calling ? "call-stop" : "call-start"
            callback: call
        }
        DialerIconButton { 
            source: "edit-clear"
            callback: function() {
                if (status.text.length > 0) {
                    status.text = status.text.substr(0, status.text.length - 1);
                } else {
                    dialer.calling = true;
                    dialer.calling = false;
                }
            }
        }
    }
}
