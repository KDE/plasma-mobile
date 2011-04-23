 
import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
 
Item {
    id: resourceItem
    height: 72
    width: 400

    Item {
        id: itemFrame
        anchors {   bottom: parent.bottom;
                    top: parent.top;
                    left: parent.left;
                    right: parent.right;
                    margins: 24;
        }
        //height: 128
        height: resourceItem.height

        PlasmaWidgets.IconWidget {
            id: previewImage
            height:64
            width: 64
            anchors.margins: 8

            function resourceIcon(resourceTypes) {
                var icons = new Object();
                icons["Resource"] = "nepomuk";
                icons["FileDataObject"] = "unknown";

                // Audio
                icons["Audio"] = "audio-x-generic";
                icons["MusicPiece"] = "audio-x-generic";

                // Images
                icons["Image"] = "image-x-generic";
                icons["RasterImage"] = "image-x-generic";

                icons["Email"] = "internet-mail";

                // ... add some more

                // keep searching until the most specific icon is found
                var _icon = "nepomuk";
                var typeList = resourceTypes.split(",");

                for(var i = 0; i < typeList.length; i++) {
                    var shortType = typeList[i].split("#")[1];
                    for (key in icons) {
                        if (key == shortType) {
                            _icon = icons[shortType];
                        }
                    }
                }
                return _icon;
            }

            Component.onCompleted: {
                try {
                    setIcon(hasSymbol);
                } catch(e) {
                    var _i = resourceIcon(types.toString())
                    //print("fallback icon: " + _i);
                    setIcon(_i);
                }
            }
        }

        PlasmaWidgets.Label {
            id: previewLabel
            text: label
            //text: url
            font.pixelSize: 14
            font.bold: true
            height: 30

            width: parent.width - previewImage.width
            anchors.top: itemFrame.top
            //anchors.bottom: infoLabel.top;
            anchors.left: previewImage.right
            anchors.right: itemFrame.right
            anchors.margins: 8
        }

        PlasmaWidgets.Label {
            id: infoLabel
            //image: metadataSource.data[DataEngineSource]["fileName"]
            //text: "the long and winding road..."
            text: className + " This is an Email Resouce Delegate"
            opacity: 0.6
            //font.pixelSize: font.pixelSize * 1.8
            font.pixelSize: 11
            height: 14
            width: parent.width - previewImage.width
            //wrapMode: Text.Wrap
            anchors.right: itemFrame.right
            anchors.top: previewLabel.bottom
            anchors.bottom: itemFrame.bottom
            anchors.left: previewImage.right
            anchors.margins: 8

        }
    }
}