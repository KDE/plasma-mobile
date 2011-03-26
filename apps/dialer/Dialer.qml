import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaWidgetsCore
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import "widgets"

MainWindow {
    signal okClicked()  
    property string typedNumber: pad.typedNumber
    
    Rectangle {
        width: parent.width
        height: 64
        x: 0
        y: 0
        color: "#303030"
        
        Label {
            text: "Telephone"
            x: 290
        }
    }
    
    Row {
        y: 65
        spacing: 10
        Column {
            spacing: 90
            PlasmaWidgets.IconWidget {
                width: 64
                height: 64
                icon: QIcon("im-user")
            }
            
            PlasmaWidgets.IconWidget {
                width: 64
                height: 64
                icon: QIcon("internet-telephony")
            }
            
            PlasmaWidgets.IconWidget {
                width: 64
                height: 64
                icon: QIcon("go-down")
            }
        }
        
        Column {
            PlasmaWidgets.LineEdit {
                text: pad.typedNumber
                width: 350
                height: 280
                font.pointSize: 24;
            }
            
            Row {
                Button {
                   width: 250
                   height: 95
                   text: i18n("Call")
                   onClicked: okClicked()
                }
                
                Button {
                   text: "<"                    
                   width: 100
                   height: 95
                   onClicked: {
                        pad.typedNumber = pad.typedNumber.slice(0, -1)
                    }
                }
            }
        }

        PhonePad {
            id: pad
            width: 354
            height: 380
        }
    }
}
