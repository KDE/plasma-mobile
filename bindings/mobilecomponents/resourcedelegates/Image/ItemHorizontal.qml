 
import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
 
Item {
    id: resourceItem
    anchors.fill: parent

    PlasmaCore.DataSource {
        id: pmSource
        engine: "preview"
       // connectedSources: [ url ]
        interval: 0
        Component.onCompleted: {
            pmSource.connectedSources = [url]
            previewFrame.visible = data[url]["status"] == "done"
            iconItem.visible = !previewFrame.visible
            previewImage.image = data[url]["thumbnail"]
        }
        onDataChanged: {
            previewFrame.visible = data[url]["status"] == "done"
            iconItem.visible = !previewFrame.visible
            previewImage.image = data[url]["thumbnail"]
        }
    }

    Item {
        id: itemFrame
        anchors {   bottom: parent.bottom;
                    top: parent.top;
                    left: parent.left;
                    right: parent.right;
                    margins: 0;
        }
        //height: 128
        height: resourceItem.height

        QIconItem {
            id: iconItem
            height: 64
            width: 64
            anchors.margins: 0
            anchors.horizontalCenter: parent.horizontalCenter

            function resourceIcon(resourceTypes) {
                if (mimeType) {
                    return mimeType.replace("/", "-")
                }
                return "nepomuk"
            }

            Component.onCompleted: {
                // FIXME: remove this crap, fix icon in metadata data set
                try {
                    if (!model["hasSymbol"]) {
                        icon = decoration
                        return
                    }
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
                    //print("icon:" + hasSymbol);
                } catch(e) {
                    var _i = resourceIcon(className);
                    print("fallback icon: " + _i + e);
                    icon = QIcon(_i);
                    print("icon2:" + _i);
                }
            }
        }
        PlasmaCore.FrameSvgItem {
            imagePath: "widgets/media-delegate"
            prefix: "picture"
            id: previewFrame
            height: width/1.6
            visible: false
            anchors {
                left: parent.left
                right: parent.right
            }
            QImageItem {
                id: previewImage
                anchors.fill: parent
                anchors.margins: previewFrame.margins.left
            }
        }


        Text {
            id: previewLabel
            text: label

            font.pixelSize: 14
            //wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            anchors.top: iconItem.bottom
            anchors.horizontalCenter: itemFrame.horizontalCenter
            width: 130
            style: Text.Outline
            styleColor: Qt.rgba(1, 1, 1, 0.6)
        }

        Text {
            id: infoLabel
            //image: metadataSource.data[DataEngineSource]["fileName"]
            //text: "the long and winding road..."
            text: className
            opacity: 0.8
            //font.pixelSize: font.pixelSize * 1.8
            font.pixelSize: 12
            height: 14
            width: parent.width - iconItem.width
            //wrapMode: Text.Wrap
            anchors.top: previewLabel.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            visible: infoLabelVisible
        }
    }
}
