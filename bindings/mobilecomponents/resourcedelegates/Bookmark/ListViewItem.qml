 
import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
 
Item {
    id: resourceItem
    height: 96
    width: 240

    PlasmaCore.DataSource {
        id: pmSource
        engine: "preview"
        connectedSources: [ description ]
        interval: 0

        Component.onCompleted: {
            //print("connected:" + connectedSources);
        }

        onDataUpdated: {
            //print(" dataUpdated: " + source + data);
        }
    }

    PlasmaCore.Theme {
        id: theme
    }


    Rectangle {
        id: frameRect
        anchors {
            top: parent.top;
            left: parent.left;
            //right: textLabel.left;
            margins: 12;
        }
        width: 100
        height: 67
        color: theme.textColor
        opacity: .6
        radius: 1
    }

    Image {
        id: previewImage
        fillMode: Image.PreserveAspectCrop
        smooth: true
        width: frameRect.width - 2
        height: frameRect.height - 2
        anchors.centerIn: frameRect

        source: {
            if (typeof pmSource.data[description] != "undefined") {
                return pmSource.data[description]["fileName"];
            }
            return "";
        }
    }

    
    /*
    Rectangle {
        border.color: theme.textColor
        anchors.fill: previewImage
        //spacing: 3
        border.width: 3
        opacity: .3
    }
    */
    Text {
        id: textLabel
        color: theme.textColor
        font.pointSize: 14
        style: Text.Sunken;
        styleColor: theme.backgroundColor
        text: {
            var s = description;
            s = s.replace("http://", "");
            s = s.replace("https://", "");
            s = s.replace("www.", "");
            return s;
        }

        anchors {
            right: parent.right;
            bottom: previewImage.bottom;
            left: previewImage.right;
            margins: 12
            //margins: 4;
        }
    }

    PlasmaWidgets.Separator {
        anchors { top: textLabel.bottom; left: textLabel.left; right: textLabel.right; }
    }

    /*

    Component.onCompleted: {
        print("Bookmark created: " + description);
    }
    */
}