 
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
            print("connected:" + connectedSources);
        }

        onDataUpdated: {
            print(" dataUpdated: " + source + data);
        }
    }

    PlasmaCore.Theme {
        id: theme
    }


    Image {
        id: previewImage
        fillMode: Image.PreserveAspectCrop
        smooth: true
        width: 96
        height: 72

        anchors {
            top: parent.top;
            left: parent.left;
            //right: textLabel.left;
            margins: 12;
        }

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
    Rectangle {
        anchors { top: parent.top; left: parent.left; right: textLabel.right; }
        height: parent.height
        color: theme.textColor
        opacity: .05
        radius: 4
    }

    Component.onCompleted: {
        print("Bookmark created: " + description);
    }
    */
}