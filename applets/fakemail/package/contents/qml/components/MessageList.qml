import Qt 4.7

Item {
    
    ListModel {
        id: messagesModel
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "Foo Bar"
            subject: "[PATCH] Crash fix"
            text : "Hello,<br/> this patch will fix the problem you encounered"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
    }

    Component {
        id : messageDelegate
        Item {
            width: list.width
            height: layout.height

            Rectangle {
                id : background
                anchors.fill : parent

                Column {
                    id : layout

                    Text {
                        text: subject
                    }
                    Text {
                        text: from
                    }
                }

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.15)  }
                }
            }
        }
    }

    // The actual list
    ListView {
        id: list
        anchors.fill: parent
        clip: true
        model: messagesModel
        delegate: messageDelegate
    }
}