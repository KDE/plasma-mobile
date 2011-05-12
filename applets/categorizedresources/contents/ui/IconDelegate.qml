 
import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
 
Item {
    id: resourceItem
    property string resourceType

    Item {
        id: itemFrame
        anchors {   fill: parent
        }
        //height: 128
        height: resourceItem.height

        QIconItem {
            id: previewImage
            height: 64
            width: 64
            anchors.horizontalCenter: parent.horizontalCenter
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
                icons["PersonContact"] = "x-office-contact";
                icons["Document"] = "kword";

                // ... add some more

                // keep searching until the most specific icon is found
                var _icon = "nepomuk";
                var typeList = resourceTypes.split(",");

                for(var i = 0; i < typeList.length; i++) {
                    var shortType = typeList[i].split("#")[1];
                    for (key in icons) {
                        if (key == shortType) {
                            print("M: " + key + icons[shortType]);
                            _icon = icons[shortType];
                        }
                    }
                }
                return _icon;
            }

            Component.onCompleted: {
                try {
                    var _l = hasSymbol.toString().split(",");
                    if (_l.length == 1) {
                        icon = QIcon(hasSymbol);
                    } else if (_l.length > 1) {
                        // pick the last one
                        var _i = _l[_l.length-1];
                        icon = QIcon(_i);
                    } else {
                        //print("HHH types" + types.toString());
                        resourceIcon(types.toString())
                    }
                    print("icon:" + hasSymbol);
                } catch(e) {
                    var _i = resourceIcon(className);
                    print("fallback icon: " + _i + e);
                    icon = QIcon(_i);
                    print("icon2:" + _i);
                }
            }
        }

        Text {
            id: previewLabel
            text: model.label
            //text: url
            font.pixelSize: 14
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter

            anchors.top: previewImage.bottom
            //anchors.bottom: infoLabel.top;
            anchors.left: itemFrame.left
            anchors.right: itemFrame.right
            anchors.margins: 8
        }
    }
}
